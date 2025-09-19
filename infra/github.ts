import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

import { infraProvider, workloadsProvider } from "./providers";

const config = new pulumi.Config();
const githubRepo = config.require("githubRepo");

// Sets up the necessary roles in the Infrastructure and Workloads accounts so that GitHub actions
// can assume them.
//
// 1. GitHub actions assumes the infra role via OIDC, granting it access to Pulumi state and encryption key.
// 2. The infra role can then assume the workloads role to perform deployments (S3, CloudFront, Route53, ACM, etc).

// GitHub OIDC Identity Provider
const githubOidcProvider = aws.iam.getOpenIdConnectProviderOutput(
  {
    url: "https://token.actions.githubusercontent.com",
  },
  { provider: infraProvider }
);

// IAM Role for GitHub Actions - Infrastructure Provisioning
export const githubActionsInfraRole = new aws.iam.Role(
  "githubActionsInfraRole",
  {
    name: "embedding-explorer-github-actions-infra",
    assumeRolePolicy: {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: {
            Federated: githubOidcProvider.arn,
          },
          Action: "sts:AssumeRoleWithWebIdentity",
          Condition: {
            StringEquals: {
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            },
            StringLike: {
              "token.actions.githubusercontent.com:sub": `repo:${githubRepo}:*`,
            },
          },
        },
      ],
    },
  },
  { provider: infraProvider }
);

// IAM Role for GitHub Actions - Workloads (S3/CloudFront operations)
export const githubActionsWorkloadsRole = new aws.iam.Role(
  "githubActionsWorkloadsRole",
  {
    name: "embedding-explorer-github-actions-workloads",
    assumeRolePolicy: {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: {
            AWS: githubActionsInfraRole.arn,
          },
          Action: ["sts:AssumeRole", "sts:TagSession"],
        },
      ],
    },
  },
  { provider: workloadsProvider }
);

// Policy for infrastructure provisioning (Pulumi state management)
new aws.iam.RolePolicy(
  "infraProvisioningPolicy",
  {
    role: githubActionsInfraRole.id,
    policy: {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Action: [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket",
          ],
          Resource: [
            "arn:aws:s3:::embedding-explorer-pulumi-state",
            "arn:aws:s3:::embedding-explorer-pulumi-state/*",
          ],
        },
        {
          Effect: "Allow",
          Action: ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"],
          Resource:
            "arn:aws:kms:us-east-1:*:key/5bd0c37c-4a15-404a-972d-a2dd93c97118",
        },
        {
          Effect: "Allow",
          Action: ["sts:AssumeRole", "sts:TagSession"],
          Resource: githubActionsWorkloadsRole.arn,
        },
        {
          Effect: "Allow",
          Action: [
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:ListRolePolicies",
            "iam:PassRole",
            "iam:CreateOpenIDConnectProvider",
            "iam:DeleteOpenIDConnectProvider",
            "iam:GetOpenIDConnectProvider",
            "iam:ListOpenIDConnectProviders",
          ],
          Resource: "*",
        },
      ],
    },
  },
  { provider: infraProvider }
);

// Policy for workloads deployment (S3, CloudFront, Route53, ACM, etc.)
new aws.iam.RolePolicy(
  "workloadsDeploymentPolicy",
  {
    role: githubActionsWorkloadsRole.id,
    policy: {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Action: ["s3:*", "cloudfront:*", "route53:*", "acm:*"],
          Resource: "*",
        },
      ],
    },
  },
  { provider: workloadsProvider }
);
