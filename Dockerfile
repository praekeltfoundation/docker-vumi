ARG VARIANT=jessie
FROM praekeltfoundation/python-base:2.7-$VARIANT

RUN addgroup vumi \
    && adduser --system --ingroup vumi vumi

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /app

COPY vumi-entrypoint.sh /scripts/
ENTRYPOINT ["tini", "--", "vumi-entrypoint.sh"]
