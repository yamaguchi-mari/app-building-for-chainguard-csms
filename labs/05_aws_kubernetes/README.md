# Build an AWS EKS Cluster with Fargate

Infrastructure the easy way: Kubernetes

*By the end of this lab, you will:*

- Build a Kubernetes cluster from the CLI using `eksctl`
- Delete and rebuild your cluster
- Run some basic `kubectl` commands
- Install the Nginx ingress controller on your cluster

---

### Fargate?  EKS?

*EKS* - or *Elastic Kubernetes Service* - is a managed Kubernetes platform on AWS.

*Fargate* is a back-end for Kubernetes that reduces your managerial/operational concerns with EKS.

Fargate+EKS is very similar to Google's *GKE*, or *Google Kubernetes Engine*.

You can think of Kubernetes as a software-defined everything for your application.  Compute, network, storage, etc. can all be defined in a single portable manifest for your application.  This means your application can run in any number of different locations or cloud providers with minimal changes.

---

Recommended working directory:

```bash
mkdir -p ~/sfs/work-dir/cloud-infrastructure
cd ~/sfs/work-dir/cloud-infrastructure
```

---

### Install the AWS CLI

```bash
# Install the AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i ~/.local/aws-cli -b ~/.local/bin

# Install the EKS CLI
curl \
  --silent \
  --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp

sudo mv /tmp/eksctl ~/.local/bin

# CloudShell may not have included ~/.local/bin in your path
# if it didn't exist when you logged in.  Since it does now,
# we're going to source our profile again.
source ~/.profile
```

Verify your installations:

```bash
aws --version
eksctl version
```
 <!--
If you're seeing `-bash: aws: command not found`, `~/.local/bin/` may not have existed at the time you logged in to Google Cloud Shell, which would have prevented it from being added to your binary search path.

To confirm that problem, run this:

```bash
# Verify that your local private binary dir is set in your profile
grep PATH ~/.profile

# You should see something like
#    PATH="$HOME/.local/bin:$PATH"

# Re-read your profile (this seems to be an issue with Cloud Shell sometimes)
source ~/.profile

# if it still does not work after the above, let your instructor know, you may need to reset your cloudshell
```
-->
**If these commands are not working, let your instructor know!**

---

### Create your Access Key

Your instructional team should have provided you with an AWS account.  If you don't have credentials, speak up now!

1. Log in to [https://sofreeus.signin.aws.amazon.com/console](https://sofreeus.signin.aws.amazon.com/console) (this link should pre-populate the account alias field with "sofreeus")
2. Use the drop-down menu at the top-right of the console to select `Oregon`.  This is the `us-west-2` region (which is cheaper than the `us-east-*` regions).
3. Use the search function at the top to navigate to `IAM`
4. Naviate to `Users` --> Your Username --> `Security Credentials`
5. Under `Access Keys`, select the `Create Access Key` button
  - This will show your key **once**.
  - **Leave this open for the next step.**
  - But if you close it, you can just delete your key and make a new one.

---

### Configure the CLI

Configure the AWS CLI with your AWS Access and Secret Keys.

Type `us-west-2` when prompted for a region.

```bash
# Configure the AWS CLI with your credentials
aws configure

# This should show your IAM account information
aws iam get-user
```

---

### Launch a Kubernetes Cluster From the CLI

A Kubernetes cluster consists of two main pieces:

*Control Plane* - This is the brain and state of your cluster.  It stores the configuration and uses the *nodes* to maintain the state of things.  If this goes away, you have a problem.

*Nodes* - These are dumb workers.  They take instruction from the control plane.  You can remove all nodes from your cluster, and you'll only have a temporary problem.  When you add nodes back (with the proper configuration), the *control plane* will ensure the expected state is reestablished.

We're going to use WeaveWorks' tool for EKS called `eksctl` to build our cluster.

```bash
# Provision the control plane
# This takes several (15-25) minutes.  Take a bathroom break or stretch your legs.
# For insight into what this is doing, you can navigate to the CloudFormation
# service in the AWS Console...
eksctl create cluster \
    --name ${MACGUFFIN}-k8s \
    --region us-west-2 --fargate

# Provision nodes for your cluster
eksctl create nodegroup \
  --cluster ${MACGUFFIN}-k8s \
  --region us-west-2 \
  --name my-mngd-nodegroup \
  --node-type t3.micro \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# Install Amazon's metrics server for EKS
METRIC_SERVER_MANIFEST_URL=https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -f ${METRIC_SERVER_MANIFEST_URL}
```

Review the output of these commands carefully.  Errors are non-obvious.

##### Troubleshooting a Common Issue

If the last command gives you an error, try this:

```shell
# Check to see if your ~/.kube/config was populated (eksctl *should* have done this)
cat ~/.kube/config

# If your kubeconfig file is empty, use this AWS command to populate it:
aws eks --region us-west-2 update-kubeconfig --name ${MACGUFFIN}-k8s
```

---

## Delete a Cluster

If you want, you can delete your cluster cluster (and managed nodegroup) and make a new one.  It's pretty easy (and scriptable!) when you're using command line tooling.

```bash
# Delete your EKS cluster
eksctl delete cluster --name ${MACGUFFIN}-k8s --region us-west-2
```

---

## `kubectl`

`kubectl` - pronounced "cube see tee ell", "cube control", "cube cuddle", or "cue Beck Tull" is the Kubernetes Control CLI tool.

[The definitive pronunciation guide](https://www.youtube.com/watch?v=2wgAIvXpJqU)

When you use `eksctl` to create a cluster, it creates a `~/.kube/config` file that stores your connection metadata.

Verify that your cluster is up and that `kubectl` is working:

```bash
# Loading kubectl command completion will make kubectl more discoverable
# and you faster
source <(kubectl completion bash)

# Show the available cluster configurations
kubectl config get-contexts

# Show node information
kubectl get nodes -o wide

# Examine your kube config
cat ~/.kube/config
```

---

## Kubernetes Nginx Ingress

We can configure the Nginx Ingress on our cluster with a single command:

```bash
# https://kubernetes.github.io/ingress-nginx/deploy/#aws
MANIFEST_URL=https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/aws/deploy.yaml
kubectl apply -f ${MANIFEST_URL}

```

This command creates a number of new objects on your Kubernetes cluster.  A brief summary will be shown in the terminal.

Next, we want to put your cluster in DNS.  Run this command and watch the output:

```bash
watch kubectl -n ingress-nginx get service
```

When `EXTERNAL-IP` changes from `<pending>` to an IP (or FQDN) for the ingress, type Ctrl+C to exit the `watch` command.  Then work with your teacher to complete the configuration in DNS.

Ultimately, we're going to create a wildcard record for your cluster's ingress.  This means that something like `*.$YOURNAME.IntroToDevOps.com` will route all traffic to the `$YOURNAME`'s Kubernetes cluster.

---

| Previous: [Continuous Integration](/labs/04_continuous_integration) | Next: [Manual Deployment](/labs/06_manual_deployment) |
|---:|:---|
