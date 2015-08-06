# [SyncDB.sh](https://github.com/Milanowicz/SyncDB.sh)

A Git optimized BASH Shell Script to dump or insert from MySQL Database, and commit it into the repository.


## Install

Set parameter for the SyncDB.sh script to do the job.

    Project/local.sh

    Project/db/SyncDB.sh


## General Usage

Show license from SyncDB.sh script.

    $ . local.sh license

Show script filename

    $ . local.sh script
    
Show script version

    $ . local.sh version
    

## Develop usage

Insert Sql files into the Database.

    $ . local.sh sync

Insert Sql files into the Database with User data.

    $ . local.sh sync user

Dump Database into Sql dump files.

    $ . local.sh dump

Dump Database into Sql dump files with User data.

    $ . local.sh dump user

Generate one file from five files.

    $ . local.sh dumpfulle


## Special operations

Dump Database into the Database SQL file.

    $ . local.sh dumpfile <Filename>

Insert SQL Backup file into the Database back.

    $ . local.sh syncfile <Filename>

Complete SQL Database Backup file and order by primary keys.

    $ . local.sh dumpcomplete


## License

[GNU GPL Version 3](http://www.gnu.org/copyleft/gpl.html)