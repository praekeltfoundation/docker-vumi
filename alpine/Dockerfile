FROM praekeltfoundation/python-base:2-alpine

RUN addgroup vumi \
    && adduser -S -G vumi vumi

# The Python 2 base image doesn't have this installed by default anymore
# Needed for cffi things such as cryptography
RUN apk add --no-cache libffi

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

WORKDIR /app

COPY vumi-entrypoint.sh /scripts/
ENTRYPOINT ["tini", "--", "vumi-entrypoint.sh"]
