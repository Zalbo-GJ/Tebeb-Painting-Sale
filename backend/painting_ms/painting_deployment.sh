# Start up Docker
open --background -a Docker

# sleep for 20 seconds till docker is up
sleep 20

# create a docker image
./mvnw clean install jib:dockerBuild

## docker login
#username="abenezertigistu"
#docker login --username "$username"

# Tag image
docker tag painting_ms:0.0.1-SNAPSHOT abenezertigistu/tibeb:painting_ms

# Push image
docker push abenezertigistu/tibeb:painting_ms

# Deploying
curl -X POST "https://api.render.com/deploy/srv-ckrrv6g1hnes738udms0?key=BFyJkA86jNw"
