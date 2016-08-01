FROM praekeltfoundation/pypy-base:debian
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /app

COPY ./vumi-entrypoint.sh /scripts/
CMD ["vumi-entrypoint.sh"]
