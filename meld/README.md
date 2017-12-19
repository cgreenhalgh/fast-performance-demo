# Meld

Hmm. Meld won't work on virtual box fs folder (rename fails).

Dockerise...?!

```
git clone https://github.com/oerc-music/meld
```
(docker -see below)
```
sudo docker build -t meld .
```
run
```
sudo docker run -d --name=meld --restart=always -p 5000:5000 meld
```

update score files
```
sudo docker cp meld/server/mkGameEngine-meld.json meld:/root/work/
sudo docker exec meld python generate_climb_scores.py mkGameEngine-meld.json score
```



## docker

See [docs](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository)
```
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, 
```
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
```
Optional,
```
sudo docker run hello-world
```



