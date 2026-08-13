FROM node:20-alpine

RUN apk add --no-cache \
    openjdk17-jre \
    docker-cli \
    curl \
    unzip

RUN curl -L -o /tmp/sonar-scanner.zip \
    https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-7.2.0.3129-linux-x64.zip \
    && unzip /tmp/sonar-scanner.zip -d /opt \
    && mv /opt/sonar-scanner-* /opt/sonar-scanner \
    && rm /tmp/sonar-scanner.zip

ENV PATH="/opt/sonar-scanner/bin:$PATH"

RUN java -version
RUN sonar-scanner --version
RUN docker --version
