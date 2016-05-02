# docker-eBot-CSGO
All-In-One docker container for CS:GO- and eBot-Server (+ web interface)

### Create container with docker-compose

Example docker-compose.yml-file:
```yml
ebotmysql:
  image: mysql
  volumes:
   - $DOCKER_DATA/ebot/mysql:/var/lib/mysql
  environment:
    - MYSQL_DATABASE=ebotv3
    - MYSQL_USER=ebotv3
    - MYSQL_PASSWORD=ebotv3
    - MYSQL_ROOT_PASSWORD=ebotv3
ebot:
  build: $DOCKER_IMAGES/ebot/
  security_opt:
    - seccomp:unconfined
  links:
    - "ebotmysql:ebotmysql"
  volumes:
    - ${DOCKER_DATA}/csgo:/home/csgo/strike
  ports:
    - "27015:27015/tcp"
    - "27015:27015/udp"
    - "12360:12360/tcp"
    - "12360:12360/udp"
    - "12361:12361/tcp"
    - "12361:12361/udp"
    - "8081:80"
```

