# Docker database cloning (DDC)

## Files
- `init.sql`: létrehoz 2 táblát adatokkal
- `Dockerfile`: a demo docker image-t lehet belőle legenerálni. Csak azért szükséges ezt használni mert szükségesek a demo adatok
- `dbc.sh`: script a másoláshoz

## Demo
0. Docker fusson a gépen
```shell
1. foo@bar:~$ docker build -t db .
```

```shell
2. foo@bar:~$ docker run --name db1 -p 5888:5432 -e POSTGRES_USER=user -e POSTGRES_DB=my-db -e POSTGRES_PASSWORD=pass -d db
```

```shell
3. foo@bar:~$ ./linux-argument.sh -u user -p pass -d my-db -f db1 ([OPTIONAL] -g db2) ([OPTIONAL] -t '5678')
```