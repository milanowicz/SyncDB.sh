#!/bin/bash
# MySQL Settings
export Username="<user>"
export Password="<password>"
# Optional
export Hostname="127.0.0.1"
# Optional
export Port="3306"

# Path to db path
export DBPath="db"

# Optional: Path to mysql binary
export PathBin=""
# Mac   -> /Applications/XAMPP/bin/
# Linux -> /usr/bin/
# Win   -> C:/xampp/mysql/bin/

# File DB Name at repo
export DBNames="<Project Name>"

# Optional: Real MySQL Databasename
export MySQLDB="<Real Database Name>"

# Example and Optional: complete insert SQL, skip Timezone, skip Charset, skip Comments
export MySQLOptions="--complete-insert --skip-tz-utc --skip-set-charset --skip-comments"

# Sync script
${DBPath}/SyncDB.sh $1 $2