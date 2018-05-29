
# keep old logs
sudo docker exec vagrant_meld_1 /bin/sh -c 'du -sk sessions'
sudo docker cp vagrant_meld_1:/root/work/sessions/ logs/sessions

