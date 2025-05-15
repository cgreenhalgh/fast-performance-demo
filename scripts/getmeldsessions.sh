
# keep old logs
sudo docker exec vagrant-meld-1 /bin/sh -c 'du -sk sessions'
sudo docker cp vagrant-meld-1:/root/work/sessions/ logs/sessions

