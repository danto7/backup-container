FROM alpine
RUN mkdir /backup && \
  apk add --no-cache restic
COPY ./entrypoint.sh /entrypoint.sh
CMD "/entrypoint.sh"
