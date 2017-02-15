FROM praekeltfoundation/python-base:alpine
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

RUN addgroup vumi \
    && adduser -S -G vumi vumi

WORKDIR /app

COPY ./vumi-entrypoint.py /scripts/
CMD ["vumi-entrypoint.py"]
