#!/bin/bash

# Remove old output files if needed
if [ -d ./linux_release ]; then
  rm -r ./linux_release/*
fi

echo "Building Lua mod ..."

# "Fix" a compile error by commenting out the line below
sed -i "s/static inline float round(float x) { return floor(x + 0.5f); }/\/\/&/" src/tools.h

cd enet
./configure
make
cd ../lua
make linux install
cp src/liblua.a ../lib/
cd ..
make linux

# Create the special lua directories that need to be copied to the AssaultCube server directory
mkdir -p linux_release/lua
mkdir linux_release/lua/config
mkdir linux_release/lua/extra
mkdir linux_release/lua/include
mkdir linux_release/lua/scripts

echo "Build complete, the generated files can be found in ./linux_release"
echo "Copy linux_64_server to <standard server directory>/bin_unix/ and lua/ to <standard server directory>/lua"
