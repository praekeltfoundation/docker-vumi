FROM praekeltfoundation/python-base:2-alpine

COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

RUN addgroup vumi \
    && adduser -S -G vumi vumi

WORKDIR /app

COPY ./vumi-entrypoint.sh /scripts/
CMD ["vumi-entrypoint.sh"]
