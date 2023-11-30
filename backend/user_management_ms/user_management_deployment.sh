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
docker tag user_management_ms:0.0.1-SNAPSHOT abenezertigistu/tibeb:user_management_ms

# Push image
docker push abenezertigistu/tibeb:user_management_ms

# Deploying
curl -X POST "https://api.render.com/deploy/srv-cl0d8sis1bgc7396242g?key=-kDOWqZDrQE"