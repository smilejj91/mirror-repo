# mirror-repo

# build with Dockerfile

## $ docker build . --no-cache -t mirror-repo:{tag}

# using mirror.sh in docker 

## $ docker cp mirror.sh {mirror-repo container}:/app/
## $ ./mirror.sh {distribution}
