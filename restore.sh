#!/bin/sh

while getopts u:d:c:p:s: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
    p) PORT="$OPTARG";;
    s) SOURCE="$OPTARG";;
    *);;
  esac
done

echo "user: $USER";
echo "db-name: $DB_NAME";
echo "container-name: $CONTAINER_NAME";
echo "port: $PORT";
echo "source: $SOURCE (TODO)";

if [ -z "$PORT" ]; then
  docker cp db.dump ${CONTAINER_NAME}:/ && docker exec -it ${CONTAINER_NAME} pg_restore --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
else
  docker cp db.dump ${CONTAINER_NAME}:/ && docker exec -it ${CONTAINER_NAME} pg_restore -p '5432' --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
fi