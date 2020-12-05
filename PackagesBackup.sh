#!/bin/bash

# My packages backup script.
# It is supposed to backup installed packages and repos.
# Written on Xubuntu 20.04

# It is a simple naming that avoids overwriting.
# Pkg-2020Nov27-131226
# Pkg-YYYYMonDD-HHMMSS
TMPNAME=Pkg-$(date +%Y%b%d-%H%M%S)
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

# If today's folder doesn't exist, create one.
[ ! -e $DEST ] && echo "LOG: Creating today's backup folder $DEST..." && mkdir $DEST
[ ! -e $DEST/Logs ] && echo "LOG: Creating today's log folder $DEST/Logs..." && mkdir $DEST/Logs

# Copying repos into 
echo "LOG: Copying folders of interest into $DEST/$TMPNAME"
mkdir $DEST/$TMPNAME
rsync -av /etc/apt/sources.list* $DEST/$TMPNAME >> $DEST/Logs/$TMPNAME.log

echo "LOG: Saving the list of installed packages to $DEST/$TMPNAME/$TMPNAME.packages"
dpkg --get-selections > $DEST/$TMPNAME/$TMPNAME.packages

echo "LOG: Exporting APT keys to $DEST/$TMPNAME/$TMPNAME.keys"
apt-key exportall > $DEST/$TMPNAME/$TMPNAME.keys 2> /dev/null

echo "LOG: Done! More backups for the backups god!"
