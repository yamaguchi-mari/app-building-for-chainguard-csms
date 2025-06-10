# Intro to DevOps

---

### Class Goal

DevOps is an exceptionally broad discipline.  It requires development expertise, operations sensibility, an immense capacity for troubleshooting, eagerness to learn, and - maybe most importantly - a broad base of knowledge around tools that can be stitched together to accomplish the goal.  

This class will provide you with a very basic framework for workflow automation.  Every commit to a repo will be built, tested, and deployed.

There is no Holy Grail - every environment is different.  This course attempts to use mostly free, open-source software to show that workflow automation is a real thing that can be done.  We'll cover one way to do it, but there are many, many other ways to accomplish the same thing.  (I've also done a GitHub --> CircleCI --> AWS/Mesos/Marathon setup that does something very similar to what we'll see in this course.)

---

### Prerequisites:

- Before starting this class, you should have a basic familiarity with a Unix-like shell (sh, bash, zsh, ksh, etc.)
- Laptop
  - A web browser - Chrome (or a Chrome-based browser like Brave) is probably best for this class
- [Create a GitLab account](https://gitlab.com/users/sign_in)
  - If you already have one, you can disregard this
- A Snyk account

***

### Following Instructions

Please follow the documented and stated instructions as closely as possible.  This will help mitigate issues that arise due to funky configurations.  As mentioned above, we'll be stitching together a number of tools.  This means that the labs are very inter-dependent, and an innocent deviation in an early lab could complicate a later lab.

I encourage all students to experiment and explore the material.  Making it your own and having fun with it will probably increase the functional utility of this class immensely.  I'm happy to help with any extracurricular questions and/or interests related to the material, but please try the extra stuff after completing the suggested stuff.  And maybe in a different subdirectory.  :)

***

# Labs

### 00. [Bash](/labs/00_bash_cloudshell)

### 01. [GitHub](/labs/01_github)

### 01a. [Chainguard and CI](/labs/01a_chainguard_ci)

> End of updated content (A. Sayre - Sept 2022)

### 02. [WIP! Not updated! Docker](/labs/02_docker)

### 03. [Webserver](/labs/03_webserver)

### 04. [Continuous Integration](/labs/04_continuous_integration)

### 05. [AWS & Kubernetes](/labs/05_aws_kubernetes)

### 06. [Manual Deployment](/labs/06_manual_deployment)

### 07. [Authenticating Kubernetes to GitLab](/labs/07_auth_kubernetes_to_gitlab)

### 08. [Authenticating GitLab to Kubernetes](/labs/08_auth_gitlab_to_kubernetes)

### 09. [Automated Deployment](/labs/09_automated_deployment)

### 10. [Everything](/labs/10_everything) (a.k.a. The Easy Lab)

### 11. [Environment Management](/labs/11_environment_mgmt)

### 12. [Test Gates for Continuous Deployment](/labs/12_test_gates)

### 13. [Horizontal Pod Autoscaler and Load Testing](/labs/13_load_and_hpa)
---

### Recommended Reading
- [The Phoenix Project](https://www.amazon.com/Phoenix-Project-DevOps-Helping-Business/dp/0988262509/), by Gene Kim
  - This is a rewrite of *The Goal* for the modern age.
- [The Goal](https://www.amazon.com/Goal-Process-Ongoing-Improvement/dp/0884271951/), by Eliyahu Goldratt
  - This is the original, and I think you'll benefit from doing the modern adaptation yourself.
