FROM alpine
ENV BACKUP_DIR=/backup
RUN mkdir /backup && \
  apk add --no-cache restic bash
COPY ./entrypoint.sh /entrypoint.sh
CMD "/entrypoint.sh"
