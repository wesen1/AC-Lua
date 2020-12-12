FROM debian:buster-slim
RUN apt-get update && \
    apt-get install -y make gcc g++ libreadline-dev lib32z1-dev
WORKDIR /app
CMD ./build.sh
