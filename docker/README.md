# Climb docker stuff

Mainly a muzicode instance with the right content and experience.

```
mkdir content
mkdir experiences
cp ../images/* content/
cp ../scoretools/test/mkGameEngine-out.json experiences/
cp ../scoretools/test/mkGameEngine-view.json content/
cp ../mei-files/out/*.mei content/
```

## Docker

To build separately (not normally required)
```
docker build -t climb .
```


To start:
```
docker-compose up -d
```
To check debug output:
```
docker-compose logs
```
To stop:
```
docker-compose stop
```

