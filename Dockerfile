FROM ghcr.io/praekeltfoundation/pypy-base-nw:2-buster AS builder

RUN apt-get update
RUN apt-get -yy install build-essential libssl-dev libffi-dev

COPY requirements.txt /requirements.txt

RUN pip install --upgrade pip
# We need the backport of the typing module to build Twisted.
RUN pip install typing==3.10.0.0

RUN pip wheel -w /wheels -r /requirements.txt


FROM ghcr.io/praekeltfoundation/pypy-base-nw:2-buster

COPY ./requirements.txt /requirements.txt
COPY --from=builder /wheels /wheels
RUN pip install -f /wheels -r /requirements.txt

RUN addgroup --system vumi \
    && adduser --system --ingroup vumi vumi

WORKDIR /app

COPY vumi-entrypoint.sh /scripts/
ENTRYPOINT ["tini", "--", "vumi-entrypoint.sh"]
