#!/bin/bash

set -x
l=`ls ../yaml/conjur*`
FNAME=allyaml.txt
echo > $FNAME
for i in $l; do
    echo "------$i------" >> $FNAME
    cat $i >> $FNAME
    echo "--------------" >> $FNAME
done

set +x