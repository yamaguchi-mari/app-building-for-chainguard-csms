# Horizontal Pod Autoscaler and Load Testing

In this lab, you will learn how to:
- Run Docker containers instead of downloading/installing software
- Perform basic load testing
- Set limits on Kubernetes deploys
- Develop manifest objects using `kubectl`
- Scale pods automatically

---

### Installing software?

Remember how we defined Docker images (and containers) as self-contained applications?  This means that we can run an app in a container without having to install anything.

We're going to use [hey](https://github.com/rakyll/hey) to load test our web server.  But instead of installing the binary (and all its dependencies) on our Cloud Shell machine, we're just going to use the Docker image.  See how below.

---

### Basic "Local" Load Testing

First, make sure your webserver is running in your Cloud Shell:

```shell
docker ps

# If you need them, here are the commands to
# stop, remove, and restart your container
docker stop mywebserver
docker rm mywebserver
docker run --detach -p 8080:80 --name mywebserver webserver
```

Now spin up the `hey` container.  We're going to run 100 concurrent workers.  They will send requests over and over for 30 seconds with a 3 second timeout per request.  The following command will sit quietly for 30 seconds while it's running:

```shell
docker run \
  --net=host \
  --rm \
  mesosphere/hey \
    -z 30s \
    -c 100 \
    -disable-keepalive \
    -t 3 \
    http://localhost:8080
```

Then it should output something like this:

```
Summary:
  Total:        30.5518 secs
  Slowest:      2.0467 secs
  Fastest:      0.0064 secs
  Average:      0.5531 secs
  Requests/sec: 93.8407
  Total data:   24937 bytes
  Size/request: 11 bytes

Response time histogram:
  0.006 [1]     |
  0.210 [1666]  |∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
  0.414 [0]     |
  0.619 [0]     |
  0.823 [0]     |
  1.027 [0]     |
  1.231 [0]     |
  1.435 [0]     |
  1.639 [0]     |
  1.843 [0]     |
  2.047 [600]   |∎∎∎∎∎∎∎∎∎∎∎∎∎∎

Latency distribution:
  10% in 0.0162 secs
  25% in 0.0194 secs
  50% in 0.0245 secs
  75% in 2.0145 secs
  90% in 2.0279 secs
  95% in 2.0325 secs
  99% in 2.0386 secs

Details (average, fastest, slowest):
  DNS+dialup:    0.5373 secs, 0.0002 secs, 2.0224 secs
  DNS-lookup:    0.5344 secs, 0.0000 secs, 2.0153 secs
  req write:     0.0005 secs, 0.0000 secs, 0.0128 secs
  resp wait:     0.0148 secs, 0.0003 secs, 0.0369 secs
  resp read:     0.0004 secs, 0.0000 secs, 0.0129 secs

Status code distribution:
  [200] 2267 responses

Error distribution:
  [600] Get http://localhost:8080: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```

Because our Cloud Shell resources are fairly limited, you should see some timeout errors.  For a production environment, we could use this approach to tune resource requirements for our app.

---

### Kubernetes Resource Limits

Kubernetes provides an easy way to manage [resources](http://blog.kubecost.com/blog/requests-and-limits/) on your cluster.  We're going to provide the following limits to our webserver:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

You can think of `requests` as both a minimum - a pod will fail to start if the cluster cannot meet the `requests` - and a guarantee - the pod will always have dedicated rights to these amounts of resources.

`Limits` are the maximums.  Kubernetes will throttle a pod if it tries to consume more than its CPU limit.  Any pod exceeding its memory limit will be killed if there is any memory contention on the cluster.

We're going to use hard-coded values today, but you can make them parameters the same way as the image, environment, and host.  This makes it easy to allocate different quotas in different environments.

Update your Helm template to add the resource limits:

```shell
edit ~/sfs/mywebserver/deploy/templates/webserver.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mywebserver-{{ .Values.environment }}
  labels:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
spec:
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
      containers:
        - name: webserver
          image: {{ .Values.image }}
          imagePullPolicy: IfNotPresent
          ports:
            - name: default
              containerPort: 80
              protocol: TCP
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
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
  selector:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
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
        pathType: Prefix
        backend:
          service:
            name: mywebserver-{{ .Values.environment }}
            port:
              name: svcport

```

Commit and ship your changes:

```shell
git add -A
git commit -m 'add resource requests and limits'
git push
```

Go check your pipelines:

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
```

When your deploy is complete, examine the pod for its resource requests and limits.  We're going to use label selectors, because we don't really know the pod name:

```shell
# Show all pods and their labels
kubectl get pod --show-labels

# Use a unique set of labels to identify a pod
# Note that this label set will not be unique if we scale up
kubectl describe pod -l app=webserver,environment=dev

# To get just the resource block we can output to JSON and use jq
kubectl get deploy mywebserver-dev -o json | \
  jq .spec.template.spec.containers[0].resources
```

---

### Manual Load Testing in Kubernetes

This is the command we used to run against our "local" webserver in our Cloud Shell environment:

```shell
docker run \
  --net=host \
  --rm \
  mesosphere/hey \
    -z 30s \
    -c 100 \
    -disable-keepalive \
    -t 3 \
    http://localhost:8080
```

We can run a very similar command to do the same thing in Kubernetes.  In order to differentiate between our `hey` container and our Kubernetes pod, we're going to name the pod `loadtest`.  We're using `http://mywebserver-dev` instead of our public FQDN becuase we're using cluster-internal DNS to access the `mywebserver-dev` service without leaving the cluster.

```shell
kubectl run loadtest \
  --image=mesosphere/hey \
  --restart=Never \
  -- \
  -z 30s \
  -c 100 \
  -disable-keepalive \
  -t 3 \
  http://mywebserver-dev
```

You'll notice that this command goes into the "background."  It creates a K8s pod and returns immediately.

```shell
# Look for the "Completed" status:
kubectl get pod

# Examine the pod logs:
kubectl logs loadtest

# Delete the pod left over from this manual run:
kubectl delete pod loadtest
```

---

### Horizontal Pod Autoscalers and...
### Manifest Development Using Kubectl

You can manually create Kubernetes objects using `kubectl`.  We did this with our Docker registry credential secret, but you don't generally want to create things manually.  You want them automated, repeatable, and consistent.  But there are two flags - `--dry-run=client` and `-o yaml` - that allow us to mock out objects we can then add to our manifest or helm chart!

```shell
kubectl autoscale deployment mywebserver-dev \
  --cpu-percent=10 \
  --min=1 \
  --max=4 \
  --dry-run=client \
  -o yaml
```

This should generate:

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: null
  name: mywebserver-dev
spec:
  maxReplicas: 4
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mywebserver-dev
  targetCPUUtilizationPercentage: 10
status:
  currentReplicas: 0
  desiredReplicas: 0
```

We're going to make some minor tweaks.  We don't need the `status` section, and we're going to use the `{{ .Values.environment }}` that we use elsewhere in our Helm chart.

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: null
  name: mywebserver-{{ .Values.environment }}
spec:
  maxReplicas: 4
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mywebserver-{{ .Values.environment }}
  targetCPUUtilizationPercentage: 10
```

Making sure to use the YAML document separator (`---`), add the HPA to our Helm chart:

```shell
edit ~/sfs/mywebserver/deploy/templates/webserver.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mywebserver-{{ .Values.environment }}
  labels:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
spec:
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
      containers:
        - name: webserver
          image: {{ .Values.image }}
          imagePullPolicy: IfNotPresent
          ports:
            - name: default
              containerPort: 80
              protocol: TCP
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
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
  selector:
    app: webserver
    course: introtodevops
    environment: {{ .Values.environment }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
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
        pathType: Prefix
        backend:
          service:
            name: mywebserver-{{ .Values.environment }}
            port:
              name: svcport
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: null
  name: mywebserver-{{ .Values.environment }}
spec:
  maxReplicas: 4
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mywebserver-{{ .Values.environment }}
  targetCPUUtilizationPercentage: 10
```

When your pipeline has completed, check for your new Horizontal Pod Autoscaler:

```shell
kubectl get hpa
```

Let's run our load test again!  Note that we're extending the length of the test this time:

```shell
# Delete the leftover pod from the last run
kubectl delete pod loadtest

# Run the load test for 2 minutes
kubectl run loadtest \
  --image=mesosphere/hey \
  --restart=Never \
  -- \
  -z 2m \
  -c 100 \
  -disable-keepalive \
  -t 3 \
  http://mywebserver-dev

# Watch your pods to see what happens:
watch kubectl get pod
```

When the run has finished, check the logs of your load test again:

```shell
# Examine the pod logs:
kubectl logs loadtest

# Delete the pod left over from this manual run:
kubectl delete pod loadtest
```

---

| Previous: [Test Gates for Continuous Deployment](/labs/12_test_gates) |  
|:---:|
