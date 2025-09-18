import path = require("node:path");

import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import mime from "mime";

import { crawlDirectory, getFileHash } from "./util";

const config = new pulumi.Config();
const domainName = config.require("domain");
const rootDomain = domainName.split(".").slice(1).join(".");

const zone = aws.route53.getZoneOutput({
  name: rootDomain,
});

const certificate = new aws.acm.Certificate("certificate", {
  domainName: domainName,
  validationMethod: "DNS",
  subjectAlternativeNames: [`*.${domainName}`],
});

const certificateValidationDomain = new aws.route53.Record(
  "certificateValidationDomain",
  {
    zoneId: zone.zoneId,
    name: certificate.domainValidationOptions[0].resourceRecordName,
    type: certificate.domainValidationOptions[0].resourceRecordType,
    records: [certificate.domainValidationOptions[0].resourceRecordValue],
    ttl: 600,
  }
);

const certificateValidation = new aws.acm.CertificateValidation(
  "certificateValidation",
  {
    certificateArn: certificate.arn,
    validationRecordFqdns: [certificateValidationDomain.fqdn],
  }
);

const websiteBucket = new aws.s3.Bucket("websiteBucket", {
  bucket: domainName,
});
new aws.s3.BucketWebsiteConfiguration(
  "websiteBucketConfiguration",
  {
    bucket: websiteBucket.bucket,
    indexDocument: { suffix: "index.html" },
  },
  { parent: websiteBucket }
);

const srcDir = "../build";
crawlDirectory(srcDir, (filePath: string) => {
  const relativeFilePath = path.relative(srcDir, filePath);
  new aws.s3.BucketObject(
    relativeFilePath,
    {
      key: relativeFilePath,
      bucket: websiteBucket.bucket,
      sourceHash: getFileHash(filePath),
      contentType: mime.getType(filePath) || undefined,
      source: new pulumi.asset.FileAsset(filePath),
    },
    {
      parent: websiteBucket,
    }
  );
});

const originAccessControl = new aws.cloudfront.OriginAccessControl(
  "originAccessControl",
  {
    name: "embedding-explorer-origin-access-control",
    description: "Origin Access Control for website bucket",
    originAccessControlOriginType: "s3",
    signingBehavior: "always",
    signingProtocol: "sigv4",
  }
);

// CloudFront Function to redirect www. to apex domain
//
// This ensures that every URL has a single, canonical URL.
const redirectWwwToApex = new aws.cloudfront.Function(
  "redirectWwwToApexFunction",
  {
    name: "embedding-explorer-redirect-www-to-apex-function",
    runtime: "cloudfront-js-2.0",
    publish: true,
    code: `
function handler(event) {
  var request = event.request;
  var host = request.headers.host.value;
  if (host.startsWith('www.')) {
    var apex = host.replace(/^www\./, '');
    var location = 'https://' + apex + request.uri;
    if (request.querystring && request.querystring.length > 0) {
      location += '?' + request.querystring;
    }
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        'location': { value: location },
      },
    };
  }
  return request;
}`,
  }
);

// CloudFront Function for SPA routing
//
// This function handles SPA routing by serving index.html for routes that don't
// correspond to actual files, while allowing static assets to be served normally.
const spaRoutingFunction = new aws.cloudfront.Function("spaRoutingFunction", {
  name: "embedding-explorer-spa-routing-function",
  runtime: "cloudfront-js-2.0",
  publish: true,
  code: `
function handler(event) {
  var request = event.request;
  var uri = request.uri;
  
  // If the URI has a file extension or ends with a slash, serve it as-is
  if (uri.includes('.') || uri.endsWith('/')) {
    return request;
  }
  
  // For routes without extensions (SPA routes), serve index.html
  request.uri = '/index.html';
  return request;
}`,
});

// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html
// https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
const cdn = new aws.cloudfront.Distribution("cdn", {
  enabled: true,
  aliases: [domainName, pulumi.interpolate`www.${domainName}`],

  origins: [
    {
      originId: websiteBucket.arn,
      domainName: websiteBucket.bucketRegionalDomainName,
      originAccessControlId: originAccessControl.id,
    },
  ],

  defaultRootObject: "index.html",

  defaultCacheBehavior: {
    targetOriginId: websiteBucket.arn,

    cachePolicyId: aws.cloudfront
      .getCachePolicy({
        name: "Managed-CachingOptimized",
      })
      .then((policy) => policy.id!),
    originRequestPolicyId: aws.cloudfront
      .getOriginRequestPolicy({
        name: "Managed-CORS-S3Origin",
      })
      .then((policy) => policy.id!),
    responseHeadersPolicyId: aws.cloudfront
      .getResponseHeadersPolicy({
        name: "Managed-SecurityHeadersPolicy",
      })
      .then((policy) => policy.id!),

    viewerProtocolPolicy: "redirect-to-https",
    allowedMethods: ["GET", "HEAD", "OPTIONS"],
    cachedMethods: ["GET", "HEAD", "OPTIONS"],

    compress: true,

    functionAssociations: [
      {
        eventType: "viewer-request",
        functionArn: redirectWwwToApex.arn,
      },
      {
        eventType: "viewer-request",
        functionArn: spaRoutingFunction.arn,
      },
    ],
  },

  priceClass: "PriceClass_100",

  restrictions: {
    geoRestriction: {
      restrictionType: "none",
    },
  },

  viewerCertificate: {
    acmCertificateArn: certificateValidation.certificateArn,
    minimumProtocolVersion: "TLSv1.2_2021",
    sslSupportMethod: "sni-only",
  },
});

new aws.s3.BucketPolicy(
  "websiteBucketPolicy",
  {
    bucket: websiteBucket.bucket,
    policy: {
      Version: "2012-10-17",
      Statement: [
        {
          Sid: "AllowCloudFrontServicePrincipalReadOnly",
          Effect: "Allow",
          Principal: {
            Service: "cloudfront.amazonaws.com",
          },
          Action: ["s3:GetObject"],
          Resource: [pulumi.interpolate`${websiteBucket.arn}/*`],
          Condition: {
            StringEquals: {
              "AWS:SourceArn": cdn.arn,
            },
          },
        },
      ],
    },
  },
  { parent: websiteBucket }
);

new aws.route53.Record("websiteDomainRecord", {
  zoneId: zone.zoneId,
  name: domainName,
  type: "A",
  aliases: [
    {
      name: cdn.domainName,
      zoneId: cdn.hostedZoneId,
      evaluateTargetHealth: true,
    },
  ],
});

new aws.route53.Record("websiteDomainRecordWWW", {
  zoneId: zone.zoneId,
  name: pulumi.interpolate`www.${domainName}`,
  type: "CNAME",
  records: [domainName],
  ttl: 300,
});

export const certificateArn = certificate.arn;
export const bucketName = websiteBucket.bucket;
export const cloudfrontDistributionId = cdn.id;
export const cdnDomain = cdn.domainName;
export const websiteUrl = pulumi.interpolate`https://${domainName}`;
