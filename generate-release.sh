#!/bin/bash

# Build the docker container if it does not exist yet
if [[ "$(docker images -q ac-lua-builder 2> /dev/null)" == "" ]]; then
  docker build . -t ac-lua-builder
fi

buildFilesDirectory="./build-tmp"
if [ -d "$buildFilesDirectory" ]; then
  rm -r "$buildFilesDirectory"
fi
mkdir "$buildFilesDirectory"
cp -R ./{enet,include,lanes,lib,lua,src,Makefile,Makefile.linux,build.sh} "$buildFilesDirectory"

# Use the docker container to compile the code
docker run --rm -v "$PWD/build-tmp:/app" ac-lua-builder

# Upate the linux_release directory
if [ -d "./linux_release" ]; then
  rm -r "./linux_release"
fi
if [ -d "$buildFilesDirectory/linux_release" ]; then
  mv "$buildFilesDirectory/linux_release" "./linux_release"
fi

# Create a zip file that contains the files that are needed to change a standard server to a Lua server
releaseFilesDirectory="./tmp-release-files"
if [ -d "$releaseFilesDirectory" ]; then
  rm -r "$releaseFilesDirectory"
fi

mkdir -p "$releaseFilesDirectory/bin_unix"
cp "linux_release/linux_64_server" "$releaseFilesDirectory/bin_unix/linux_64_server"
cp -r "linux_release/lua" "$releaseFilesDirectory/lua"

if [ -f "release.zip" ]; then
  rm "release.zip"
fi
(cd "$releaseFilesDirectory" && zip -r ../release.zip .)

# Clean up
rm -r "$buildFilesDirectory"
rm -r "$releaseFilesDirectory"
