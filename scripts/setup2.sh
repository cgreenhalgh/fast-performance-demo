if ! [ -d "musiccodes" ]; then
	echo 'Please install musiccodes'
	exit -1
fi


if ! [ -d "meld" ]; then
	echo 'Please install meld'
	exit -1
fi

if ! [ -d "musiccodes/server/public/content" ]; then
	mkdir musiccodes/server/public/content
fi

cp mei-files/*.mei musiccodes/server/public/content/
cp images/* musiccodes/server/public/content/

cd scoretools
npm install --no-bin-links

node lib/makemuzicodes.js test/mkGameEngine2-config.yml
cp test/mkGameEngine2-out.json ../musiccodes/server/experiences/


