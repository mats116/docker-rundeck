FROM java:openjdk-8-jdk

ENV TZ=Asia/Tokyo

ENV VERSION=2.6.2-1-GA

RUN apt-get update \
    && apt-get install -y uuid-runtime

RUN wget -nv "http://dl.bintray.com/rundeck/rundeck-deb/rundeck-$VERSION.deb" \
    && dpkg -i rundeck-$VERSION.deb \
    && rm -f rundeck-$VERSION.deb

WORKDIR /var/log/rundeck/var/lib/rundeck/libext
RUN wget -nv "https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v1.5.1/rundeck-ec2-nodes-plugin-1.5.1.jar" \
    && wget -nv "https://github.com/rundeck-plugins/rundeck-s3-log-plugin/releases/download/v1.0.0/rundeck-s3-log-plugin-1.0.0.jar" \
    && wget -nv "https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.5.dev/rundeck-slack-incoming-webhook-plugin-0.5.jar"

WORKDIR /var/log/rundeck

CMD sed -i -e "/^framework.server.name/c\framework.server.name = ${HOSTNAME}" /etc/rundeck/framework.properties \
    && sed -i -e "/^framework.server.hostname/c\framework.server.hostname = ${HOSTNAME}" /etc/rundeck/framework.properties \
    && sed -i -e "/^framework.server.port/c\framework.server.port = ${RUNDECK_PORT}" /etc/rundeck/framework.properties \
    && sed -i -e "/^framework.server.url/c\framework.server.url = ${RUNDECK_URL}" /etc/rundeck/framework.properties \
    && echo "rundeck.server.uuid = $(uuidgen)" >> /etc/rundeck/framework.properties \

    && echo "\n# Rundeck S3 Log Storage Plugin" >> /etc/rundeck/framework.properties \
    && echo "framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.bucket = ${RUNDECK_S3_BUCKET}" >> /etc/rundeck/framework.properties \
    && echo "framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.path = logs/${job.project}/${job.id}/${job.execid}.log" >> /etc/rundeck/framework.properties \
    && echo "framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.region = ${RUNDECK_S3_REGION}" >> /etc/rundeck/framework.properties \

    && sed -i -e "/^grails.serverURL/c\grails.serverURL = ${RUNDECK_URL}" /etc/rundeck/rundeck-config.properties \
    && sed -i -e "/^dataSource.url/c\dataSource.url = jdbc:mysql://${RUNDECK_MYSQL_HOST}/${RUNDECK_MYSQL_DATABASE}?autoReconnect=true" /etc/rundeck/rundeck-config.properties \
    && echo "dataSource.username = ${RUNDECK_MYSQL_USERNAME}" >> /etc/rundeck/rundeck-config.properties \
    && echo "dataSource.password = ${RUNDECK_MYSQL_PASSWORD}" >> /etc/rundeck/rundeck-config.properties \

    && echo "\n# Enables DB for Project configuration storage" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.projectsStorageType = db" >> /etc/rundeck/rundeck-config.properties \

    && echo "\n# Encryption for project config storage" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.config.storage.converter.1.type = jasypt-encryption" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.config.storage.converter.1.path = projects" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.config.storage.converter.1.config.password = mysecret" >> /etc/rundeck/rundeck-config.properties \

    && echo "\n# Enable DB for Key Storage" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.storage.provider.1.type = db" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.storage.provider.1.path = keys" >> /etc/rundeck/rundeck-config.properties \

    && echo "\n# Encryption for Key Storage" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.storage.converter.1.type = jasypt-encryption" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.storage.converter.1.path = keys" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.storage.converter.1.config.password = mysecret" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.clusterMode.enabled = true" >> /etc/rundeck/rundeck-config.properties \

    && echo "\n# Enables S3 for Log storage" >> /etc/rundeck/rundeck-config.properties \
    && echo "rundeck.execution.logs.fileStoragePlugin = org.rundeck.amazon-s3" >> /etc/rundeck/rundeck-config.properties \

    && . /etc/rundeck/profile \
    && /usr/bin/java ${RDECK_JVM} -cp ${BOOTSTRAP_CP} com.dtolabs.rundeck.RunServer /var/lib/rundeck ${RUNDECK_PORT}
