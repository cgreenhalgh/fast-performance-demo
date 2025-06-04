
copy images\* volumes\content\

rem powershell
rem docker run --rm -v "${pwd}/scoretools/test:/srv/scoretools/test" -v "${pwd}/mei-files:/srv/mei-files" cgreenhalgh/scoretools
rem bat/command
docker run --rm -v "%cd%/scoretools/test:/srv/scoretools/test" -v "%cd%/mei-files:/srv/mei-files" cgreenhalgh/scoretools

copy scoretools\test\mkGameEngine-out.json volumes\experiences\
copy scoretools\test\mkGameEngine-view.json volumes\content\
copy scoretools\test\mkGameEngine-meld.json volumes\score\
copy mei-files\out\*.mei volumes\content\
rem #copy mei-files/*.mei volumes\content\

rem #sudo docker cp meld/meld/server/mkGameEngine-meld.json meld:/root/work/
docker exec fast-performance-demo-meld-1 python generate_climb_scores.py score/mkGameEngine-meld.json score
