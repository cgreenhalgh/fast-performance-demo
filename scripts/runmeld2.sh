MELD=meld
MUZICODES=muzicodes
export MELD_BASE_URI=http://${MELD}
export MELD_MEI_URI=http://${MUZICODES}/content
export MELD_MUZICODES_URI=http://${MUZICODES}
export MELD_BASECAMP_MEI_FILE="http://${MUZICODES}/content/MSThe%20Climb%20(Base%20Camp).mei"

echo "Open " ${MELD_BASE_URI}"/startTheClimb"
cd meld
python manage.py runserver --host=0.0.0.0

