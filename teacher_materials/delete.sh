#!/bin/bash -eux

MONIKER=$1

# TODO: We need to add the EksAdmins role to the aws-auth
# configmap before this will work.  We'll also have to 
# figure out how to `aws sts assume-role` when we're
# deleting clusters.

# Delete the EKS cluster
# eksctl delete cluster ${MONIKER}-k8s

# Detach all user policies from your service account
for POLICY_ARN in $(
  aws iam list-attached-user-policies \
    --user-name ${MONIKER}-i2do-k8s-svc-account | \
    jq -r .AttachedPolicies[].PolicyArn
  ); do
    aws iam detach-user-policy \
      --user-name ${MONIKER}-i2do-k8s-svc-account \
      --policy-arn ${POLICY_ARN}

    # Delete your service account's IAM policy
    aws iam delete-policy \
    --policy-arn ${POLICY_ARN}
done


# Remove all access keys from your service account
for ACCESS_KEY in $(
  aws iam list-access-keys \
    --user-name ${MONIKER}-i2do-k8s-svc-account | \
    jq -r .AccessKeyMetadata[].AccessKeyId
  ); do
    aws iam delete-access-key \
      --user-name ${MONIKER}-i2do-k8s-svc-account \
      --access-key-id ${ACCESS_KEY}
done

# Delete your service account
aws iam delete-user --user-name ${MONIKER}-i2do-k8s-svc-account

