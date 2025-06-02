# Continuous Integration

*By the end of this lab, you will:*
1. Configure a gitlab pipeline
1. Setup a stage to build, test and push the webserver
1. Define Continuous Integration
1. Explain what _pipeline_, _stage_, _jobs_ and _scripts_ mean in the context of Continuous Integration

Required working directory:

```shell
cd ~/sfs/mywebserver
```

(This is the root of your webserver repository)

---

Most continuous integration platforms start by cloning your repository.  You're then able to run build/test jobs against a clean environment with the latest copy of your (or your developer's) code.  You can accomplish something very similar by creating a new directory on your machine and cloning a new copy of your repo - which can be a really good way to test quickly and troubleshoot errors with your CI system.

---


GitLab has [Pipelines](https://docs.gitlab.com/ce/ci/pipelines.html) that perform continuous integration tasks for us.  

To use pipelines, we just need to create a `.gitlab-ci.yml` file.  There are [a lot of options](https://docs.gitlab.com/ce/ci/yaml/README.html) for this file, but we're just going to cover some basics.

---

### Terminology

*pipeline* - A collection of stages, jobs, and scripts that will be run when a new commit is checked in to the repository.
*stages* - Will be run sequentially.  
*jobs* - Will be run in parallel, within the confines of each stage.  
*scripts* - Will be run sequentially within the confines of each job.  

---

![image](gitlab_pipelines.png?)

### A Basic GitLab CI Pipeline

Save the following as `.gitlab-ci.yml` in your webserver project at `~/sfs/mywebserver/.gitlab-ci.yml`

```shell
touch ~/sfs/mywebserver/.gitlab-ci.yml
edit ~/sfs/mywebserver/.gitlab-ci.yml
```

Add these contents:

```yaml
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
    - curl docker:8080 # <------------ This is the (overly simplified) test!
    - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN registry.gitlab.com
    - docker push ${CI_REGISTRY_IMAGE}
    - echo Published ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
    - echo Published ${CI_REGISTRY_IMAGE}:latest
```

#### Breakdown

We're telling GitLab to build our project inside the `docker:stable` container.  This job requires a Docker service in the background, so we're running `docker:dind` (dind = Docker-in-Docker) as a service.

```yaml
image: docker:stable
services:
  - docker:dind
```

Stages define dependent steps in the workflow.  Every pipeline has build, test, and deploy stages by default.  In our case, we're going to run the build and the test in the same stage (and job) because otherwise we'd have to publish an untested image.

```yaml
stage: build
```

This is the meat of our pipeline.  We build the image, run it as a container, make sure it's serving a webpage, then push the image to the registry if everything is working.

```yaml
script:
  - docker build -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA} -t ${CI_REGISTRY_IMAGE}:latest .
  - docker run -d -p8080:80 --name mywebserver ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
  - docker logs mywebserver
  - apk add curl
  - curl docker:8080 # <------------ This is the (overly simplified) test!
  - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN registry.gitlab.com
  - docker push ${CI_REGISTRY_IMAGE}
  - echo Published ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}
  - echo Published ${CI_REGISTRY_IMAGE}:latest
```

The `docker logs mywebserver` line above is a very helpful command that will proactively add troubleshooting information to the logs (more on that in a second).

---

### Kicking it Off

After you save your `.gitlab-ci.yml` file, you'll want to commit your changes to GitLab:

```bash
cd ~/sfs/mywebserver
git status

# Stage all new/changed files in the 'mywebserver' repo
git add .

# Make a commit for the Dockerfile
git commit -m 'add container definition' Dockerfile

# Create a commit for the site
git commit -m 'add site' html/

# Create a commit for the CI configuration
git commit -m 'add CI' .gitlab-ci.yml

# Push all of these commits to the remote repo on gitlab.com
git push
```
![image](gitlab-ci-1.png?)

![image](gitlab-ci-2.png?)

> aayore (6:53 PM) - if you try to teach students that it's actually a **gitlab runner running docker with docker in docker building a docker image** ... you're going to extra-confuse people and run out of time.

---

### Checking Progress

Go to [GitLab](https://gitlab.com) and navigate to your project

Should be: `https://gitlab.com/<your_user_name>/mywebserver`

You can also generate the URL from your `repo_metadata.json` file (and the knowledge of the `pipelines` web path):

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
```

If you're manually navigating, click the `Pipelines` link under `CI/CD` on the left-side menu

If you don't see anything here, make sure you saved your `.gitlab-ci.yml` in the correct location, added, committed, and pushed your repo.

You should see a `pending` or `running` (or maybe `passed` or `failed`) pipeline

1. On the main Pipelines page, click on the status icon to see the pipeline details
2. On the details page, click on the status icon to get information about the build (job) status
3. You should see the output from your job on this page
  - This is where you can see the `docker logs ...` output
  - Take note of the output of the `${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}` command.
4. Under `Packages` in the left-side menu, click `Container Registry` to view your image in the GitLab registry

---

## Checkpoint

**This is a critical point.  If things don't look right at this point, review all the steps and ask for help.  You'll want everything working before you proceed to the next step.**

Make a minor change to your webserver:

```bash
echo This is my second web page > html/index.html
git add html/index.html
git commit -m 'second webpage'
git push
```

Check again to see that your change is building and testing again in your CI pipeline!

![image](pipelines.png?)

---

### Other Tools/Resources

- [GitLab](https://docs.gitlab.com/ce/ci/yaml/README.html) and [Gitlab Variables](https://docs.gitlab.com/ee/ci/variables/)
- [CircleCI](https://circleci.com/docs/getting-started/)  
- [Docker-CI](http://docker-ci.org/documentation)  
- [Jenkins](https://jenkins.io/doc/)  
- [Travis CI](https://docs.travis-ci.com/user/getting-started/)  

---

_Continuous Integration_ is a software development practice where members of a team integrate their work frequently, usually each person integrates at least daily - leading to multiple integrations per day. Each integration is verified by an automated build (including test) to detect integration errors as quickly as possible. Many teams find that this approach leads to significantly reduced integration problems and allows a team to develop cohesive software more rapidly.

-- Martin Fowler

---

| Previous: [Webserver](/labs/03_webserver) | Next: [AWS Kubernetes](/labs/05_aws_kubernetes) |
|---:|:---|
