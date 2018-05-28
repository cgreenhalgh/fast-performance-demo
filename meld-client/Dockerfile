FROM node:8.11.2-stretch

RUN mkdir -p /root/work
WORKDIR /root/work

COPY meld-client/package.json .
COPY package-lock.json .

RUN npm install

COPY meld-client/ .

EXPOSE 8080

CMD ["node","./node_modules/webpack-dev-server/bin/webpack-dev-server.js","--host=0.0.0.0"]
