if ! [ -d "musiccodes" ]; then
	echo 'Please install musiccodes'
	exit -1
fi


if ! [ -d "meld" ]; then
	echo 'Please install meld'
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
cp test/mkGameEngine-meld.json ../meld/server/
cd ..
#cp mei-files/out/*.mei musiccodes/server/public/content/
cp mei-files/*.mei musiccodes/server/public/content/

IP="127.0.0.1"
export MELD_BASE_URI=http://${IP}:5000
export MELD_MEI_URI=http://${IP}:3000/content
export MELD_SCORE_URI="http://${IP}:5000/score"

(cd meld/server; python generate_climb_scores.py mkGameEngine-meld.json /vagrant/meld/server/score/)
