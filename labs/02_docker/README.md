# Docker

*By the end of this lab, you will be able to:*

  * compare/contrast containers/vms (like VMs but not, one job vs many, no interactive sessions, space, proc power, spin-up spin down fast!)
  * define docker terms: image/container/file/registry
  * build a new image (layers)
  * run your image


Docker is a program that allows us to run "containers."  Containers can be run almost anywhere.  You can think of them as either tiny, single-process server instances or somewhat overblown application binaries.  They contain all the libraries and dependencies they need to run.

---

### Terminology
- **[Image](https://docs.docker.com/engine/reference/glossary/#/image)** - A collection of filesystem information and  execution parameters for use within a container runtime. An image does not have state and it never changes.  
- **[Container](https://docs.docker.com/engine/reference/glossary/#/container)** - A runtime instance of an image.  

It might help to think of an image as the "gold master" - a copy that is never altered.  A container begins its life as an exact copy of an image, but you can do stuff with it.  A container is a running instance of an image.


Recommended working directory: `~/sfs/work-dir/docker`

```bash
mkdir -p ~/sfs/work-dir/docker
cd ~/sfs/work-dir/docker
```
---

### Test Your Docker Installation

<!--

  _Note_: If you get a permissions error with the above docker pull command, run the below commands to add your user to the `docker` group. If no error, skip to the 'docker run' command belows

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot
```

-->

```bash
# Download the latest Ubuntu image from Docker Hub
docker pull ubuntu:latest

# Run a container from the Ubuntu image
# Tell it to run "echo Hello World"
docker run ubuntu:latest echo Hello World
```

![image](docker_pull.png?)

---

### A Basic Dockerfile

A Dockerfile is essentially a script that tells Docker how to build an image.  When you have a complicated build, this can save you a lot of time.  This is a really basic example that just adds a command (`echo Hello World`) to a basic Ubuntu image.

We're going to create a Dockerfile

```shell
# Create an empty file
touch ~/sfs/work-dir/docker/Dockerfile

# Edit the file
edit ~/sfs/work-dir/docker/Dockerfile
```

Put this in the file and save it:

```Dockerfile
FROM ubuntu:latest
CMD echo Hello World
```

---

### Building an Image

The Dockerfile above is just a script.  To make it useful, you have to build it into an image.  Make sure you're in the same directory as your `Dockerfile` and run this:

```bash
# Build your image
docker build -t hellodocker .
```

Note: Google Cloud Shell instances will ask for authorization to use the Docker daemon.  Go ahead and approve this.

![image](docker_build.png?)


```bash
# List the Docker images on your system
docker images
```


Now you have a useful container.  You've basically taken an Ubuntu image and given it One Job.

---

### Running Your Image

```bash
# Run with the default command
docker run hellodocker

# Override the default command
docker run hellodocker echo DevOps Rocks!
```

![image](docker_run.png?)

---

| Previous: [GitLab](/labs/01_gitlab) | Next: [Webserver](/labs/03_webserver) |
|---:|:---|
