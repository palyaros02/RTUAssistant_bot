FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y --no-install-recommends locales language-pack-ru build-essential python3 python3-pip python3-setuptools sqlite3 libcurl4-openssl-dev libssl-dev r-base

ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8

RUN sed -i -e \
  's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen \
   && locale-gen \
   && dpkg-reconfigure locales

ADD . .
RUN pip3 install -r requirements.txt
RUN Rscript requirements.R

RUN python3 ./parsing/parser.py

ENTRYPOINT ["Rscript", "bot.R"]
