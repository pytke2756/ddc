#!/bin/bash

while getopts u:d:c:f: flag;
do
  case ${flag} in
    u) USER="$OPTARG";;
    d) DB_NAME="$OPTARG";;
    c) CONTAINER_NAME="$OPTARG";;
    f) FILE_NAME="$OPTARG";;
    *);;
  esac
done

if [ -n "$FILE_NAME" ]; then
  if [[ ! "$FILE_NAME" == *.dump ]]; then
    FILE_NAME+=".dump"
  fi
else
  CURRENT_DATE=$(date +"%Y-%m-%d")
  FILE_NAME="db-${CURRENT_DATE}.dump"
fi

shift $((OPTIND -1))

TARGET=$1

if [ -z "$TARGET" ]; then
  TARGET="."
fi

echo "user: $USER";
echo "db-name: $DB_NAME";
echo "container-name: $CONTAINER_NAME";
echo "file name: $FILE_NAME";
echo "target: $TARGET";

docker exec -it "${CONTAINER_NAME}" pg_dump -U "${USER}" -d "${DB_NAME}" -Fc -f "${FILE_NAME}" && docker cp "${CONTAINER_NAME}":"${FILE_NAME}" "${TARGET}"
ERROR_CODE=$?
if [ "$ERROR_CODE" -ne 0 ]; then
  echo "Error"
  exit 1
fi

exit 0