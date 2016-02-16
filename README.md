# docker-rundeck

## Environment

```
RUNDECK_PORT: 
RUNDECK_URL:

RUNDECK_S3_BUCKET:
RUNDECK_S3_REGION:

RUNDECK_MYSQL_HOST:
RUNDECK_MYSQL_DATABASE:
RUNDECK_MYSQL_USERNAME:
RUNDECK_MYSQL_PASSWORD:
```

## How to use

```bash
$ docker run -p 4440:4440 \
             -e "RUNDECK_PORT=4440" \
             -e "RUNDECK_URL=https://rundeck.example.com" \
             -e "RUNDECK_S3_BUCKET=rundeck" \
             -e "RUNDECK_MYSQL_HOST=localhost" \
             -e "RUNDECK_MYSQL_DATABASE=rundeck" \
             -e "RUNDECK_MYSQL_USERNAME=rundeck" \
             -e "RUNDECK_MYSQL_PASSWORD"=rundeck \
             -t mats116/rundeck:latest
