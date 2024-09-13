#!/bin/bash

while getopts u:d:c:p:s: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
    p) PORT="$OPTARG";;
    *);;
  esac
done

if [ -z $PORT ]; then
  PORT="5432"
fi

shift $((OPTIND -1))

SOURCE=$1

if [[ $SOURCE =~ /([^/]+)\.([^/]+[dump])$ ]]; then
  FILE_NAME=${BASH_REMATCH[1]}.${BASH_REMATCH[2]}
else
  SOURCE="./db.dump"
  FILE_NAME="db.dump"
fi

echo "user: $USER";
echo "db-name: $DB_NAME";
echo "container-name: $CONTAINER_NAME";
echo "port: $PORT";
echo "source: $SOURCE";
echo "file-name: $FILE_NAME";

docker cp ${SOURCE} "${CONTAINER_NAME}":/ && docker exec -it "${CONTAINER_NAME}" pg_restore -p 5432 --if-exists -c -U "${USER}" -d "${DB_NAME}" ${FILE_NAME}

exit 1