#!/bin/sh

#
# launched from build.sh; runs under a clean environment
#

HEAD=/lfs/build/JayOS
ALERT=/lfs/build/JayOS/skel/jlfs/root/bin/tos-redalert

echo "Building LFS base" && \
cd /tools/src && make && make un-prep && \
\
\
echo "Finished building LFS base" || \
    ( echo "Problem building LFS base... you have a long road ahead of you :(" && \
    play $ALERT && read val && \
    make un-prep && \
    exit 1 )

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
make strip-man
make livecd

play $ALERT >/dev/null 2>&1
sleep 1
play $ALERT >/dev/null 2>&1
