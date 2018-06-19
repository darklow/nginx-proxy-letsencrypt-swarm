FROM jwilder/nginx-proxy

RUN wget -q https://dl.eff.org/certbot-auto \
&& chmod a+x ./certbot-auto \
&& mv ./certbot-auto /usr/local/bin/certbot \
&& certbot --install-only --non-interactive

RUN certbot register -n -m joeri.veder@comsave.com --agree-tos

RUN apt-get update -y \
 && apt-get install -y \
            cron \
            jq \
            curl

RUN wget -q https://dl.minio.io/client/mc/release/linux-amd64/mc \
 && mv ./mc /usr/local/bin/mc \
 && chmod a+x /usr/local/bin/mc

ENV S3FS_ENDPOINT=https://s3.wasabisys.com \
    S3FS_ACCESSKEY=HTGT0EK60QR7KT3WA79I \
    S3FS_SECRETKEY=EmggKIe499mBQYOU1bETGLqDrawYr1nHzVsibPXY

RUN mc config host add wasabi $S3FS_ENDPOINT $S3FS_ACCESSKEY $S3FS_SECRETKEY

COPY ./cron.d/letsencrypt /etc/cron.d/letsencrypt
RUN crontab /etc/cron.d/letsencrypt

COPY ./cron.d/letsencrypt /etc/cron.d/letsencrypt
RUN crontab /etc/cron.d/letsencrypt

COPY ./app /app/

ENTRYPOINT ["/app/comsave/init.sh"]
CMD ["forego", "start", "-r"]
