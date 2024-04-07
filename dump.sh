#!/bin/sh

while getopts u:d:c:t: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
    t) TARGET="$OPTARG";;
    *);;
  esac
done

echo "user: $USER";
echo "db-name: $DB_NAME";
echo "container-name: $CONTAINER_NAME";
echo "target: $TARGET (TODO)";


docker exec -it "${CONTAINER_NAME}" pg_dump -U "${USER}" -d "${DB_NAME}" -Fc -f db.dump && docker cp "${CONTAINER_NAME}":db.dump .