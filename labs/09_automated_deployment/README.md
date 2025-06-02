# (Better) Automated Deployment

*By the end of this lab, you will:*

- Have more control over your deployments
- See how to create more extensible deployment templates with Helm

---

If we use the `latest` tag (`mywebserver:latest`) for our deploys this could cause problems:

1. When troubleshooting, we don't really know which version of our app we're running.
2. If a Kubernetes node crashes, its replacement could pull a newer version of the app.
3. Without forcing a `docker pull`, Kubernetes might not update as expected.  (Did you notice this in the last lab?)

---

### Required Working Directory

```shell
cd ~/sfs/mywebserver
```

#### Pre-Start Cleanup

Clean up your manual deploy, service, and ingresses with

```shell
# Remove our webserver stuff
kubectl delete deploy,svc,ing mywebserver-dev

# Verify that it's gone (THIS SHOULD ERROR)
curl $(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
```

### Helm Chart & Template

Create the directory structure for a Helm chart

```shell
mkdir -p ~/sfs/mywebserver/deploy/templates
```

Save the following chart metadata at `~/sfs/mywebserver/deploy/Chart.yaml`

```shell
touch ~/sfs/mywebserver/deploy/Chart.yaml
edit ~/sfs/mywebserver/deploy/Chart.yaml
```

```yaml
apiVersion: v1
appVersion: "1.0"
description: Web Server Deploy Template
name: mywebserver
version: 1.0.0
```

Save the following at `~/sfs/mywebserver/deploy/templates/webserver.yaml`.  (We'll examine the important bits in the next step.)

```shell
touch ~/sfs/mywebserver/deploy/templates/webserver.yaml
edit ~/sfs/mywebserver/deploy/templates/webserver.yaml
```

```yaml
# The Deployment object expresses the desired state for your app
kind: Deployment
apiVersion: apps/v1
metadata:
  name: mywebserver-{{ .Values.environment }}
  labels:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
spec:
  # Specify how many pods of this type k8s will run in this deployment
  replicas: 1
  selector:
    matchLabels:
      app: webserver
      course: introtodevops
      environment: {{ .Values.environment }}
  template:
    metadata:
      labels:
        app: webserver
        course: introtodevops
        environment: {{ .Values.environment }}
    spec:
      imagePullSecrets:
        - name: regcred
      # Specify the container(s) to run inside each pod.
      containers:
        - name: webserver
          image: {{ .Values.image }}
          imagePullPolicy: IfNotPresent
          ports:
            - name: default
              containerPort: 80
              protocol: TCP
---
# Configure the app to be used by other apps
kind: Service
apiVersion: v1
metadata:
  name: mywebserver-{{ .Values.environment }}
  labels:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: default
      protocol: TCP
      name: svcport
  # Selects pods to send traffic to by matching selectors to pod labels
  selector:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
---
# Create an ingress object to connect the pod(s) to the Ingress Controller we created in the previous lab
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: mywebserver-{{ .Values.environment }}
  labels:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: {{ .Values.host }}
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: mywebserver-{{ .Values.environment }}
            port:
              name: svcport
```

Examine the differences between the files:

```shell
diff --side-by-side --width=140 webserver-manual.yaml deploy/templates/webserver.yaml
```

Examine the Helm values we've added:

```shell
grep -oe "{{.*}}" deploy/templates/webserver.yaml | sort | uniq
```

You should see

```
{{ .Values.environment }}
{{ .Values.host }}
{{ .Values.image }}
```

These are the variables we need to feed into the Helm template to generate a working manifest.  The `.Values` object is pretty much just a container for variables.  So `environment`, `host`, and `image` are the required variables.

Manually render and examine the template:

```shell
helm template \
  --set image=MyTestImage \
  --set host=MyTestHost \
  --set environment=MyTestEnvironment \
  deploy
```

Scroll through the output and look for the `MyTest*` values.

### Using Helm With GitLab CI

Update the CI deploy job to use the template.

```shell
edit ~/sfs/mywebserver/.gitlab-ci.yml
```

Replace the previous contents with this:

```yaml
# Add stages beyond the defaults
stages:
  - build
  - prepare-dev
  - deploy-dev

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

# Use a `helm-kubectl` image to render the manifest
render_manifest:
  stage: prepare-dev
  image: dtzar/helm-kubectl
  variables:
    INGRESS_HOST: dev.${MACGUFFIN}.introtodevops.com
    K8S_ENVIRONMENT: dev
  # Collect the manifest from this job
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

deploy_webserver:
  stage: deploy-dev
  image: aayore/aws-kubectl
  variables:
    CLUSTER: ${MACGUFFIN}-k8s
  before_script:
    # Authenticate to the cluster
    # This uses the AWS* variables in the background
    - aws eks update-kubeconfig --name ${CLUSTER} --region ${AWS_DEFAULT_REGION}
  script:
    # The manifest will be collected from the previous job
    - kubectl apply -f manifest.yaml
```

Commit your changes:

```shell
git add -A
git commit -m 'add Helm template'
git push
```

Navigate to your project in GitLab.com and observe the pipeline.

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
```

When the pipeline has completed successfully...

```shell
kubectl get deploy,svc,ing
```

- What do you see?
- What is new/different?

Examine the output of this command:

```shell
kubectl get deploy,svc,ing mywebserver-dev -o yaml
```

- Verify the object names
- Verify the environment labels
- Verify the host name of the ingress
- Verify the container image

Check out your web page:

```shell
curl $(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
```

---

| Previous: [GitLab to K8s Auth](/labs/08_auth_gitlab_to_kubernetes) | Next: [Everything!](/labs/10_everything) |
|---:|:---|
