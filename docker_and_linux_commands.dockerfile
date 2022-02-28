uname -m  : check architecture (e.g. x86_64)
lsb_release -a : check OS version

# Q) How to run latest PostgreSQL container?
docker run -e POSTGRES_PASSWORD=h1a2k3a4 postgres

# Q) How to check all running containers?
(base) hakan@hakan-VirtualBox:~$ docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED              STATUS              PORTS      NAMES
af1e44334536   postgres   "docker-entrypoint.s…"   About a minute ago   Up About a minute   5432/tcp   elastic_keller

docker images : list of docker images in the docker host

# Q) How to create a container from a specific docker image?
(base) hakan@hakan-VirtualBox:~$ docker run -it -e POSTGRES_PASSWORD=h1a2k3a4 postgres

# Q) How to get help about specific (management) command?
(base) hakan@hakan-VirtualBox:~$ docker ps --help
(base) hakan@hakan-VirtualBox:~$ docker container --help
(base) hakan@hakan-VirtualBox:~$ docker container wait --help

# Q) To cleanup all the stopped containers
(base) hakan@hakan-VirtualBox:~$ docker ps -a
(base) hakan@hakan-VirtualBox:~$ docker container prune

# Q) To cleanup (dangling) images that are not used:

(base) hakan@hakan-VirtualBox:~$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
postgres      latest    07e2ee723e2d   4 weeks ago     374MB
mysql         latest    30f937e841c8   20 months ago   541MB
nginx         latest    9beeba249f3e   20 months ago   127MB
httpd         latest    d4e60c8eb27a   20 months ago   166MB
mongo         latest    3f3daf863757   21 months ago   388MB
alpine        latest    f70734b6a266   21 months ago   5.61MB
hello-world   latest    bf756fb1ae65   2 years ago     13.3kB

(base) hakan@hakan-VirtualBox:~$ docker image prune -a
-a : cleanup also the dangling images (the ones in cache but not in Docker Registry)

docker run - start a container
e.g. docker run nginx

docker ps - list running containers
docker ps - list running and stopped containers

docker stop <container_id>    : to stop running container
docker stop <container_name>  : to stop running container

docker rm sill_sammet         : to remove a stopped container

docker images : to list of the images that are in the local cache
docker rmi images : to remove an image, you must stop & delete all the dependent containers

docker pull nginx  : to pull the image but not to run it

(base) hakan@hakan-VirtualBox:~$ docker run ubuntu sleep 60
(base) hakan@hakan-VirtualBox:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS                     PORTS     NAMES
94289ca85349   ubuntu    "sleep 100"   8 seconds ago   Up 8 seconds                         hungry_brown
077c7c8bbd64   ubuntu    "sleep 5"     4 minutes ago   Exited (0) 4 minutes ago             festive_allen
(base) hakan@hakan-VirtualBox:~$ docker exec 94289ca85349 cat /etc/hosts

# By default, docker runs the containers in the attached mode; your terminal window will be bound to STDOUT of the container's process.
# You wont be able to execute any further commands in the terminal window.

docker run -d kodekloud/simple-webapp  << runs the container in detached mode in the background process
(base) hakan@hakan-VirtualBox:~$ docker ps -a
CONTAINER ID   IMAGE                     COMMAND           CREATED          STATUS                     PORTS     NAMES
a7004283d430   kodekloud/simple-webapp   "python app.py"   54 seconds ago   Exited (0) 4 seconds ago             magical_jackson

docker attach a7004283d430             << attaches the current terminal process to the running container
    # we are attaching out terminal STDIN, STDOUT and STDERR to that of the container's STDIN, STDOUT and STDERR respectively

# Q) how to name a container? with --name option in run command
docker run -d --name webapp kodekloud/simple-webapp

# Q) How to run a specific version of a container?
docker run redis:4.0

# How to run the latest version of a container?
docker run redis
docker run redis:latest

####  RUN - STDIN & STDOUT
    # Consider having an interactive hello application
    ~/prompt-application$ ./app.sh
    Please Enter your name: Hakan

    Hello & Wellcome Hakan!

    # If we were to dockerize the app and run it like this:
    docker run simple-prompt-application

    Hello & Wellcome !

    # So, the container would not wait for the prompt.
    # It would print what it has already in the wellcome string.
    # That is because, by default, the container does not listen to its standard input
    # Even though you are attached to its console, it is not able to read any input from STDIN.
    # It does not have a terminal to read input from; it runs in a non-interactive mode
    # If you would like to provide input to the container, you must map
    # STDIN of the terminal to the STDIN of the running container:
    docker run -i simple-prompt-application
    Hakan

    Hello & Wellcome Hakan!

    # But the prompt "Please Enter your name:" is missing in the previous output.
    # When dockerized that prompt is missing. That's because, we have not attached
    # our terminal to the containers terminal. To show the prompt, add -t option:
    docker run -it simple-prompt-application
    Please Enter your name: Hakan

    Hello & Wellcome Hakan!

    Q1) What happens in the background when we pass -i option to docker run command?
        i.e. in terms of connecting of STDIN to the container etc.

    Q2) What happens in the background when we pass -t option to docker run command?
        i.e. in terms of creating a new terminal and connecting our terminal to that


# Q) How do we see the logs of a container running in a background?
docker run -d --name webapp kodekloud/simple-webapp
docker logs webapp

# Q) How do pass an environment variable?
docker run -e APP_COLOR=black simple-webapp

# Q) How to check an environment variable in a running container?
A) Use docker inspect command > config section

# Q) List the current networks
docker network ls

# Q) What is the subnetwork configured on the bridge network?
docker network inspect bridge

# Q) Run a container named alpine-2 using the alpine image and attach it to the none network.
docker run -d --name alpine-2 --network=none alpine

# Q) Create a new network named wp-mysql-network using the bridge driver. Allocate subnet 182.18.0.1/24. Configure Gateway 182.18.0.1
docker network create --driver bridge --subnet 182.18.0.1/24 --gateway 182.18.0.1 wp-mysql-network

# Q) Deploy a mysql database using the mysql:5.6 image and name it mysql-db. Attach it to the newly created network wp-mysql-network
# Set the database password to use db_pass123. The environment variable to set is MYSQL_ROOT_PASSWORD.
docker run -d --network=wp-mysql-network --name mysql-db -e MYSQL_ROOT_PASSWORD=db_pass123 mysql:5.6

# Q) Deploy a web application named webapp using the kodekloud/simple-webapp-mysql image. Expose the port to 38080 on the host.
# The application makes use of two environment variable:
# 1: DB_Host with the value mysql-db.
# 2: DB_Password with the value db_pass123.
# Make sure to attach it to the newly created network called wp-mysql-network.
# ?? Also make sure to link the MySQL and the webapp container
docker run -d -p 38080:8080 -e DB_Host=mysql-db -e DB_Password=db_pass123 --network=wp-mysql-network --name webapp --link mysql-db:mysql-db kodekloud/simple-webapp-mysql

# Q: To see the layers in the image crazymilo/my-custom-app-img
docker history crazymilo/my-custom-app-img

# Q: Build a docker image using the Dockerfile and name it webapp-color. No tag to be specified.
docker build -t webapp-color .

# Q: What is the base Operating System used by the python:3.6 image?
# If required, run an instance of the image to figure it out.
docker run python:3.6 cat /etc/*release*

# Q: List the networks
docker network ls

# Q: What is the subnet configured on the bridge network
docker network inspect bridge

# Q: Run a container named alpine-2 using the alpine image and attach it to the none network.
docker run -d --network=none --name=alpine-2 alpine

# Q: Create a new network named wp-mysql-network using the bridge driver. Allocate subnet 182.18.0.1/24. Configure Gateway 182.18.0.1
docker network create --driver=bridge --subnet 182.18.0.1/24 --gateway 182.18.0.1 wp-mysql-network

# Q: Deploy a mysql database using the mysql:5.6 image and name it mysql-db. Attach it to the newly created network wp-mysql-network
# Set the database password to use db_pass123. The environment variable to set is MYSQL_ROOT_PASSWORD.
docker run -d --name mysql-db --network=wp-mysql-network -e MYSQL_ROOT_PASSWORD=db_pass123 mysql:5.6

# Q: Deploy a web application named webapp using the kodekloud/simple-webapp-mysql image. Expose the port to 38080 on the host.
# The application makes use of two environment variable:
# 1: DB_Host with the value mysql-db.
# 2: DB_Password with the value db_pass123.
# Make sure to attach it to the newly created network called wp-mysql-network.
# Also make sure to link the MySQL and the webapp container.
docker run -d -p 38080:8080 -e DB_Host=mysql-db -e DB_Password=db_pass123 --network=wp-mysql-network --link mysql-db:mysql-db  --name webapp kodekloud/simple-webapp-mysql

# Q: Run a container named blue-app using image kodekloud/simple-webapp and set the environment variable APP_COLOR to blue.
# Make the application available on port 38282 on the host. The application listens on port 8080.
docker run -d --name blue-app -e APP_COLOR=blue -p 38282:8080 kodekloud/simple-webapp

# Q: Deploy a mysql database using the mysql image and name it mysql-db.
# Set the database password to use db_pass123
docker run -d --name mysql-db -e MYSQL_ROOT_PASSWORD=db_pass123 mysql


# When you install docker on a docker host, it creates this folder structure at
/var/lib/docker
    /aufs
    /containers
    /image
    /volumes
    ...

# Q: How to create a volume?
docker volume create data_volume_1    -> creates a volume under /var/lib/docker/volumes/data_volume_1
docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 -v data_volume_1:/var/lib/mysql --name mysql-db mysql

# Q: Run a mysql container again, but this time map a volume to the container so that the data stored by the container is stored at /opt/data on the host.
# Use the same name : mysql-db and same password: db_pass123 as before. Mysql stores data at /var/lib/mysql inside the container.
docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 -v /opt/data:/var/lib/mysql --name mysql-db mysql

# Q:  Let's push two images for now .i.e. nginx:latest and httpd:latest.
# To check the list of images pushed , use curl -X GET localhost:5000/v2/_catalog
# Run:
$ docker run -d --name my-registry -p 5000:5000 --restart=always registry:2

docker pull nginx:latest
docker image tag nginx:latest localhost:5000/nginx:latest
docker push localhost:5000/nginx:latest

# We will use the same steps for the second image docker
docker pull httpd:latest
docker image tag httpd:latest localhost:5000/httpd:latest
docker push localhost:5000/httpd:latest

## Demo – Example Voting Application - Part 1 : Running the application stack via docker run commands
## The source code for the Example Voting Application: https://github.com/dockersamples/example-voting-app
        (base) hakan@hakan-VirtualBox:~/Docker$ git clone https://github.com/dockersamples/example-voting-app.git
        (base) hakan@hakan-VirtualBox:~/Docker$ cd example-voting-app/
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ ls -la
        total 172
        drwxrwxr-x 10 hakan hakan  4096 helmi 15 14:16 .
        drwxr-xr-x  7 hakan hakan  4096 helmi 15 14:16 ..
        -rw-rw-r--  1 hakan hakan 54824 helmi 15 14:16 architecture.png
        -rw-rw-r--  1 hakan hakan   893 helmi 15 14:16 docker-compose-javaworker.yml
        -rw-rw-r--  1 hakan hakan   598 helmi 15 14:16 docker-compose-k8s.yml
        -rw-rw-r--  1 hakan hakan   116 helmi 15 14:16 docker-compose.seed.yml
        -rw-rw-r--  1 hakan hakan   485 helmi 15 14:16 docker-compose-simple.yml
        -rw-rw-r--  1 hakan hakan  1070 helmi 15 14:16 docker-compose-windows-1809.yml
        -rw-rw-r--  1 hakan hakan   994 helmi 15 14:16 docker-compose-windows.yml
        -rw-rw-r--  1 hakan hakan  1488 helmi 15 14:16 docker-compose.yml
        -rw-rw-r--  1 hakan hakan  1562 helmi 15 14:16 docker-stack-simple.yml
        -rw-rw-r--  1 hakan hakan  1037 helmi 15 14:16 docker-stack-windows-1809.yml
        -rw-rw-r--  1 hakan hakan  1284 helmi 15 14:16 docker-stack-windows.yml
        -rw-rw-r--  1 hakan hakan  1792 helmi 15 14:16 docker-stack.yml
        -rw-rw-r--  1 hakan hakan  2058 helmi 15 14:16 ExampleVotingApp.sln
        drwxrwxr-x  8 hakan hakan  4096 helmi 15 14:16 .git
        drwxrwxr-x  2 hakan hakan  4096 helmi 15 14:16 .github
        -rw-rw-r--  1 hakan hakan    53 helmi 15 14:16 .gitignore
        drwxrwxr-x  2 hakan hakan  4096 helmi 15 14:16 healthchecks
        drwxrwxr-x  2 hakan hakan  4096 helmi 15 14:16 k8s-specifications
        -rw-rw-r--  1 hakan hakan  3364 helmi 15 14:16 kube-deployment.yml
        -rw-rw-r--  1 hakan hakan 10758 helmi 15 14:16 LICENSE
        -rw-rw-r--  1 hakan hakan   288 helmi 15 14:16 MAINTAINERS
        -rw-rw-r--  1 hakan hakan  3838 helmi 15 14:16 README.md
        drwxrwxr-x  6 hakan hakan  4096 helmi 15 14:16 result          << results app
        drwxrwxr-x  2 hakan hakan  4096 helmi 15 14:16 seed-data
        drwxrwxr-x  5 hakan hakan  4096 helmi 15 14:16 vote            << voting app
        drwxrwxr-x  6 hakan hakan  4096 helmi 15 14:16 worker          << worker app

        # create a volume for redis and mount it on /healthchecks/ folder in the container named "redis"
        # the container must use the image redis:5.0-alpine3.10
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker volume create redis_volume
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker run -d --name redis -v redis_volume:/healthchecks/  redis:5.0-alpine3.10
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS         PORTS      NAMES
        80ae122b83ec   redis:5.0-alpine3.10   "docker-entrypoint.s…"   10 seconds ago   Up 9 seconds   6379/tcp   redis

        # build the voting app and tag it as voting-app
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker build -t voting-app ./vote/
        ...
        Step 7/8 : EXPOSE 80

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker images
        REPOSITORY                TAG              IMAGE ID       CREATED          SIZE
        voting-app                latest           75d4b2a55fbe   53 seconds ago   141MB
        python                    3.9-slim         8da5d5abf979   10 days ago      122MB     << voting-app image is built
        ubuntu                    latest           54c9d81cbb44   13 days ago      72.8MB
        redis                     5.0-alpine3.10   a49ff3e0d85f   2 years ago      29.3MB
        kodekloud/simple-webapp   latest           c6e3cd9aae36   3 years ago      84.8MB
        kodekloud/webapp          latest           1a45ba829f10   4 years ago      432MB

        # create a container for voting app and name it as vote. Link the container to the container named redis
        # make sure that port 80 in the container is mapped to port 5000 in the host
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker run -d --name vote --link redis:redis -p 5000:80 voting-app
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                   NAMES
        dc59b6c114d9   voting-app             "gunicorn app:app -b…"   8 seconds ago    Up 7 seconds    0.0.0.0:5000->80/tcp, :::5000->80/tcp   vote
        80ae122b83ec   redis:5.0-alpine3.10   "docker-entrypoint.s…"   19 minutes ago   Up 19 minutes   6379/tcp

        # create a container named db based on postgres:9.4 image. Environment variables are:
        # POSTGRES_USER: "postgres"
        # POSTGRES_PASSWORD: "postgres"
        # in addition, create a volume called postgres_volume and map it to /var/lib/postgresql/data
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker volume create postgres_volume
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker run -d --name db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -v postgres_volume:/var/lib/postgresql/data postgres:9.4
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                   NAMES
        8f71d918e545   postgres:9.4           "docker-entrypoint.s…"   6 seconds ago    Up 5 seconds    5432/tcp                                db
        dc59b6c114d9   voting-app             "gunicorn app:app -b…"   8 minutes ago    Up 8 minutes    0.0.0.0:5000->80/tcp, :::5000->80/tcp   vote
        80ae122b83ec   redis:5.0-alpine3.10   "docker-entrypoint.s…"   27 minutes ago   Up 27 minutes   6379/tcp                                redis

        # build the worker image named as worker-app-img
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker build -t worker-app-img ./worker/
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker images
        REPOSITORY                              TAG              IMAGE ID       CREATED          SIZE
        worker-app-img                          latest           8b49275b5e51   4 seconds ago    193MB  << worker-app-img is built
        # create a container named worker which is based on the worker-app-img
        # link db container to the newly created container
        # link the redis container to the newly created container
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker run -d --name worker --link db:db --link redis:redis worker-app-img
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                   NAMES
        177738bb4e2d   worker-app-img         "dotnet Worker.dll"      5 seconds ago    Up 4 seconds                                            worker
        8f71d918e545   postgres:9.4           "docker-entrypoint.s…"   7 minutes ago    Up 7 minutes    5432/tcp                                db
        dc59b6c114d9   voting-app             "gunicorn app:app -b…"   15 minutes ago   Up 15 minutes   0.0.0.0:5000->80/tcp, :::5000->80/tcp   vote
        80ae122b83ec   redis:5.0-alpine3.10   "docker-entrypoint.s…"   34 minutes ago   Up 34 minutes   6379/tcp                                redis

        # build result app image named result-app-img
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker build -t results-app-img ./result/
        ...
        Step 12/13 : EXPOSE 80
        ...
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker images
        REPOSITORY                              TAG              IMAGE ID       CREATED          SIZE
        results-app-img                         latest           573ade187f21   17 seconds ago   160MB   << successfully built results-app-img
        ...
        # run result app image named result linked to db with port mapping 5001:80
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker run -d --name result --link db:db -p 5001:80 results-app-img

        # cleanup steps:
        # kill all running containers
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker container kill result worker db vote redis
        result
        worker
        db
        vote
        redis

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS                       PORTS     NAMES
        015def967daf   results-app-img        "docker-entrypoint.s…"   3 minutes ago    Exited (137) 7 seconds ago             result
        177738bb4e2d   worker-app-img         "dotnet Worker.dll"      9 minutes ago    Exited (137) 7 seconds ago             worker
        8f71d918e545   postgres:9.4           "docker-entrypoint.s…"   17 minutes ago   Exited (137) 7 seconds ago             db
        dc59b6c114d9   voting-app             "gunicorn app:app -b…"   25 minutes ago   Exited (137) 7 seconds ago             vote
        80ae122b83ec   redis:5.0-alpine3.10   "docker-entrypoint.s…"   44 minutes ago   Exited (137) 7 seconds ago             redis

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker container prune
        WARNING! This will remove all stopped containers.
        Are you sure you want to continue? [y/N] y
        Deleted Containers:
        015def967daf2e5ffd1d8d2dd48d4a9653726bd129be6289fb695dfec2b70653
        177738bb4e2d607a0d4ca9c251b85f6d2ff6b0ae714ead70c3a207a1bc47c64f
        8f71d918e545c39a6ca07987d669cb83a6cb4c5754ecc1dfa8c8faf097280a0f
        dc59b6c114d9b5f5a6c61bc814f40041cc123c50c67db2817a9585d71291b429
        80ae122b83ec6487509b72897178e94b1b37ec7e6e95ce2ef65ff10743b27b35

        Total reclaimed space: 524.6kB

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker images
        REPOSITORY                              TAG              IMAGE ID       CREATED          SIZE
        results-app-img                         latest           573ade187f21   7 minutes ago    160MB
        worker-app-img                          latest           8b49275b5e51   15 minutes ago   193MB
        <none>                                  <none>           f2405fb05538   16 minutes ago   749MB
        voting-app                              latest           75d4b2a55fbe   29 minutes ago   141MB
        mcr.microsoft.com/dotnet/core/sdk       3.1              4a4f24ef67d3   6 days ago       710MB
        mcr.microsoft.com/dotnet/core/runtime   3.1              cb9ef5fcda2c   6 days ago       190MB
        python                                  3.9-slim         8da5d5abf979   10 days ago      122MB
        ubuntu                                  latest           54c9d81cbb44   13 days ago      72.8MB
        node                                    10-slim          6fbcbbb5c603   10 months ago    134MB
        postgres                                9.4              ed5a45034282   2 years ago      251MB
        redis                                   5.0-alpine3.10   a49ff3e0d85f   2 years ago      29.3MB
        kodekloud/simple-webapp                 latest           c6e3cd9aae36   3 years ago      84.8MB
        kodekloud/webapp                        latest           1a45ba829f10   4 years ago      432MB
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker image prune -a
        WARNING! This will remove all images without at least one container associated to them.
        Are you sure you want to continue? [y/N] y

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker images
        REPOSITORY   TAG       IMAGE ID   CREATED   SIZE

## Demo – Example Voting Application - Part 1 : Running the application stack via docker-compose-hakan.yml
## The source code for the Example Voting Application: https://github.com/dockersamples/example-voting-app
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker-compose -f docker-compose-hakan.yml up -d
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps -a
        CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS          PORTS                                   NAMES
        e3f98e1b4cf1   example-voting-app_worker   "dotnet Worker.dll"      39 seconds ago   Up 37 seconds                                           example-voting-app_worker_1
        c2e2ade3ed81   example-voting-app_result   "docker-entrypoint.s…"   39 seconds ago   Up 37 seconds   0.0.0.0:5001->80/tcp, :::5001->80/tcp   example-voting-app_result_1
        90f1301be776   postgres:9.4                "docker-entrypoint.s…"   39 seconds ago   Up 38 seconds   5432/tcp                                example-voting-app_db_1
        c3b0c0030cdf   example-voting-app_vote     "gunicorn app:app -b…"   8 minutes ago    Up 38 seconds   0.0.0.0:5000->80/tcp, :::5000->80/tcp   example-voting-app_vote_1
        d6592ac21b81   redis:5.0-alpine3.10        "docker-entrypoint.s…"   8 minutes ago    Up 38 seconds   6379/tcp                                example-voting-app_redis_1

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker-compose -f docker-compose-hakan.yml kill
        Killing example-voting-app_worker_1 ... done
        Killing example-voting-app_result_1 ... done
        Killing example-voting-app_db_1     ... done
        Killing example-voting-app_vote_1   ... done
        Killing example-voting-app_redis_1  ... done

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker container prune
        WARNING! This will remove all stopped containers.
        Are you sure you want to continue? [y/N] y
        Deleted Containers:
        e3f98e1b4cf102103c58dedd5e3e3c47dcdb3b51f519aa9c5c196697fdb8202a
        c2e2ade3ed81a16b910dc0f98aa1f896f77dcaa6c90aed896a5d885b3e329ccb
        90f1301be7768d117a61e4cb12a802445fe61ba536ff47a85f3f7b71a1edc633
        c3b0c0030cdfa3525274be6f143a4bfb477eb9ffabe333503722281b59045be6
        d6592ac21b8181e2f2ac554df264795acef96de35f8133c4921a1df7634fe977

        Total reclaimed space: 524.6kB

        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker-compose -f docker-compose-hakan.yml up -d
        Creating redis  ... done
        Creating db    ... done
        Creating result ... done
        Creating vote   ... done
        Creating worker ... done
        (base) hakan@hakan-VirtualBox:~/Docker/example-voting-app$ docker ps
        CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS          PORTS                                   NAMES
        e9086efeb987   example-voting-app_worker   "dotnet Worker.dll"      14 seconds ago   Up 13 seconds                                           worker
        83c2553a8bd5   example-voting-app_vote     "gunicorn app:app -b…"   14 seconds ago   Up 13 seconds   0.0.0.0:5000->80/tcp, :::5000->80/tcp   vote
        205a1b1c764f   example-voting-app_result   "docker-entrypoint.s…"   14 seconds ago   Up 13 seconds   0.0.0.0:5001->80/tcp, :::5001->80/tcp   result
        011b66295717   redis:5.0-alpine3.10        "docker-entrypoint.s…"   15 seconds ago   Up 14 seconds   6379/tcp                                redis
        ca5a0912b8dd   postgres:9.4                "docker-entrypoint.s…"   15 seconds ago   Up 14 seconds   5432/tcp                                db



# Q) What does docker system prune do?
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

# Q: How to run a shell inside a container?
docker exec -it <container_name> sh
docker run -it <container_name> sh

# Q: How to run a container based on a custom image?
docker run  -d <image_id>


# Q: How to run automated tests inside a running container?
(base) hakan@hakan-VirtualBox:~$ docker ps -a
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                                       NAMES
8107d7a0fb2c   frontend_web-frontend   "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   frontend_web-frontend_1

(base) hakan@hakan-VirtualBox:~$ docker exec -it frontend_web-frontend_1 sh
~/app $ npm run test

