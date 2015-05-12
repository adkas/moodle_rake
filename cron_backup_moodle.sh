#!/bin/bash

scriptdir=`dirname $(readlink -f $0)`

cd $scriptdir

rake backup

