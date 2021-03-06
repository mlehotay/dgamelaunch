#!/bin/sh
#
# reap.sh
# copies bones to the boneyard

NHDIR="/opt/dgl/nh370/"
BONEYARD="/opt/dgl/bones/"

cd $NHDIR
BONES=`ls bon*`
for bonesfile in $BONES; do
        HASH=`cksum $bonesfile | cut -d' ' -f1`
        cp -n $bonesfile "$BONEYARD$bonesfile-$HASH"
done
