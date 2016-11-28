export MELD_BASE_URI=http://127.0.0.1:5000
export MELD_MEI_URI=http://127.0.0.1:3000/content
export MELD_MUZICODES_URI=http://127.0.0.1:3000
export MELD_BASECAMP_MEI_FILE="http://127.0.0.1:3000/content/MSThe%20Climb%20(Base%20Camp).mei"

cd meld
python manage.py runserver --host=0.0.0.0

