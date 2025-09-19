import * as aws from "@pulumi/aws";

// We need to use explicit providers so that GitHub can use environment credentials and, locally,
// we can use SSO profiles.

export const infraProvider = new aws.Provider("infraProvider", {
  profile: process.env.CI ? undefined : "infra-provisioning",
  region: "us-east-1",
});

export const workloadsProvider = new aws.Provider(
  "workloadsProvider",
  {
    profile: process.env.CI ? undefined : "workloads-prod",
    region: "us-east-1",
    // In CI, we need to explicitly assume the workloads role from the infra role
    assumeRoles: process.env.AWS_WORKLOADS_ROLE_ARN
      ? [{ roleArn: process.env.AWS_WORKLOADS_ROLE_ARN }]
      : undefined,
  },
  { ignoreChanges: ["assumeRoles"] }
);
