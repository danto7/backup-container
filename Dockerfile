FROM alpine
ENV BACKUP_DIR=/backup
RUN mkdir /backup && \
  apk add --no-cache restic
COPY ./entrypoint.sh /entrypoint.sh
CMD "/entrypoint.sh"
