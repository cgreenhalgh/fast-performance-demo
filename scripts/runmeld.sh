IP="$1"
if [ "$IP" = "" ]; then
  IP="127.0.0.1"
fi
echo "IP = " $IP
export MELD_BASE_URI=http://${IP}:5000
export MELD_MEI_URI=http://${IP}:3000/content
export MELD_MUZICODES_URI=http://${IP}:3000
export MELD_BASECAMP_MEI_FILE="http://${IP}:3000/content/BaseCamp.mei"

echo "Open " ${MELD_BASE_URI}"/startTheClimb"
cd meld
python manage.py runserver --host=0.0.0.0

