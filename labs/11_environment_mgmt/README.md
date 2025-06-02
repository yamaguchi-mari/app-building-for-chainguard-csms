# Environment Management

What this unit demonstrates:
- Using the [Environments](https://docs.gitlab.com/ee/ci/environments/) feature within GitLab
- Deploying multiple "stacks" in our Kubernetes cluster

What this unit does not demonstrate:
- Isolating environments to different AWS accounts
- Dedicating a Kubernetes cluster per environment
- Managing environments with namespaces within a single cluster

---

### It's all in the YAML

The updated `.gitlab-ci.yml` below...

1. Uses a template job to create multi-stage deploys
    - Note the addition of custom stages
    - Both `.render_manifest` and `.deploy_webserver` have been updated to start with `.` which means they won't run by themselves
    - `render_dev` and `render_prod`
      - Are both instantiations of the `.render_manifest` job (via `extends`)
      - They include custom variables to prepare them for their respective environments
    - `deploy_dev` and `deploy_prod`
      - Are both instantiations of the `.deploy_webserver` job (via `extends`)
      - Includes a `$CLUSTER` variable that would allow us to deploy to different dev/test/prod clusters in the future.
2. `deploy_dev` and `deploy_prod` add the `environment` key to the deploy jobs
    - This tells GitLab to populate the `MyWebServer --> Operations --> Environments` page
      ```shell
      echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/environments"
      ```
    - Provides version history when you click in to an environment
    - Enables one-click rollbacks
    - You can optionally edit an environment to add the URL

### Try it Out

Update your `.gitlab-ci.yml`:

```yaml
# Add stages beyond the defaults
stages:
  - build
  - prepare-dev
  - deploy-dev
  - prepare-prod
  - deploy-prod

# Same build and test as before
build_and_test_webserver:
  stage: build
  image: docker:stable
  services:
    - docker:dind
  script:
    - docker build -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA} -t ${CI_REGISTRY_IMAGE}:latest .
    - docker run -d -p8080:80 --name mywebserver ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
    - docker logs mywebserver
    - apk add curl
    - curl docker:8080
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
  variables:
    CLUSTER: ${MACGUFFIN}-k8s

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
  when: manual
  variables:
    CLUSTER: ${MACGUFFIN}-k8s
```

Commit and push your changes:

```bash
git add -A
git commit -m 'per-environment deploys'
git push
```

Examine your pipeline:

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
```

- Note the additional jobs/stages
- Because of the `when: manual` in the job definition, `deploy_prod` will not run automatically

Visit the `MyWebServer --> Operations --> Environments` page in your repo

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/environments"
```

Examine your cluster:

```bash
kubectl get deploy,svc,ing
```

Examine your environments

```bash
curl dev.${MACGUFFIN}.introtodevops.com
curl www.${MACGUFFIN}.introtodevops.com
```

---

### Make Some Versions!

```shell
# Make a silly version
echo "Version Aardvark" > ~/sfs/mywebserver/html/index.html
git add -A
git commit -m 'Create Version Aardvark'
git push

# Now do another
echo "Version Zebra" > ~/sfs/mywebserver/html/index.html
git add -A
git commit -m 'Create Version Zebra'
git push
```

Go play with your pipelines!  Push either version - or both versions - to production!

The check out the environments.  Try to roll back your Prod environment.

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/environments"
```


---

| Previous: [Everything!](/labs/10_everything) | Next: [Test Gates for Continuous Deployment](/labs/12_test_gates) |
|---:|:---|
