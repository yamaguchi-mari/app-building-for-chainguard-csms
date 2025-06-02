# A Really Basic WebServer (in Docker)

*By the end of this lab, you will be able to:*

 * build and run a local webserver container
 * select container images purposefully for your docker builds



For this lab, use the repository you created in the [GitLab lab](labs/01_gitlab).  
If you followed the instructions verbatim, it should be `~/sfs/mywebserver`

```bash
cd ~/sfs/mywebserver
```

---

### Make a Webpage

```bash
mkdir html
echo This is my first web page > html/index.html
cat html/index.html
```

---

### Make a Webserver with Docker

Create a Dockerfile:

```bash
touch ~/sfs/mywebserver/Dockerfile
edit ~/sfs/mywebserver/Dockerfile
```

And add this as the body:

```Dockerfile
FROM nginx

COPY ./html /usr/share/nginx/html/
```

And build your Docker image:

```bash
docker build -t webserver .
```

![image](make_webserver.png?)


---



### Run and Test Your Webserver

Run your webserver with the `-p 8080:80` option to expose the ports, and (optionally) give it a name with the `--name` flag:

```bash
docker run --detach -p 8080:80 --name mywebserver webserver
```

Now run `docker ps` to see information about your running container:

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
f9105b1c0ca3        webserver           "/docker-entrypoint.…"   16 seconds ago      Up 16 seconds       0.0.0.0:8080->80/tcp   mywebserver
```

Finally, test your webserver to see if it's running:

```bash
curl localhost:8080
```

In Google Cloud Shell, you can now click the "Web Preview" button.

---

### Docker Hub - [hub.docker.com](https://hub.docker.com)
  - [Explore](https://hub.docker.com/search?&q=)

---

| Previous: [Docker](/labs/02_docker) | Next: [Continuous Integration](/labs/04_continuous_integration) |
|---:|:---|
