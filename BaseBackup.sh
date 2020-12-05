#!/bin/bash

# My base backup script.
# It is supposed to backup select folders with configs and stuff.
# Written on Xubuntu 20.04

# This is a list of files and directories to back up
FILES="$HOME/Soft $HOME/.newsboat $HOME/.config $HOME/.bashrc $HOME/Pictures"

# I only need one subfolder, Dropbox.
# Since I don't create it automatically, I have a separate list with Dropbox folders I need to back up.
# The purpose of backing up Dropbox is that I don't have to wait for it to sync to start
# using scripts and bashrc extensions that are located on Dropbox.
DROPBOX="$HOME/Dropbox/0.Workbench $HOME/Dropbox/5.Configs"

# It is a simple naming that avoids overwriting.
# Base-2020Nov27-131226
# Base-YYYYMonDD-HHMMSS
TMPNAME=Base-$(date +%Y%b%d-%H%M%S)
TEMPDIR=/tmp/$TMPNAME
MASTERDIR=$(hostname)-Backup-$(date +%Y%b%d)

# If an SSD is connected and mounted, use it as a backup drive.
# If not, just put the backup on Desktop.
# -e checks if file exists. -f checks if file exists and if it is file, not a directory/link.
if [ -e /media/$USER/Data/B.Backups ]
then
    echo "LOG: Backup SSD is connected. Using the backups folder!"
    DEST=/media/$USER/Data/B.Backups/$MASTERDIR
else
    echo "WARNING: Backup SSD is NOT connected. Saving to the Desktop!"
    DEST=$HOME/Desktop/$MASTERDIR
fi

[ ! -e $DEST ] && echo "LOG: Creating today's backup folder $DEST..." && mkdir $DEST

echo "LOG: Creating directory $TEMPDIR..."
[ -e $TEMPDIR ] && rm -rf $TEMPDIR
mkdir $TEMPDIR

# Checking if I have to backup any Dropbox stuff up.
# If so, creating a subdirectory for it. Otherwise, printing a warning message.
[ ! -z "$DROPBOX" ] && mkdir $TEMPDIR/Dropbox || echo "WARNING: DROPBOX variable is not set. Not backing any dropbox stuff up!"

# Copying the necessary files and folders to the temp folder and saving the rsync output to log file.
# In case I back up the ~/Soft folder, I have an --exclude in place to avoid backing up the Arduino IDE.
echo "LOG: Copying folders of interest into $TEMPDIR"
rsync -av --exclude="*arduino*" $FILES $TEMPDIR >> $DEST/$TMPNAME.log
[ ! -z "$DROPBOX" ] && rsync -av $DROPBOX $TEMPDIR/Dropbox >> $DEST/$TMPNAME.log

# Gzipping the temp folder and saving it to SSD or Desktop, saving tar output to log file.
# I enter the directory so I don't end up tarring the /tmp folder.
# Maybe it has something to do with the flags I blindly copied from stackoverflow.
echo "LOG: Tarring everything up and saving to $DEST/$TMPNAME"
cd /tmp
tar -cvzpf $DEST/$TMPNAME.tar.gz $TMPNAME >> $DEST/$TMPNAME.log
cd

echo "LOG: Cleaning up..."
rm -rf $TEMPDIR
echo "LOG: Done! More backups for the backups god!"
