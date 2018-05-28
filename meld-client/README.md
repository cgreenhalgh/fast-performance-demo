# Meld Client

Clone
```
git clone https://github.com/cgreenhalgh/meld-client
(cd meld-client; git checkout climb)
```
(forked from https://github.com/oerc-music/meld-client)
(install docker)
then
```
sudo docker build -t meld-client .
sudo docker tag meld-client cgreenhalgh/meld-client
sudo docker tag meld-client cgreenhalgh/meld-client:20180528.1
```
```
sudo docker run -d --name=meld-client --restart=always -p 8080:8080 meld-client
```
