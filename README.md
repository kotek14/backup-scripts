# backup-scripts

My very own backup scripts. Built with Xubuntu 20.04 in mind.

### Backup structure

```
hostname-Backup-YYYYMonDD/
├── Base-YYYYMonDD-HHMMSS.tar.gz
├── Full-YYYYMonDD-HHMMSS.tar.gz
├── Logs/
│   ├── Base-YYYYMonDD-HHMMSS.log
│   ├── Full-YYYYMonDD-HHMMSS.log
│   └── Pkg-YYYYMonDD-HHMMSS.log
└── Pkg-YYYYMonDD-HHMMSS/
    ├── Pkg-YYYYMonDD-HHMMSS.keys
    ├── Pkg-YYYYMonDD-HHMMSS.packages
    ├── sources.list
    ├── sources.list.save
    └── sources.list.d/
 ```

### The scripts

#### PackagesBackup.sh (PackagesRestore.sh)
Used for backing up the list of installed packages and APT repositories.

Syntax: `bash PackagesBackup.sh` and `sudo bash PackagesRestore.sh /path/to/backup/folder`

#### BaseBackup.sh (BaseRestore.sh)
Used for backing up some critical files and folders (such as configs). The goal is to get the system configured without spending a long time backing up everything.

Syntax: `bash BaseBackup.sh` and `sudo bash BaseRestore.sh /path/to/backup/folder`

#### FullBackup.sh
Used for making a full copy of the home directory. Takes a long time. Didn't feel the need to write a Restore script for it. It's more of a "store a large archive of data in case you'll need to pull something from it one day" kind of thing.

Syntax: `bash FullBackup.sh`
