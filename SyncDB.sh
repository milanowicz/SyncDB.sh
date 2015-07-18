#!/bin/bash
####################################
####################################
##                                ##
##  MySQL Database Sync Script    ##
##                                ##
####################################
####################################
Version="0.9.4"
ScriptFilename="SyncDB.sh"
Error=0

if [ $# -eq 0 ]; then
    Error=1
else
    if [ "$1" == "version" ]; then
        Error=10
    elif [ "$1" == "script" ]; then
        Error=11
    elif [ "$1" == "license" ]; then
        Error=12
    fi
fi

# Set Username if empty
if [ -z ${Username} ]; then
    Username="root"
fi

# Set Password if empty
if [ -z ${Password} ]; then
    Password="123456"
fi

# Set Port if empty
if [ -z ${Port} ]; then
    Port="3306"
fi

# Set Hostname if empty
if [ -z ${Hostname} ]; then
    Hostname="127.0.0.1"
fi

# Set MySQLOptions if empty
if [ -z ${MySQLOptions} ]; then
    MySQLOptions=""
fi

if [ "$1" != "dumpfile" ] && [ "$1" != "syncfile" ]; then

    # Set DBPath if empty
    if [ -z ${DBPath} ]; then
        DBPath="db"
    fi

    if [ -z ${DBNames} ] && [ ${Error} -eq 0 ]; then
        DBNames=""
        echo -e "\nError: Variable DBNames is not set!"
        echo -e "export DBNames=\"<Project Name>\""
        Error=2
    fi

    # Set MySQLDB equal DBNames if is empty
    if [ -z ${MySQLDB} ]; then
        MySQLDB=${DBNames}
    fi

else

    # Set MySQLDB equal DBNames if is empty
    if [ -z ${MySQLDB} ]; then
        echo -e "\nError: Variable MySQLDB is not set!"
        echo -e "export MySQLDB=\"<MySQL Database>\""
        Error=3
    fi
fi


# Check the MySQL application binary
function GetBashPrompt () {

    Prompt=

    # Set Linux default if empty
    if [ -z ${PathBin} ]; then

        # Get absolute path to binrary file
        Prompt=`which $1`

        if [ -n ${Prompt} ]; then

            # Check if exists
            ls ${Prompt} > /dev/null 2> /dev/null

            if [ $? != 0 ]; then

                # Wenn das Kommando nicht gefunden wird,
                # dann Shell Skript abbrechen
                echo "Error: You do not have the application which, please enter your MySQL binrary path in the local.sh file!"
                exit 1

            fi
        fi
    fi

    # Set Prompt when it not be set
    if [ -z ${Prompt} ]; then

        # MySQL Kommando ermitteln
        ls ${PathBin}""$1> /dev/null 2> /dev/null

        # Pruefen ob Kommando vorhanden war
        if [ $? != 0 ]; then

            ls ${PathBin}"/"$1> /dev/null 2> /dev/null

            if [ $? != 0 ]; then

                # Wenn das Kommando nicht gefunden wird,
                # dann Shell Skript abbrechen
                echo "Error: You enter a wrong MySQL binrary path in the local.sh!"
                exit 1

            else
                Prompt=${PathBin}"/"$1
            fi
        else
            Prompt=${PathBin}""$1
        fi
    fi
}

# Pruefen ob Datenbank vorhanden ist ?
function CreateDatabase () {
    ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
        -e "CREATE DATABASE IF NOT EXISTS \`"${MySQLDB}"\`;"
}
# Pruefen ob Datenbank vorhanden ist, wenn ja dann loeschen
function DropDatabase () {
    ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
        -e "DROP DATABASE IF EXISTS \`"${MySQLDB}"\`;"
}


# ReadOnly Tabellen aus der Datei auslesen
ReadTableNames=
IgnoreTable=

if [ ${Error} -eq 0 ]; then
    ls ${DBPath}"/"${DBNames}"_ReadTable" > /dev/null 2> /dev/null
    if [ $? == 0 ]; then

        while read Line
        do
            ReadTableNames="${ReadTableNames} $Line"
        done < ${DBPath}"/"${DBNames}"_ReadTable"

        # ReadTableNames String mit --ignore-table verschachteln
        for Elem in ${ReadTableNames} ; do
            IgnoreTable="${IgnoreTable} --ignore-table=${MySQLDB}.$Elem"
        done

    fi
fi


# User Daten Tabellen aus der Datei auslesen
UserTableNames=
IgnoreUserDataTable=

if [ ${Error} -eq 0 ]; then

    ls ${DBPath}"/"${DBNames}"_UserTable" > /dev/null 2> /dev/null

    if [ $? == 0 ]; then

        while read Line
        do
            UserTableNames="${UserTableNames} $Line"
        done < ${DBPath}"/"${DBNames}"_UserTable"

        # UserTableNames String mit --ignore-table verschachteln
        for Elem in ${UserTableNames} ; do
            IgnoreUserDataTable="${IgnoreUserDataTable} --ignore-table=${MySQLDB}.$Elem"
        done

    fi
fi


# Auf Fehler pruefen
if [ ${Error} -gt 1 ] && [ ${Error} -lt 10 ]; then

    echo -e "Error in SyncDB.sh!"
    
# SQL Dumps in die MySQL Datenbank einspielen
elif [ "$1" == "sync" ]; then

    # MySQLDump Kommando ermitteln
    GetBashPrompt "mysql"
    CreateDatabase

    # Datenbank ReadOnly Tabellen importieren, 
    # falls ReadOnly Tabellen vorhanden sind
    if [ -n "${IgnoreTable}" ]; then
        
        ls ${DBPath}"/"${DBNames}"_ReadOnly.sql" > /dev/null 2> /dev/null
        
        if [ $? == 0 ]; then
            echo "Import of readonly table structure . . ."
            # Wenn etwas fehlschaegt, bedeutet es das die Tabelle schon erstellt ist
            ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
                --database=${MySQLDB} < ${DBPath}"/"${DBNames}"_ReadOnly.sql"
    
        else
            echo "Error: ${DBPath}/${DBNames}_ReadOnly.sql not found !"
    
        fi
    fi


    # Benutzer Daten importieren bei Angabe des Parameters
    if [ "$2" == "user" ]; then

        # Tabellen Struktur vom Benutzer importieren
        ls ${DBPath}/${DBNames}"_UserStructure.sql" > /dev/null 2> /dev/null
        if [ $? == 0 ]; then

            echo "Import of user table structure . . ."
            ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
                --database=${MySQLDB} < ${DBPath}"/"${DBNames}"_UserStructure.sql" || exit

        fi

        # Daten vom Benutzer importieren
        ls ${DBPath}/${DBNames}"_UserData.sql" > /dev/null 2> /dev/null
        if [ $? == 0 ]; then
            echo "Import of user data . . ."
            ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
                --database=${MySQLDB} < ${DBPath}"/"${DBNames}"_UserData.sql" || exit
        fi
    fi


    # Datenbank Struktur importieren
    ls ${DBPath}/${DBNames}"_Structure.sql" > /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        echo "Import of table structure . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --database=${MySQLDB} < ${DBPath}"/"${DBNames}"_Structure.sql" || exit

    else
        echo "Error: ${DBPath}/"${DBNames}"_Structure.sql not found !"

    fi


    # Datenbank Daten importieren
    ls ${DBPath}/${DBNames}"_Data.sql" > /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        echo "Import of data . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --database=${MySQLDB} < ${DBPath}"/"${DBNames}"_Data.sql" || exit

    else
        echo "Error: ${DBPath}/"${DBNames}"_Data.sql not found !"

    fi


# Datenbank in SQL Dumps sichern
elif [ "$1" == "dump" ]; then

    # MySQLDump Kommando ermitteln
    GetBashPrompt "mysqldump"

    
    # Datenbank ReadOnly Tabellen exportieren
    if [ -n "${IgnoreTable}" ]; then

        # Sichere die ReadOnly Tabellen Struktur
        # - ohne Daten
        # - ohne Kommentare
        # - Ersetze keine Tabellen die schon vorhanden sind (Wichtig !)
        # - ohne Trigger Tabellen
        # | Entferne die AUTO_INCREMENTs von der ReadOnly Struktur
        echo "Dump of readonly table structure . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --no-data \
            --comments=FALSE \
            --add-drop-table=FALSE \
            --skip-triggers \
            ${MySQLOptions} ${IgnoreUserDataTable} ${MySQLDB} ${ReadTableNames} | \
            sed -e 's/ AUTO_INCREMENT=[0-9]*//' > ${DBPath}"/"${DBNames}"_ReadOnly.sql" || exit

    fi


    # Datenbank ReadOnly Tabellen exportieren
    if [ "$2" == "user" ] && [ -n "${IgnoreUserDataTable}" ]; then

        # Sichere die ReadOnly Tabellen Struktur von den Benutzer Daten
        # - ohne Daten
        # - ohne Kommentare
        # - Ersetze keine Tabellen die schon vorhanden sind (Wichtig !)
        # - ohne Trigger Tabellen
        # | Entferne die AUTO_INCREMENTs von der ReadOnly Struktur
        echo "Dump of user table structure . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --no-data \
            --comments=FALSE \
            --skip-triggers \
            ${MySQLOptions} ${MySQLDB} ${UserTableNames} | \
            sed -e 's/ AUTO_INCREMENT=[0-9]*//' > ${DBPath}"/"${DBNames}"_UserStructure.sql" || exit

        # Sichern der Benutzer Daten von der Datenbank
        # - ohne Tabellen Struktur
        # - ohne Kommentare
        # - Sortiert nach Primary Keys (wegen Git Diffs)
        # - Eine Zeile pro INSERT (wegen Git Diffs)
        # - Komplette INSERT Syntax mit Spaltennamen
        # - Ohne ReadOnly Tabellen
        echo "Dump of user data . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --no-create-info \
            --comments=FALSE \
            --order-by-primary \
            --extended-insert=FALSE \
            --complete-insert \
            ${MySQLOptions} ${IgnoreTable} ${MySQLDB} ${UserTableNames} > ${DBPath}"/"${DBNames}"_UserData.sql" || exit

    fi


    # Exportieren der Tabellen Struktur fuer die Daten
    # - ohne Daten
    # - ohne Kommentare
    # - ohne Trigger Tabellen
    # - ohne ReadOnly Tabellen sichern
    # | Entferne die AUTO_INCREMENTs von der Struktur
    echo "Dump of table structure . . ."
    ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
        --no-data \
        --comments=FALSE \
        --skip-triggers \
        ${MySQLOptions} ${IgnoreTable} ${IgnoreUserDataTable} ${MySQLDB} | \
        sed -e 's/ AUTO_INCREMENT=[0-9]*//' > ${DBPath}"/"${DBNames}"_Structure.sql" || exit


    # Sichern der Daten von der Datenbank
    # - ohne Tabellen Struktur
    # - ohne Kommentare
    # - Sortiert nach Primary Keys (wegen Git Diffs)
    # - Eine Zeile pro INSERT (wegen Git Diffs)
    # - Komplette INSERT Syntax mit Spaltennamen
    # - Ohne ReadOnly Tabellen    
    echo "Dump of data . . ."
    ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
        --no-create-info \
        --comments=FALSE \
        --order-by-primary \
        --extended-insert=FALSE \
        --complete-insert \
        ${MySQLOptions} ${IgnoreTable} ${IgnoreUserDataTable} ${MySQLDB} > ${DBPath}"/"${DBNames}"_Data.sql" || exit


# Komplette Datenbank in SQL Dumps sichern
elif [ "$1" == "dumpfull" ]; then

    # MySQLDump Kommando ermitteln
    GetBashPrompt "mysqldump"
        
    # Datenbank ReadOnly Tabellen exportieren
    if [ -n "${IgnoreTable}" ]; then

        # Sichere die ReadOnly Tabellen Struktur
        # - ohne Daten
        # - ohne Kommentare
        # - Ersetze keine Tabellen die schon vorhanden sind (Wichtig !)
        # - ohne Trigger Tabellen
        echo "Dump of readonly table structure . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --no-data \
            --comments=FALSE \
            --add-drop-table=FALSE \
            --skip-triggers \
            ${MySQLOptions} ${MySQLDB} ${ReadTableNames} > ${DBPath}"/"${DBNames}"_Full.sql" || exit

    fi


    # Sichern der Daten von der Datenbank    
    # - Sortiert nach Primary Keys (wegen Git Diffs)
    # - ohne Kommentare
    # - Eine Zeile pro INSERT (wegen Git Diffs)
    # - Komplette INSERT Syntax mit Spaltennamen
    # - Ohne ReadOnly Tabellen
    # | Entferne die AUTO_INCREMENTs von der ReadOnly Struktur
    echo "Dump of all data with user data . . ."
    ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
        --order-by-primary \
        --comments=FALSE \
        --complete-insert \
        ${MySQLOptions} ${IgnoreTable} ${MySQLDB} | \
        sed -e 's/ AUTO_INCREMENT=[0-9]*//' >> ${DBPath}"/"${DBNames}"_Full.sql" || exit


# Komplette Datenbank in SQL Dumps sichern
elif [ "$1" == "dumpcomplete" ] || [ "$1" == "dumpfile" ]; then

    Filename=
    Options=
    if [ "$1" == "dumpcomplete" ]; then
        Filename=${DBPath}"/"${DBNames}"_Complete.sql"
        Options="--order-by-primary"
    else
        Filename=$2
    fi

    # Pruefen auf Dateiname
    if [ -n ${Filename} ]; then

        # MySQL Prompt
        GetBashPrompt "mysqldump"

        # Sichern der Daten von der Datenbank
        # - Sortiert nach Primary Keys (wegen Git Diffs)
        echo "Dump complete database with all in it . . ."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            ${Options} ${MySQLOptions} ${MySQLDB} > ${Filename} || exit
    fi


# Komplette Datenbank zurueck in die MySQL Datenbank spielen
elif [ "$1" == "syncfile" ]; then

    # Datei pruefen
    Filename=
    ls $2 > /dev/null 2> /dev/null
    if [ $? != 0 ]; then

        ls $2".sql" > /dev/null 2> /dev/null

        if [ $? == 0 ]; then
            Filename=$2".sql"

        else
            echo "Error: File $2 not found!"
        fi

    else
        Filename=$2

    fi

    # Pruefen auf Dateiname
    if [ -n ${Filename} ]; then

        # MySQLDump Kommando ermitteln
        GetBashPrompt "mysql"
        DropDatabase
        CreateDatabase

        # Datenbank importieren
        echo "Import of "${Filename}" SQL file ..."
        ${Prompt} -u ${Username} -p${Password} -h ${Hostname} -P ${Port} \
            --database=${MySQLDB} < ${Filename} || exit
    fi


else
    # Es wurde wahrscheinlich nicht der richtige Parameter angegeben
    if [ ${Error} -lt 10 ]; then
        Error=1
    fi
fi


# Hilfe Ausgabe der Skript Parameter
if [ ${Error} -eq 1 ]; then
    echo -e "\n###############################################################################"
    echo -e "#"
    echo -e "#\t     MySQL synchronisation and dumping BASH shell script"
    echo -e "#"
    echo -e "#\t\t\t\tVersion "${Version}
    echo -e "#"
    echo -e "###############################################################################"
    echo -e "#"
    echo -e "#   Param\t\t\tDescription"
    echo -e "#"
    echo -e "#------------------------------------------------------------------------------"
    echo -e "#"
    echo -e "#   sync\t\t\tDatabase sync"
    echo -e "#   sync user\t\t\tDatabase sync with User Data"
    echo -e "#"
    echo -e "#   dump\t\t\tDatabase dump"
    echo -e "#   dump user\t\t\tDatabase dump with User Data"
    echo -e "#"
    echo -e "#   dumpfull\t\t\tGenerate one file from five files"
    echo -e "#"
    echo -e "#------------------------------------------------------------------------------"
    echo -e "#"
    echo -e "#   syncfile <Filename>\t\tInsert SQL Backup file into an new Database"
    echo -e "#   dumpfile <Filename>\t\tGenerate SQL Backup from Database into file"
    echo -e "#"
    echo -e "#   dumpcomplete\t\tGenerate a SQL file order by primary keys"
    echo -e "#"
    echo -e "#------------------------------------------------------------------------------"
    echo -e "#"
    echo -e "#   license\t\t\tLicense from shell script"
    echo -e "#   script\t\t\tFilename from shell script"
    echo -e "#   version\t\t\t${ScriptFilename} Version"
    echo -e "#"
    echo -e "###############################################################################\n"
elif [ ${Error} -eq 10 ]; then
    echo ${Version}
elif [ ${Error} -eq 11 ]; then
    echo ${ScriptFilename}
elif [ ${Error} -eq 12 ]; then
    echo "GNU GPL Version 3"
fi