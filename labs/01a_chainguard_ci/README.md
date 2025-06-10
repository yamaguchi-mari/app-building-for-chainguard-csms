# Snyk and CI

*By the end of this lab, you will:*

1. Know how to run a `snyk test` on a local npm project
2. Have the same Snyk test written into a working Gitlab CI file

#### Ensure you are in the correct directory:

```shell
cd ~/Snyky/goof/
```

#### Running local snyk tests on a project

Start with a simple test command:

```shell
snyk test
```

Should fail with error message: `package not found http-signature`

> **Q:** Why?

- Run npm install:

    ```bash
    npm install
    ```

    ```shell
    # should return many package update messages and then something like this at the end:
    ...
    > goof@1.0.1 prepare
    > npm run snyk-protect


    > goof@1.0.1 snyk-protect
    > snyk protect

    Successfully applied Snyk patches


    added 806 packages, and audited 1058 packages in 20s

    1 package is looking for funding
  run `npm fund` for details

    101 vulnerabilities (7 low, 26 moderate, 54 high, 14 critical)
    ```

> **Q:** How many vulnerabilities discovered?

- Run test command again:

    ```shell
    snyk test --json
    ```

    ```shell

    # Result should end with some thing like this:
    ...
    },
  "uniqueCount": 112,
  "projectName": "goof",
  "displayTargetFile": "package-lock.json",
  "path": "/Users/anthonysayre/snyky/goof"
    }

    ```
 
> **Q:** Take note of the **uniqueCount** total... How many vulns discovered this time? Same as the **vulnerabilities count** from the previous step? Npm install command was used last time


#### Monitor Project and Generate a report

- Download snyk-to-html
    ```shell
    npm install snyk-to-html -g
    ```
- Make vars
    ```shell
    export SNYK_ORG_ID=<insert your snyk org id>
    # verify:
    echo $SNYK_ORG_ID
    # Don't move fwd if this var does not return your Snyk org ID
  ```
  

- Monitor the local project (with env vars)
    ```shell
    # Below command is using a custom vars ($SNYK_ORG_ID, $MACGUFFIN, and built-in var from your local env ($HOME)
    snyk monitor --org=$SNYK_ORG_ID --project-name=$HOME:$MACGUFFIN
    ```
- Go to Snyk UI and view the project import results

  ![image](snyk-monitor-ui-local.png?)
- Go back to `z-shell terminal`, test and output results to report artifact
    ```shell
    snyk test --json --org=$SNYK_ORG_ID | snyk-to-html -o snyk_results.html
  ` # View results
    open snyk_results.html
  ```
  
  ![image](snyk-report-results.png?)

> **Q:** How many vulns identified?


### Continuous Integratiton(CI) 


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


![image](../04_continuous_integration/gitlab_pipelines.png?)


### Set up authentication and other variables

- Open the remote copy of your Goof repo in the GitLab UI
  - https://gitlab.com/<GitLab-User>/Goof
- On the left-hand side menu, click **Settings >> CI/CD**
- Find the **Variables** section, click **Expand**
- Get your Snyk PAT and a Snyk Org ID, make a variable in the GitLab repo for both
- Make $SNYK_TOKEN and $SNYK_ORG_ID vars
- When complete it should look like the below:
  - Be sure to toggle 'protected' and 'masked' for the $SNYK_TOKEN var
  - This is like the `.zshrc` (or the `.bashrc`) file! Or like using custom vars with `EXPORT` command
  ![image](gitlab-snyk-vars.png?)

### A Basic GitLab CI Pipeline

In your **z-shell terminal**, 
save the following as `.gitlab-ci.yml` in your repo project at `~/snyky/goof/.gitlab-ci.yml`

```shell
touch ~/snyky/goof/.gitlab-ci.yml
open -a TextEdit ~/snyky/goof/.gitlab-ci.yml
```

Add these contents:

```yaml
# Example Snyk script for GitLab CI/CD Pipeline with Node.js project

dependency_scanning:
  image: node:latest
  stage: test
  script:
    # Install npm, snyk, and snyk-to-html
    - npm install -g npm@latest
    - npm install -g snyk
    - npm install snyk-to-html -g
    # Run snyk help, snyk auth, snyk monitor, snyk test to break build and out report
    - snyk --help
    - snyk auth $SNYK_TOKEN
    - echo SnykProjName:${CI_API_V4_URL}:${CI_COMMIT_SHORT_SHA} # <--- We're adding these GitLab variables to the Snyk monitor command directly below
    - snyk monitor --org=$SNYK_ORG_ID --project-name=${CI_API_V4_URL}:${CI_COMMIT_SHORT_SHA} # <---the project name in Snyk UI will be <GitLab api url>:<GitLab commit SHA(short)>
    - snyk test --json --org=$SNYK_ORG_ID | snyk-to-html -o snyk_results.html

  # Save report to artifacts
  artifacts:
    when: always
    paths:
      - snyk_results.html
```
ref: https://github.com/snyk-labs/snyk-cicd-integration-examples/blob/master/GitLabCICD/gitlab-npm.yml

running a CI pipeline inside a container: https://docs.gitlab.com/runner/executors/docker.html
> Notice the above CI script contains references to some GitLab variables including CI_COMMIT_SHORT_SHA
> Here's the rest of the [GitLab standard variables list](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)

---
### Kicking it Off

After you save your `.gitlab-ci.yml` file, you'll want to commit your changes to GitLab:

```bash
cd ~/snky/goof
git status

# Stage the new file
git add .gitlab-ci.yml

# Create a commit for the CI configuration
git commit -m 'add CI' .gitlab-ci.yml

# Push all of these commits to the remote repo on gitlab.com
git push
```
> The git push command will kick off a CI Pipeline inside a GitLab runner 

> **Q:** How long does it take to finish?

> Time it

---

### Checking Progress

Go to [GitLab](https://gitlab.com) and navigate to your project

Should be: `https://gitlab.com/$GITLAB_USER/goof`

You can also generate the URL from your `repo_metadata_goof.json` file (and the knowledge of the `pipelines` web path):

```shell
echo "$( jq -r '.web_url' ~/snyky/repo_metadata_goof.json )/-/pipelines"
```

If you're manually navigating, click the `Pipelines` link under `CI/CD` on the left-side menu

If you don't see anything here, make sure you saved your `.gitlab-ci.yml` in the correct location, added, committed, and pushed your repo.

You should see a `pending` or `running` (or maybe `passed` or `failed`) pipeline

1. On the main Pipelines page, click on the status icon to see the pipeline details
2. On the details page, click on the status icon to get information about the build (job) status
3. You should see the output from your job on this page
4. While in the dependency_scanning page (the job), click on **Browse**:
   ![image](artifact.png?)


5. Click on **snyk-results.html**:
   ![image](artifact-browse-tab.png?)


---

> **Q:** The `snyk monitor` command may have succeeded, but the `snyk test` command and the artifact left behind probably did not find any vulns... Why?

> **A:** Add an NPM install to the CI file:

```shell
open -a TextEdit ~/snyky/goof/.gitlab-ci.yml
```

```yaml
# Example Snyk script for GitLab CI/CD Pipeline with Node.js project

dependency_scanning:
  image: node:latest
  stage: test
  script:
    # Install npm, snyk, and snyk-to-html
    - npm install -g npm@latest
    - npm install -g snyk
    - npm install snyk-to-html -g
    # Run snyk help, snyk auth, snyk monitor, snyk test to break build and out report
    - snyk --help
    - echo SnykProjName:${CI_API_V4_URL}:${CI_COMMIT_SHORT_SHA} # <--- add these GitLab variables to the Snyk monitor command directly below
    - snyk monitor --org=$SNYK_ORG_ID --project-name=${CI_API_V4_URL}:${CI_COMMIT_SHORT_SHA} # <---the project name in Snyk UI will be <GitLab api url>:<GitLab commit SHA(short)>
    # Insert the below npm command - npm will build the application before scanning
    - npm install # <---
    - snyk test --json --org=$SNYK_ORG_ID | snyk-to-html -o snyk_results.html

  # Save report to artifacts
  artifacts:
    when: always
    paths:
      - snyk_results.html
```

> Use `git` to `add`, `commit`, and `push` the updated `.gitlab-ci.yml` file to the repo ^^^ How long does it take to finish the test this time?

> Go to the GitLab repo page, wait for the pipeline to finish and then check out the artifact

> **Q:** Do you see results this time? 


---

### How is all of this relevant?

> Example: Customer request for a way to get specific SCM **commit SHAs** into Snyk UI/API

> **Q:** What is a commit SHA?

![image](gitlab-scm-commit-sha.png?)

### Commit SHA in pipeline

> Since I included the GitLab env var called ${CI_COMMIT_SHORT_SHA} in the snyk monitor command in the CI file, you can see it below...
![img.png](gitlab-ci-commit-sha.png?)
link: https://gitlab.com/$GITLAB_USER/Goof/-/jobs
### Snyk UI

> ... and it will also appear as the project name in the Snyk UI...
![image](snyk-ui-commit-sha.png?)
link: https://app.snyk.io/org/$ORG_SLUG/projects

### Snyk API

> ... AND it will also appear in the Snyk API...
![image](snyk-api-example.png?)
link:https://snyk.docs.apiary.io/#reference/projects/individual-project/retrieve-a-single-project?console=1

curl command to get the same thing:

```shell
curl --include \
     --header "Content-Type: application/json" \
     --header "Authorization: token $SNYKTOKEN" \
  'https://api.snyk.io/api/v1/org/$SNYK_ORG_ID/project/<snyk-project-id>'
```

> Once you have verified your commit SHA appears in the Snyk API using the above API endpoint, you have finished the lab!

| Previous: [GitLab](/labs/01_gitlab) | Next: [WIP! Not updated! Docker](/labs/02_docker) |
|-------------------------------------------:|:--------------------------------------------------|
