FROM praekeltfoundation/python-base:debian
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

ENV VUMI_VERSION "0.6.10"
RUN pip install vumi==$VUMI_VERSION

WORKDIR /app

COPY ./vumi-entrypoint.sh /scripts/
CMD ["vumi-entrypoint.sh"]
