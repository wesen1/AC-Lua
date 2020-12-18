#!/bin/bash

###################
# Functions
###################

#
# Copies all files that are required to build AC-Lua to a given directory.
#
# @param string $1 The path to the directory to copy the required files to
#
prepareBuild()
{
  buildFilesDirectory="$1"

  if [ -d "$buildFilesDirectory" ]; then
    rm -r "$buildFilesDirectory"
  fi
  mkdir "$buildFilesDirectory"
  cp -R ./{enet,include,lanes,lib,lua,src,Makefile,Makefile.linux,build.sh} "$buildFilesDirectory"
}

#
# Builds AC-Lua from the files in a given directory.
# The result will be copied to "./linux_release".
# Also removes the given directory.
#
# @param string $1 The path to the directory to copy the required files to
#
build()
{
  buildFilesDirectory="$1"

  # Use the docker container to compile the code
  docker run --rm -v "$buildFilesDirectory:/app" ac-lua-builder

  # Upate the linux_release directory
  if [ -d "./linux_release" ]; then
    rm -r "./linux_release"
  fi
  if [ -d "$buildFilesDirectory/linux_release" ]; then
    mv "$buildFilesDirectory/linux_release" "./linux_release"
  fi

  # Clean up
  rm -r "$buildFilesDirectory"
}

#
# Creates a release "package" from the files in "./linux_release".
# This will just create a zip file from the binary and the empty directories.
#
# @param string $1 The name of the release
#
createReleasePackage()
{
  releaseName="$1"
  zipFileName="AC-Lua-$releaseName.zip"

  # Create a zip file that contains the files that are needed to change a standard server to a Lua server
  releaseFilesDirectory="./tmp-release-files"
  if [ -d "$releaseFilesDirectory" ]; then
    rm -r "$releaseFilesDirectory"
  fi

  mkdir -p "$releaseFilesDirectory/bin_unix"
  cp "linux_release/linux_64_server" "$releaseFilesDirectory/bin_unix/linux_64_server"
  cp -r "linux_release/lua" "$releaseFilesDirectory/lua"

  if [ -f "$zipFileName" ]; then
    rm "$zipFileName"
  fi
  (cd "$releaseFilesDirectory" && zip -r "../$zipFileName" .)

  # Clean up
  rm -r "$releaseFilesDirectory"
}


###################
# Script
###################

# Build the docker container if it does not exist yet
if [[ "$(docker images -q ac-lua-builder 2> /dev/null)" == "" ]]; then
  docker build . -t ac-lua-builder
fi

buildFilesDirectory="$PWD/build-tmp"

# Create one build with the lua version included in this repository
prepareBuild "$buildFilesDirectory"
build "$buildFilesDirectory"
createReleasePackage "local-lua"

# Create another build with the lua version installed in by apt-get
prepareBuild "$buildFilesDirectory"

# Replace "-Llua/src -llua" by "-llua5.1"
sed -i "$buildFilesDirectory/Makefile.linux" -re 's/^(.*)\-Llua\/src \-llua(.+)$/\1\-llua5.1\2/'

build "$buildFilesDirectory"
createReleasePackage "lib-lua"
