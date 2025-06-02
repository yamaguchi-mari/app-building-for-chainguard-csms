## Cleanup

This is a list of things we created in this course.

GitLab:
- MyWebserver repository
- SSH key
- Access token

Amazon:

```shell

# Delete the EKS cluster
eksctl delete cluster ${MACGUFFIN}-k8s

# Detach all user policies from your service account
for POLICY_ARN in $(
  aws iam list-attached-user-policies \
    --user-name ${MACGUFFIN}-i2do-k8s-svc-account | \
    jq -r .AttachedPolicies[].PolicyArn
  ); do
    aws iam detach-user-policy \
      --user-name ${MACGUFFIN}-i2do-k8s-svc-account \
      --policy-arn ${POLICY_ARN}

done

# Delete your service account's IAM policy
aws iam delete-policy \
  --policy-arn $(
      jq -r '.Policy.Arn' ~/sfs/work-dir/cloud-infrastructure/policy-output.json
    )

# Remove all access keys from your service account
for ACCESS_KEY in $(
  aws iam list-access-keys \
    --user-name ${MACGUFFIN}-i2do-k8s-svc-account | \
    jq -r .AccessKeyMetadata[].AccessKeyId
  ); do
    aws iam delete-access-key \
      --user-name ${MACGUFFIN}-i2do-k8s-svc-account \
      --access-key-id ${ACCESS_KEY}
done

# Delete your service account
aws iam delete-user --user-name ${MACGUFFIN}-i2do-k8s-svc-account

```


If you want to clean up your GCP Cloud Shell:
- [Reset your Cloud Shell](https://cloud.google.com/shell/docs/resetting-cloud-shell)
- If you ignore it, it'll just turn off.  All your stuff should still be in there, though.
