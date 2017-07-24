FROM praekeltfoundation/python-base:2-alpine

RUN addgroup vumi \
    && adduser -S -G vumi vumi

COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /app

COPY ./vumi-entrypoint.sh /scripts/
CMD ["vumi-entrypoint.sh"]
