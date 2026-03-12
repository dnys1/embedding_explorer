import path = require("node:path");

import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import mime from "mime";

import { githubActionsInfraRole, githubActionsWorkloadsRole } from "./github";
import { workloadsProvider } from "./providers";
import { crawlDirectory, getFileHash } from "./util";

const config = new pulumi.Config();
const domainName = config.require("domain");
const rootDomain = domainName.split(".").slice(1).join(".");

const zone = aws.route53.getZoneOutput(
  {
    name: rootDomain,
  },
  { provider: workloadsProvider }
);

const certificate = new aws.acm.Certificate(
  "certificate",
  {
    domainName: domainName,
    validationMethod: "DNS",
    subjectAlternativeNames: [`*.${domainName}`],
  },
  { provider: workloadsProvider }
);

const certificateValidationDomain = new aws.route53.Record(
  "certificateValidationDomain",
  {
    zoneId: zone.zoneId,
    name: certificate.domainValidationOptions[0].resourceRecordName,
    type: certificate.domainValidationOptions[0].resourceRecordType,
    records: [certificate.domainValidationOptions[0].resourceRecordValue],
    ttl: 600,
  },
  { provider: workloadsProvider }
);

const certificateValidation = new aws.acm.CertificateValidation(
  "certificateValidation",
  {
    certificateArn: certificate.arn,
    validationRecordFqdns: [certificateValidationDomain.fqdn],
  },
  { provider: workloadsProvider }
);

const websiteBucket = new aws.s3.Bucket(
  "websiteBucket",
  {
    bucket: domainName,
  },
  { provider: workloadsProvider }
);
new aws.s3.BucketWebsiteConfiguration(
  "websiteBucketConfiguration",
  {
    bucket: websiteBucket.bucket,
    indexDocument: { suffix: "index.html" },
  },
  { parent: websiteBucket, provider: workloadsProvider }
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
      provider: workloadsProvider,
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
  },
  { provider: workloadsProvider }
);

// CloudFront Function for SPA routing and redirecting www. to apex domain
//
// This function handles SPA routing by serving index.html for routes that don't
// correspond to actual files, while allowing static assets to be served normally.
//
// Redirects ensure that every URL has a single, canonical URL.
const routingFunction = new aws.cloudfront.Function(
  "routingFunction",
  {
    name: "embedding-explorer-function",
    runtime: "cloudfront-js-2.0",
    publish: true,
    code: `
function handler(event) {
  var request = event.request;

  // Redirect www. to apex domain
  var host = request.headers.host;
  if (host && host.value.startsWith('www.')) {
    return redirectToApex(request, host.value);
  }
  
  // SPA routing logic
  var uri = request.uri; // The relative path, e.g. "/about" or "/js/app.js"
  
  // If the URI has a file extension or ends with a slash, serve it as-is
  var pathSegments = uri.split('/');
  var lastSegment = pathSegments[pathSegments.length - 1];
  if (lastSegment && lastSegment.includes('.')) {
    return request;
  }
  
  // For routes without extensions (SPA routes), serve index.html
  request.uri = '/index.html';
  return request;
}

// Redirect from www. to apex domain, preserving path and query string.
function redirectToApex(request, host) {
  var apex = host.replace(/^www\./, '');
  var location = 'https://' + apex + request.uri;
  
  // Build query string from querystring object
  var queryParams = [];
  for (var key in request.querystring) {
    if (request.querystring.hasOwnProperty(key)) {
      var param = request.querystring[key];
      if (param.multiValue) {
        // Handle multi-value parameters
        for (var i = 0; i < param.multiValue.length; i++) {
          queryParams.push(encodeURIComponent(key) + '=' + encodeURIComponent(param.multiValue[i].value));
        }
      } else if (param.value !== undefined) {
        // Handle single-value parameters
        queryParams.push(encodeURIComponent(key) + '=' + encodeURIComponent(param.value));
      } else {
        // Handle parameters without values (e.g., ?flag)
        queryParams.push(encodeURIComponent(key));
      }
    }
  }
  
  if (queryParams.length > 0) {
    location += '?' + queryParams.join('&');
  }
  
  return {
    statusCode: 301,
    statusDescription: 'Moved Permanently',
    headers: {
      'location': { value: location },
    },
  };
}`,
  },
  { provider: workloadsProvider }
);

// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html
// https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
const cachePolicyId = aws.cloudfront
  .getCachePolicy(
    {
      name: "Managed-CachingOptimized",
    },
    { provider: workloadsProvider }
  )
  .then((policy) => policy.id!);
const originRequestPolicyId = aws.cloudfront
  .getOriginRequestPolicy(
    {
      name: "Managed-CORS-S3Origin",
    },
    { provider: workloadsProvider }
  )
  .then((policy) => policy.id!);
const responseHeadersPolicyId = aws.cloudfront
  .getResponseHeadersPolicy(
    {
      name: "Managed-SecurityHeadersPolicy",
    },
    { provider: workloadsProvider }
  )
  .then((policy) => policy.id!);
const cdn = new aws.cloudfront.Distribution(
  "cdn",
  {
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

      cachePolicyId,
      originRequestPolicyId,
      responseHeadersPolicyId,

      viewerProtocolPolicy: "redirect-to-https",
      allowedMethods: ["GET", "HEAD", "OPTIONS"],
      cachedMethods: ["GET", "HEAD", "OPTIONS"],

      compress: true,

      functionAssociations: [
        {
          eventType: "viewer-request",
          functionArn: routingFunction.arn,
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
  },
  { provider: workloadsProvider }
);

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
  { parent: websiteBucket, provider: workloadsProvider }
);

new aws.route53.Record(
  "websiteDomainRecord",
  {
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
  },
  { provider: workloadsProvider }
);

new aws.route53.Record(
  "websiteDomainRecordWWW",
  {
    zoneId: zone.zoneId,
    name: pulumi.interpolate`www.${domainName}`,
    type: "CNAME",
    records: [domainName],
    ttl: 300,
  },
  { provider: workloadsProvider }
);

export const certificateArn = certificate.arn;
export const bucketName = websiteBucket.bucket;
export const cloudfrontDistributionId = cdn.id;
export const cdnDomain = cdn.domainName;
export const websiteUrl = pulumi.interpolate`https://${domainName}`;
export const githubActionsInfraRoleArn = githubActionsInfraRole.arn;
export const githubActionsWorkloadsRoleArn = githubActionsWorkloadsRole.arn;
