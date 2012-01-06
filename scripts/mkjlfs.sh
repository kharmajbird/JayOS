#!/bin/sh

#
# launched from build.sh; runs under a clean environment
#

HEAD=/lfs/build/JayOS

echo "Building LFS base" && \
cd /tools/src && make && make un-prep && \
\
\
echo "Finished building LFS base" || \
    ( echo "Problem building LFS base..you got a long road ahead of ya :(" && \
    read val && make un-prep && exit 1 )

#
# Start Beyond Linux From Scratch build
#

echo "Building BLFS with JayOS customizations" && \
cd $HEAD/jlfs && \
make prep && \
\
cd /usr/src && \
make && \
make un-prep && \
make strip-man && \
make livecd
