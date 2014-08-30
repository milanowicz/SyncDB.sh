# Database Bash Shell Script

A Git optimized BASH Shell Script to dump or insert from MySQL Database, and commit it into the repository.


## Install

Set parameter for the SyncDB.sh script to do the job.

    Project/local.sh

    Project/db/SyncDB.sh


## Develop usage

Insert Sql files into the Database.

    $ . local.sh sync

Insert Sql files into the Database with User data.

    $ . local.sh sync user

Dump Database into Sql dump files.

    $ . local.sh dump

Dump Database into Sql dump files with User data.

    $ . local.sh dump user


## Special operations

Insert SQL Backup file into the Database back.

    $ . local.sh full <Filename>

Generate one file from five files.

    $ . local.sh dumpfull

Complete SQL Database Backup file.

    $ . local.sh dumpcomplete


## License

[GNU GPL Version 3](http://www.gnu.org/copyleft/gpl.html)