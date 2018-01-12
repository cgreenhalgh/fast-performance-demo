if ! [ -d "musiccodes" ]; then
	echo 'Please install musiccodes'
	exit -1
fi


if ! [ -d "meld/meld" ]; then
	echo 'Please install meld'
	exit -1
fi

if ! [ -d "meld-client/meld-client" ]; then
	echo 'Please install meld-client'
	exit -1
fi

if ! [ -d "music-performance-manager" ]; then
echo 'Please install music-performance-manager'
exit -1
fi


if ! [ -d "musiccodes/server/public/content" ]; then
	mkdir musiccodes/server/public/content
fi

#cp mei-files/*.mei musiccodes/server/public/content/
if ! [ -d "mei-files/out" ]; then
	mkdir mei-files/out
fi

cp images/* musiccodes/server/public/content/

cd scoretools
npm install --no-bin-links

node lib/makemuzicodes.js test/mkGameEngine-config.yml
cp test/mkGameEngine-out.json ../musiccodes/server/experiences/
cp test/mkGameEngine-view.json ../musiccodes/server/public/content/
cp test/mkGameEngine-meld.json ../meld/meld/server/
cd ..
cp mei-files/out/*.mei musiccodes/server/public/content/
#cp mei-files/*.mei musiccodes/server/public/content/

# keep old logs
sudo docker exec meld /bin/sh -c 'du -sk sessions'
sudo docker cp meld:/root/work/sessions/ meld/sessions/

sudo docker cp meld/meld/server/mkGameEngine-meld.json meld:/root/work/
sudo docker exec meld python generate_climb_scores.py mkGameEngine-meld.json score
