FROM curlimages/curl:7.73.0
USER root
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --update --no-cache jq
USER curl_user
RUN mkdir /tmp/ddns_cache/

WORKDIR /app
COPY ./ddns-aws-client.sh ./ddns-aws-client.sh
ENTRYPOINT [ "sh", "./ddns-aws-client.sh" ]
CMD [ "--help" ]
VOLUME /tmp/ddns_cache/