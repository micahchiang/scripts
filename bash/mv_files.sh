#!/bin/bash

# move files of an extension from one location to another

ORIGIN=$1
DEST=$2
EXT=$3

find $ORIGIN -type f -depth 1 -name "*.$EXT" -exec mv {} $DEST \;
