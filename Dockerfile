FROM    node:10-alpine

LABEL   maintainer="Rizal Fauzie Ridwan <rizal@fauzie.my.id>"

ENV     NPM_CONFIG_LOGLEVEL=error

RUN     apk add --update --no-cache jq bash sqlite && \
        npm install -g laravel-echo-server

COPY    app /app

EXPOSE  6001

CMD     /app/start.sh
