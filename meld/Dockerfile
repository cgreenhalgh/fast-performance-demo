FROM python:2.7-stretch

RUN mkdir /root/work
WORKDIR /root/work

COPY meld/server /root/work
RUN pip install -r requirements.txt

ENV MELD_BASE_URI http://127.0.0.1:5000
ENV MELD_MEI_URI http://127.0.0.1:3000/content
ENV MELD_SCORE_URI http://127.0.0.1:5000/score

EXPOSE 5000

CMD ["python","manage.py","runserver","--threaded","--host=0.0.0.0"]
