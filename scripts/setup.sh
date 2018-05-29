
cp images/* volumes/content/

docker run --rm -v `pwd`/scoretools/test:/srv/scoretools/test -v `pwd`/mei-files:/srv/mei-files scoretools

cp scoretools/test/mkGameEngine-out.json volumes/experiences/
cp scoretools/test/mkGameEngine-view.json volumes/content/
cp scoretools/test/mkGameEngine-meld.json volumes/score/
cp mei-files/out/*.mei volumes/content/
#cp mei-files/*.mei volumes/content/

#sudo docker cp meld/meld/server/mkGameEngine-meld.json meld:/root/work/
sudo docker exec vagrant_meld_1 python generate_climb_scores.py score/mkGameEngine-meld.json score
