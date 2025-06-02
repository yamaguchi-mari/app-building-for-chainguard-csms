# Manual Deployment to Kubernetes

*By the end of this lab, you will:*

- Launch an nginx webserver on your Kubernetes cluster
- Understand the pain of a manual Kubernetes deploy

---

Save this file as `~/sfs/mywebserver/webserver-manual.yaml`

```shell
touch ~/sfs/mywebserver/webserver-manual.yaml
edit ~/sfs/mywebserver/webserver-manual.yaml
```

```yaml
# The Deployment object expresses the desired state for your app
kind: Deployment
apiVersion: apps/v1
metadata:
  name: mywebserver-dev
  labels:
    app: webserver
    course: introtodevops
    environment: dev
spec:
  # Specify how many pods of this type k8s will run in this deployment
  replicas: 1
  selector:
    matchLabels:
      app: webserver
      course: introtodevops
      environment: dev
  template:
    metadata:
      labels:
        app: webserver
        course: introtodevops
        environment: dev
    spec:
      # Specify the container(s) to run inside each pod.
      containers:
        - name: webserver
          image: nginx
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
  name: mywebserver-dev
  labels:
    app: webserver
    course: introtodevops
    environment: dev
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
    environment: dev
---
# Create an ingress object to connect the pod(s) to the Ingress Controller we created in the previous lab
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: mywebserver-dev
  labels:
    app: webserver
    course: introtodevops
    environment: dev
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: mywebserver
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: mywebserver-dev
            port:
              name: svcport
```
---

This manifest describes the following structure:

![image](gke-cluster-logical-view.png?)

---

Labels and Selectors are critical to the basic understanding of the deploy/replicaset/pod/service interfaces:

![image](k8s-labels-selectors.png?)

---

#### Manual Deploy

Double-check that you're still on the right cluster

```bash
kubectl get nodes
```

Apply your manifest to your cluster

```bash
kubectl apply -f ~/sfs/mywebserver/webserver-manual.yaml
```

This should output
```
deployment.apps/mywebserver-dev created
service/mywebserver-dev created
ingress.networking.k8s.io/mywebserver-dev created
```

See what it created:

```bash
kubectl get deployment,service,ingress
```

Or the shorter version:

```bash
kubectl get deploy,svc,ing
```

Regardless, you should see something like this:

```
NAME                                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/mywebserver-dev   1         1         1            1            2m

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes        ClusterIP   10.70.0.1      <none>        443/TCP         2m
service/mywebserver-dev   NodePort    10.70.12.123   <none>        80:31219/TCP    2m

NAME              CLASS    HOSTS         ADDRESS                                                                         PORTS   AGE
mywebserver-dev   <none>   mywebserver   a607460a57dbd402bb9c04c544e9e49e-a1c428ce49c127fc.elb.us-west-2.amazonaws.com   80      4m41s
```

Test it!

```bash
curl \
  -H "Host: mywebserver" $(
    kubectl \
    -n ingress-nginx \
    get svc ingress-nginx-controller \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  )
```

This sends a custom host header to an IP we programmatically derive from our cluster.  Since we don't want to to that every time, we need to leverage the DNS configuration we implemented at the end of the last lab.

---

### Using a Hostname

`edit ~/sfs/mywebserver/webserver-manual.yaml` and find this line:

```yaml
    - host: mywebserver
```

and replace it with your `dev.$MACGUFFIN.introtodevops.com` DNS name.  (**Make sure you don't change the indentation.**)

Examples:

```yaml
    - host: dev.rug.introtodevops.com
    - host: dev.ring.introtodevops.com
    - host: dev.godot.introtodevops.com
    - host: dev.woodchuck.introtodevops.com
```

Save your `webserver-manual.yaml` and re-apply your changes:

```bash
kubectl apply -f ~/sfs/mywebserver/webserver-manual.yaml
```

Make sure your change is implemented:

```bash
kubectl get ing mywebserver-dev
```

Should now show your updated host.  We're going to be using the following command to extract the host directly in the next step:

```bash
kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}'
```

Test it the easy way:

If you're a GUI-centric user, you should be able to open your webpage in a browser:

```bash
## Windows and MacOS ##
open http://$(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
## Linux ##
xdg-open http://$(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
## CloudShell ##
# (click the resulting output)
echo http://$(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
```

Note this is just a fancy way of opening dev.$MACGUFFIN.introtodevops.com in a browser!

You should see the **nginx** welcome page.  ("**Welcome to nginx! ...**")

If you're awesome like your teacher, you'll eschew the browser for anything that can be done in the terminal, like this:

```bash
curl $(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
## or, for example... ##
curl dev.$MACGUFFIN.IntroToDevOps.com
```

You should see something like this:

```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

---

| Previous: [AWS Kubernetes](/labs/05_aws_kubernetes) | Next: [K8s to GitLab Auth](/labs/07_auth_kubernetes_to_gitlab) |
|---:|:---|
