FROM node:8.11.2-stretch

RUN npm install -g coffee-script
RUN mkdir /srv/scoretools
WORKDIR /srv/scoretools

COPY package.json /srv/scoretools/
RUN npm install
COPY src /srv/scoretools/src
RUN mkdir /srv/scoretools/lib
RUN npm run compile

VOLUME /srv/scoretools/test
VOLUME /srv/mei-files

CMD ["node","lib/makemuzicodes.js","test/mkGameEngine-config.yml"]
