FROM python:2.7-stretch

RUN mkdir /root/work
WORKDIR /root/work

COPY meld-web-services/requirements.txt /root/work
RUN pip install -r requirements.txt

ENV MELD_BASE_URI http://127.0.0.1:5000
ENV MELD_MEI_URI http://127.0.0.1:3000/content
ENV MELD_SCORE_URI http://127.0.0.1:5000/score

EXPOSE 5000

COPY meld-web-services/ /root/work
VOLUME /root/work/score
#(doesn't work) VOLUME /root/work/sessions
#COPY meld/server/mkGameEngine-meld.json .
RUN python generate_climb_scores.py mkGameEngine-meld.json score

CMD ["python","manage.py","runserver","--threaded","--host=0.0.0.0"]
