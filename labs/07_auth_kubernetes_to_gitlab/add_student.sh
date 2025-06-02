#!/bin/sh -eux

DEVELOPER=$1

ORGANIZATION=$2

ROLES="roles/resourcemanager.organizationAdmin"
ROLES+=" roles/resourcemanager.projectDeleter"
ROLES+=" roles/resourcemanager.projectCreator"
ROLES+=" roles/billing.admin"
ROLES+=" roles/billing.projectManager"
ROLES+=" roles/billing.user"

for ROLE in ${ROLES}
  do gcloud organizations add-iam-policy-binding ${ORGANIZATION} \
     --member user:${DEVELOPER} --role ${ROLE}
done
