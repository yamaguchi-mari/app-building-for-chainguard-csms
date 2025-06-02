# Everything All At Once

*By the end of this lab, you will:*

- See continuous integration in action
- See measurable results of DevOps!

---

#### _But First, Feedback_

Please go to the Software Freedom School's [links page](https://sofree.us/links/), find our Feedback Form, and submit!

---

It's time to tie everything together!  

This is what we've been working for.  Remember from the beginning of this course:
```
Faster Development + Smaller Changes = More Stability + Happier People
```

And the success metric for this class is the time it takes for a commit to be deployed.  So let's measure.  Get out your stopwatch.

---

Recommended working directory:

```shell
cd ~/sfs/mywebserver
```

---

### Update the Web Page

Update the web page:

```bash
echo "FINAL EXAM" > ~/sfs/mywebserver/html/index.html
```

We're going to commit the change, but take note of the last line(s) here.  If you paste this whole block to your termianl, it will measure our committed-to-deployed time (~+5 sec).

```bash
git add -A
git commit -m 'web page final exam update'
git push
time while curl --silent $(
    kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}'
) | grep -vi final; do sleep 5; done
```

When this completes, you should see something like this:

```
real    3m5.216s
user    0m41.764s
sys     0m7.151s
```

Take note of the `real` time.  This is the measure of our commit-to-deploy time.

Monitor the progress:

```shell
echo "$( jq -r '.web_url' ~/sfs/repo_metadata.json )/-/pipelines"
```

![image](i2do-aws-cu_2021-4-25_2.png?)

Check it out!

```shell
curl $(kubectl get ing mywebserver-dev -o jsonpath='{.spec.rules[0].host}')
```

---

### Questions for Review

- How long did it take for that commit to be deployed?
- What was the developer effort required to deploy the change?
- What was the operations effort required to deploy the change?

---

### Other Thoughts

- More complicated software will require more complicated testing, but this can all be automated in the `.gitlab-ci.yml` file.  (Which, conveniently, is stored in the code repo.)
- Ops folks might want to investigate options (scripts, [Kubernetes](https://kubernetes.io/), [Marathon](https://github.com/mesosphere/marathon), etc.) to assist with rolling updates.

---

| Previous: [Automated Deployment](/labs/09_automated_deployment) | Next: [Environment Management](/labs/11_environment_mgmt) |
|---:|:---|
