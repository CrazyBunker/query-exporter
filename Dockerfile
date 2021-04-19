FROM python:3.8-alpine AS build-image

#RUN apt update
#RUN apt full-upgrade -y
RUN apk add --no-cache --virtual \
    build-essential \
    curl \
#    default-libmysqlclient-dev \
    mariadb-dev \
#    libpq-dev \
#    libpq \
#    unixodbc-dev \

    gcc \
    linux-headers \
    libc-dev \
    unzip

ADD . /srcdir
RUN python3 -m venv /virtualenv
ENV PATH="/virtualenv/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install \
     /srcdir \
#    cx-Oracle \
#    ibm-db-sa \
     mysqlclient
#    psycopg2-binary \
#    psycopg2 \
#    pyodbc

#`RUN curl \
#    https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip \
#    -o instantclient.zip
#RUN unzip instantclient.zip
#RUN mkdir -p /opt/oracle/instantclient
#RUN mv instantclient*/* /opt/oracle/instantclient


FROM python:3.8-alpine

RUN apk add --no-cache \
#RUN apt update && \
#    apt full-upgrade -y && \
#    apt install -y --no-install-recommends \
    curl \
    gnupg \
#    libaio1 \
#    libmariadb-dev-compat \
    mariadb-dev \
#    libodbc1 \
#    libpq5 \
    libxml2
#    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
#    curl https://packages.microsoft.com/config/debian/$(. /etc/os-release; echo "$VERSION_ID")/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
#    apt update && \
#    ACCEPT_EULA=Y apt install -y --no-install-recommends msodbcsql17
RUN wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.7.2.1-1_amd64.apk &&\
    wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.7.1.1-1_amd64.apk &&\
    apk add --allow-untrusted msodbcsql17_17.7.2.1-1_amd64.apk &&\
    apk add --allow-untrusted mssql-tools_17.7.1.1-1_amd64.apk

COPY --from=build-image /virtualenv /virtualenv
COPY --from=build-image /opt /opt

ENV PATH="/virtualenv/bin:$PATH"
ENV VIRTUAL_ENV="/virtualenv"
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"

EXPOSE 9560/tcp
# IPv6 support is not enabled by default, only bind IPv4
ENTRYPOINT ["query-exporter", "/config.yaml", "-H", "0.0.0.0"]
