FROM ghcr.io/praekeltfoundation/pypy-base-nw:2-buster

RUN addgroup --system vumi \
    && adduser --system --ingroup vumi vumi

# We need the backport of the typing module to build Twisted.
RUN pip install typing==3.10.0.0

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /app

COPY vumi-entrypoint.sh /scripts/
ENTRYPOINT ["tini", "--", "vumi-entrypoint.sh"]
