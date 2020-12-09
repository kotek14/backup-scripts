#!/bin/bash

# My packages installation script.
# It is supposed to restore packages and repos from backup.
# Written on Xubuntu 20.04

# Important! If you have multiple backups in the folder, you're on your own.

# Some basic errors.
# - You have to be root
# - You have to provide a backup folder
# - The backup folder should have exactly one packages backup folder.
printUsage () {
        echo "Usage: sudo ./PackagesRestore.sh /path/to/backup/folder" > /dev/stderr
}

if [ $(id -u) -ne 0 ] 
then
    echo "Error: Are you root?" > /dev/stderr
    printUsage
    exit 1
elif [ $# -ne 1 ] 
then
    echo "Error: The script takes exactly one argument" > /dev/stderr
    printUsage
    exit 1
elif [ ! -e $1 ]
then
    echo "Error: The folder you specified doesn't exist!" > /dev/stderr
    printUsage
    exit 1
elif [ ! -e $1/Pkg-* ]
then
    echo "Error: The folder exists, but it doesn't contain the PackagesBackup.sh data" > /dev/stderr
    printUsage
    exit 1
elif [ $(find $1 -maxdepth 1 -name Pkg-* | wc -l) -ne 1 ]
then
    echo "Error: There are multiple backups in the folder specified" > /dev/stderr
    printUsage
    exit 1 
fi

PKGDIR=$(find $1 -maxdepth 1 -name Pkg-*)
LOGDIR=/tmp/RestoreLogs-$(date +%Y%b%d)
KEYFIL=$PKGDIR/Pkg-*.keys
PKGFIL=$PKGDIR/Pkg-*.packages

# The script creates a log folder in /tmp
[ ! -e $LOGDIR ] && echo "LOG: Creating today's log folder $LOGDIR..." && mkdir $LOGDIR

# Doing a quick check if $KEYFIL has an asterisk.
# If it does, that means that they .keys file isn't present in $PKGDIR
echo "LOG: Restoring APT keys"
[ -z $(echo $KEYFIL |  grep "*") ] && cat $KEYFIL | apt-key add >> $LOGDIR/temp.log 2>&1 && cat $LOGDIR/temp.log >> Packages.log  || { echo "ERROR: .keys file is not present in $PKGDIR. Aborting..."; exit 1; }

echo "LOG: Copying the APT sources files"
cp -r $PKGDIR/sources* /etc/apt && chmod -R 644 /etc/apt/sources.list* && chmod +x /etc/apt/sources.list.d 

# Very annoying, so I always purge it.
echo "LOG: Killing and removing unattended-upgrades"
killall unattended-upgrades 2>/dev/null
apt purge -y unattended-upgrades >> $LOGDIR/temp.log 2>&1 && cat $LOGDIR/temp.log >> Packages.log

# Some packages prompt user for input during installation (such as Microsoft fonts)
echo "--> Please make sure you're around during packages installation."
read -p "--> Install packages from the backup? (N/y) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    if [ -z $(echo $PKGFIL |  grep "*") ]
    then
        echo "LOG: Installing packages!"
        apt update >> $LOGDIR/temp.log 2>&1 && cat $LOGDIR/temp.log >> Packages.log
        apt install -y dselect >> $LOGDIR/temp.log 2>&1 && cat $LOGDIR/temp.log >> Packages.log
        dselect update >> $LOGDIR/Packages.log
        dpkg --set-selections < $PKGFIL
        apt-get -y dselect-upgrade
    else
        echo "ERROR: .packages file is not present in $PKGDIR. Aborting..."
        exit 1
    fi
fi

rm $LOGDIR/temp.log 2> /dev/null
echo "LOG: Done!"
