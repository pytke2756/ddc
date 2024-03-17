#!/bin/sh

exit_codes() {
  if [ "$1" -ne "0" ]; then
    echo "error";
    exit 1;
  fi
}

docker_check() {
  TRY=$(echo "$1" | sed -n "/$2.*Up*/p")
  echo "$TRY";
  if [ -n "$TRY" ]; then
    return 0
  else
    return 1
  fi
}

docker_watch() {
  while true ; do
    CONTAINERS=$(watch -n 1 -g docker container ls -a --format '{{.Names}}\\t{{.Status}}' &)
      if docker_check "$CONTAINERS" "$1"; then
        echo "Container running"
        break;
      fi
  done
}

while getopts u:p:d:c:t: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    p) PASSWORD="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
    t) PORT="$OPTARG";;
    *) ;;
  esac
done

echo "user: $USER";
echo "password: $PASSWORD";
echo "db-name: $DB_NAME-db";
echo "container-name: $CONTAINER_NAME"
echo "port: $PORT"

CURRENT_DATE=$(date +"%Y-%m-%d")
CONTAINER_WITH_TIME="${CONTAINER_NAME}-${CURRENT_DATE}"

docker exec -it ${CONTAINER_NAME} psql -U ${USER} -d ${DB_NAME} -c "INSERT INTO kor (id, ember_id, kor) VALUES ('2', '2', '4444');"
exit_codes $?

if [ -z "$PORT" ]; then
  IMAGE=$(docker create --name ${CONTAINER_WITH_TIME} -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASSWORD} -e POSTGRES_DB=${DB_NAME} -p "5888:5432" db)
else
  IMAGE=$(docker create --name ${CONTAINER_WITH_TIME} -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASSWORD} -e POSTGRES_DB=${DB_NAME} -p "${PORT}:5432" db)
fi

if [ -z "$IMAGE" ]; then
  exit 1;
fi

docker exec -it ${CONTAINER_NAME} pg_dump -U ${USER} -d ${DB_NAME} -Fc -f db.dump && docker cp ${CONTAINER_NAME}:db.dump .
sleep 1;

docker stop ${CONTAINER_NAME}
docker start ${CONTAINER_WITH_TIME}
exit_codes $?
docker_watch "$CONTAINER_WITH_TIME"
docker cp db.dump ${CONTAINER_WITH_TIME}:/
sleep 1
if [ -z "$PORT" ]; then
  docker exec -it ${CONTAINER_WITH_TIME} pg_restore --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
else
  docker exec -it ${CONTAINER_WITH_TIME} pg_restore -p '5432' --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
fi