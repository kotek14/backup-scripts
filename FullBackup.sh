#!/bin/bash

# My base backup script.
# It is supposed to backup everything but VMs and Dropbox from the home folder..
# Written on Xubuntu 20.04

# It is a simple naming that avoids overwriting.
# Base-2020Nov27-131226
# Base-YYYYMonDD-HHMMSS
TMPNAME=Full-$(date +%Y%b%d-%H%M%S)
MASTERDIR=$(hostname)-Backup-$(date +%Y%b%d)
#EXCLUDES="$HOME/VMs $HOME/Dropbox"

# If an SSD is connected and mounted, use it as a backup drive.
# This script doesn't save anything to Desktop.
# -e checks if file exists. -f checks if file exists and if it is file, not a directory/link.
if [ -e /media/$USER/Data/B.Backups ]
then
    echo "LOG: Backup SSD is connected. Using the backups folder!"
    DEST=/media/$USER/Data/B.Backups/$MASTERDIR
else
    echo "ERROR: Backup SSD is NOT connected. Can't proceed. Connect the SSD first."
    exit 1
fi

[ ! -e $DEST ] && echo "LOG: Creating today's backup folder $DEST..." && mkdir $DEST

# VMs can easily take hundreds of gigs. Not backing up those!
echo "LOG: Tarring data and saving into $DEST/$TMPNAME.7z"
echo "Please don't disconnect the SSD. Might take a while."
cd
tar --exclude="VMs" --exclude="Dropbox" -cvzpf  $DEST/$TMPNAME.tar.gz $HOME >> $DEST/$TMPNAME.log

echo "LOG: Done! More backups for the backups god!"
