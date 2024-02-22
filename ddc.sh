#!/bin/sh

while getopts u:p:d:c: flag; 
do
  case ${flag} in
    u) USER="$OPTARG";;
    p) PASSWORD="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
  esac
done

echo "user: $USER";
echo "password: $PASSWORD";
echo "db-name: $DB_NAME-db";
echo "container-name: $CONTAINER_NAME"

CURRENT_DATE=$(date +"%Y-%m-%d")
CONTAINER_WITH_TIME="${CONTAINER_NAME}-${CURRENT_DATE}"

docker exec -it ${CONTAINER_NAME} psql -U ${USER} -d ${DB_NAME} -c "INSERT INTO kor (id, ember_id, kor) VALUES ('2', '2', '4444');"

docker create --name ${CONTAINER_WITH_TIME}  -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASSWORD} -e POSTGRES_DB=${DB_NAME} -p '5888:5432' db
sleep 5
docker exec -it ${CONTAINER_NAME} pg_dump -U ${USER} -d ${DB_NAME} -Fc -f db.dump && docker cp ${CONTAINER_NAME}:db.dump .
sleep 5
docker stop ${CONTAINER_NAME}
docker start ${CONTAINER_WITH_TIME}
sleep 5
docker cp db.dump ${CONTAINER_WITH_TIME}:/


docker exec -it ${CONTAINER_WITH_TIME} pg_restore --if-exists -c -U ${USER} -d ${DB_NAME} db.dump