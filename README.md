# Docker database cloning (DDC)

## Files
- `init.sql`: Creates two tables with sample data.
- `Dockerfile`: Generates the demo Docker image. This is needed solely for the demo data requirements.
- `ddc.sh`: Script for cloning the database.
- `dump.sh`: Creates a data dump from the specified Docker container's database.
- `restore.sh`: Loads the dumped data into the specified Docker container's database.

## Demo
0. Ensure Docker is running on your machine.
```shell
1. foo@bar:~$ docker build -t db .
```

```shell
2. foo@bar:~$ docker run --name db1 -p 5888:5432 -e POSTGRES_USER=user -e POSTGRES_DB=my-db -e POSTGRES_PASSWORD=pass -d db
```

```shell
#Dump and restore
3. foo@bar:~$ ./ddc.sh -u user -p pass -d my-db -f db1 ([OPTIONAL] -g db2) ([OPTIONAL] -t '5432')
```

```shell
#Dump
foo@bar:~$ ./dump.sh -u user -p pass -d my-db -c db1 data.dump
```

```shell
#Restore
foo@bar:~$ ./restore.sh -u user -d my-db -c db1 data.dump
```