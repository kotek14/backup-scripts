#!/bin/bash

# My packages installation script.
# It is supposed to restore configs and stuff.
# Written on Xubuntu 20.04

# Important! If you have multiple backups in the folder, you're on your own.
# In general, this script is pretty straightforward.

# Some basic errors.
# - You have to provide a backup folder
# - The backup folder should have exactly one base backup tarball.
printUsage () {
        echo "Usage: ./BaseRestore.sh /path/to/backup/folder" > /dev/stderr
}

if [ $# -ne 1 ] 
then
    echo "Error: The script takes exactly one argument" > /dev/stderr
    printUsage
    exit 1
elif [ ! -e $1 ]
then
    echo "Error: The folder you specified doesn't exist!" > /dev/stderr
    printUsage
    exit 1
elif [ ! -e $1/Base-* ]
then
    echo "Error: The folder exists, but it doesn't contain the BaseBackup.sh data" > /dev/stderr
    printUsage
    exit 1
elif [ $(find $1 -maxdepth 1 -name Base-* | wc -l) -ne 1 ]
then
    echo "Error: There are multiple backups in the folder specified" > /dev/stderr
    printUsage
    exit 1 
fi

TARBAL=$(find $1 -maxdepth 1 -name Base-*.tar.gz)
LOGDIR=/tmp/RestoreLogs-$(date +%Y%b%d)
TMPDIR=$(basename $TARBAL .tar.gz)

# The script creates a log folder in /tmp
[ ! -e $LOGDIR ] && echo "LOG: Creating today's log folder $LOGDIR..." && mkdir $LOGDIR

echo "LOG: Creating a temporary folder /tmp/$TMPDIR"
mkdir /tmp/$TMPDIR

echo "LOG: Untarring backup contacts into the temporary folder"
tar -xvf $TARBAL -C /tmp >> $LOGDIR/Base.log

echo "LOG: Copying files over to the $HOME folder"
shopt -s dotglob
cp -rv /tmp/$TMPDIR/* $HOME >> $LOGDIR/Base.log
shopt -u dotglob

echo "LOG: Cleaning up..."
rm -rfv /tmp/$TMPDIR >> $LOGDIR/Base.log

echo "LOG: Done!"
