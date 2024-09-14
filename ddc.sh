#!/bin/bash

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

while getopts u:p:d:f:g:c:t: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    p) PASSWORD="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    f) FROM_CONTAINER_NAME="$OPTARG";;
    g) TO_CONTAINER_NAME="$OPTARG";;
    t) PORT="$OPTARG";;
    *) ;;
  esac
done

if [ -z "$PORT" ]; then
  PORT="5432"
fi

echo "user: $USER";
echo "password: $PASSWORD";
echo "db-name: $DB_NAME-db";
echo "from-container-name: $FROM_CONTAINER_NAME"
echo "to-container-name: $TO_CONTAINER_NAME"
echo "port: $PORT"

DEFAULT_FILE_NAME="db.dump"

PATH_TO_FILE="."
echo '-------------------------------------'
./dump.sh -u "${USER}" -d "${DB_NAME}" -c "${FROM_CONTAINER_NAME}" -f "${DEFAULT_FILE_NAME}" "${PATH_TO_FILE}"
docker stop "${FROM_CONTAINER_NAME}"
sleep 1

if [ -z "$TO_CONTAINER_NAME" ]; then
  CURRENT_DATE=$(date +"%Y-%m-%d")
  TO_CONTAINER_NAME="${FROM_CONTAINER_NAME}-${CURRENT_DATE}"
fi

IMAGE=$(docker create --name "${TO_CONTAINER_NAME}" -e POSTGRES_USER="${USER}" -e POSTGRES_PASSWORD="${PASSWORD}" -e POSTGRES_DB="${DB_NAME}" -p "${PORT}:5432" db)

if [ -z "$IMAGE" ]; then
  exit 1;
fi
sleep 3
docker start "${TO_CONTAINER_NAME}"
sleep 3

./restore.sh -u "${USER}" -d "${DB_NAME}" -c "${TO_CONTAINER_NAME}" -p "${PORT}"


# docker exec -it ${FROM_CONTAINER_NAME} psql -U ${USER} -d ${DB_NAME} -c "INSERT INTO kor (id, ember_id, kor) VALUES ('2', '2', '4444');"
# exit_codes $?


# docker exec -it ${FROM_CONTAINER_NAME} pg_dump -U ${USER} -d ${DB_NAME} -Fc -f db.dump && docker cp ${FROM_CONTAINER_NAME}:db.dump .
# sleep 1;

# docker stop ${FROM_CONTAINER_NAME}
# docker start ${CONTAINER_WITH_TIME}
# exit_codes $?
# docker_watch "$CONTAINER_WITH_TIME"
# docker cp db.dump ${CONTAINER_WITH_TIME}:/
# sleep 1
# if [ -z "$PORT" ]; then
#   docker exec -it ${CONTAINER_WITH_TIME} pg_restore --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
# else
#   docker exec -it ${CONTAINER_WITH_TIME} pg_restore -p '5432' --if-exists -c -U ${USER} -d ${DB_NAME} db.dump
# fi