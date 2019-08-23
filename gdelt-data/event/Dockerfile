FROM ubuntu:18.04

COPY event.sh /gdelt/event.sh

WORKDIR /gdelt

RUN apt update && apt install python3-pip python3-dev unzip wget -y
RUN cd /usr/local/bin && ln -s /usr/bin/python3 python
RUN pip3 install awscli --upgrade --ignore-installed six

ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""

CMD ["/bin/bash", "event.sh"]

