# Test Gates for Continuous Deployment

### Pre-Work:

```shell
edit ~/sfs/mywebserver/deploy/templates/webserver.yaml
```

**Look for `pathType: Exact` and change this to `pathType: Prefix`**

---

This iterates on our pipeline again.  We're adding an additional stage to test our deploy in the `dev` environment.  If this is successful, we automatically deploy to `prod`.

```yaml
# Add stages beyond the defaults
stages:
  - build
  - prepare-dev
  - deploy-dev
  - test-dev
  - prepare-prod
  - deploy-prod
  - test-prod

# Adds a version endpoint
build_and_test_webserver:
  stage: build
  image: docker:stable
  services:
    - docker:dind
  script:
    - echo ${CI_COMMIT_SHORT_SHA} > html/version.html
    - docker build -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA} -t ${CI_REGISTRY_IMAGE}:latest .
    - docker run -d -p8080:80 --name mywebserver ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
    - docker logs mywebserver
    - apk add curl
    - curl docker:8080
    - curl docker:8080/version.html | grep ${CI_COMMIT_SHORT_SHA}
    - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN registry.gitlab.com
    - docker push ${CI_REGISTRY_IMAGE}
    - echo ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}

# Template job to render manifests
.render_manifest:
  image: dtzar/helm-kubectl
  artifacts:
    paths:
      - manifest.yaml
  script:
    - >
      helm template \
        --set image=${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA} \
        --set host=${INGRESS_HOST} \
        --set environment=${K8S_ENVIRONMENT} \
        deploy > manifest.yaml

# Template job to deploy manifests
.deploy_webserver:
  image: aayore/aws-kubectl
  before_script:
    - aws eks update-kubeconfig --name ${CLUSTER} --region ${AWS_DEFAULT_REGION}
  script:
    - kubectl apply -f manifest.yaml

prepare_dev:
  extends: .render_manifest
  stage: prepare-dev
  variables:
    INGRESS_HOST: dev.${MACGUFFIN}.introtodevops.com
    K8S_ENVIRONMENT: dev

deploy_dev:
  extends: .deploy_webserver
  stage: deploy-dev
  environment: dev
  dependencies:
    - prepare_dev
  variables:
    CLUSTER: ${MACGUFFIN}-k8s

test_dev:
  stage: test-dev
  image: curlimages/curl:latest
  dependencies: []
  variables:
    INGRESS_HOST: dev.${MACGUFFIN}.introtodevops.com
  script:
    - |
      for COUNTER in $(seq 1 30)
      do sleep 5
      if curl -s ${INGRESS_HOST}/version.html | grep ${CI_COMMIT_SHORT_SHA}; then exit 0; fi
      done
      exit 1

prepare_prod:
  extends: .render_manifest
  stage: prepare-prod
  variables:
    INGRESS_HOST: www.${MACGUFFIN}.introtodevops.com
    K8S_ENVIRONMENT: prod

deploy_prod:
  extends: .deploy_webserver
  stage: deploy-prod
  environment: prod
  dependencies:
    - prepare_prod
  variables:
    CLUSTER: ${MACGUFFIN}-k8s

test_prod:
  stage: test-prod
  image:
    name: mesosphere/hey
    entrypoint:
      - /bin/sh
      - -c
  dependencies: []
  variables:
    INGRESS_HOST: www.${MACGUFFIN}.introtodevops.com
    GIT_STRATEGY: none
  script:
    - hey -z 30s -c 100 -disable-keepalive -t 3 http://${INGRESS_HOST}
```

---

### More Abstraction (Try This At Home)

Maintaining these variables in multiple places in a file may not be ideal for your environment.  Especially when some of the variables (e.g. `CLUSTER`, `REGION`, and `PROJECT`) may be widely-used across projects.

If you have a **group** configured in GitLab (e.g. https://gitlab.com/sofreeus), you might set the following group-wide:

```yaml
DEV_CLUSTER: dev-cluster-1
DEV_REGION: us-west-2
PROD_CLUSTER: prod-cluster-1
PROD_REGION: us-east-1
```

Within your **project**, you could set these:

```yaml
DEV_INGRESS_HOST: dev.${MACGUFFIN}.introtodevops.com
DEV_K8S_ENVIRONMENT: dev
PROD_INGRESS_HOST: www.${MACGUFFIN}.introtodevops.com
PROD_K8S_ENVIRONMENT: prod
```

Now you can configure your deploy jobs to look like this:

```yaml
deploy_dev:
  extends: .deploy_webserver
  stage: deploy-dev
  variables:
    CLUSTER: ${DEV_CLUSTER}
    AWS_DEFAULT_REGION: ${DEV_REGION}
    INGRESS_HOST: ${DEV_INGRESS_HOST}
    K8S_ENVIRONMENT: ${DEV_K8S_ENVIRONMENT}
  environment: dev

deploy_prod:
  extends: .deploy_webserver
  stage: deploy-prod
  variables:
    CLUSTER: ${PROD_CLUSTER}
    AWS_DEFAULT_REGION: ${PROD_REGION}
    INGRESS_HOST: ${PROD_INGRESS_HOST}
    K8S_ENVIRONMENT: ${PROD_K8S_ENVIRONMENT}
  environment: prod
```

This makes your `.gitlab-ci.yml` - maybe more importantly the individual jobs - more portable and reusable.  This means you could start playing with the [include](https://docs.gitlab.com/ee/ci/yaml/#include) directive...

---

| Previous: [Environment Management](/labs/11_environment_mgmt) | Next: [Horizontal Pod Autoscaler and Load Testing](/labs/13_load_and_hpa) |
|---:|:---|
