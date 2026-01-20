#!/bin/bash

set -x
l=`ls ../*.sh`
echo > all.txt
for i in $l; do
    echo "------$i------" >> all.txt
    cat $i >> all.txt
    echo "--------------" >> all.txt
done

set +x