#!/bin/bash -eu

PASSWD=$(pwgen -y 16 1)

aws iam create-user --user-name ${1}

aws iam create-login-profile \
    --user-name ${1} \
    --password=${PASSWD} \
    > /dev/null

aws iam attach-user-policy \
    --user-name ${1} \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
    > /dev/null

echo ${1}
echo ${PASSWD}
echo "https://sofreeus.signin.aws.amazon.com/console"