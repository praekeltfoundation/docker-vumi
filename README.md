# docker-vumi

[![Build Status](https://travis-ci.org/praekeltfoundation/docker-vumi.svg?branch=develop)](https://travis-ci.org/praekeltfoundation/docker-vumi)
[![Requirements Status](https://pyup.io/repos/github/praekeltfoundation/docker-vumi/shield.svg)](https://pyup.io/repos/github/praekeltfoundation/docker-vumi/)

Docker images for the Vumi messaging engine (http://vumi.readthedocs.io)

## Usage
The Docker image provides an entrypoint for Vumi that allows the configuration of Vumi workers via environment variables.

### Configuration
Configuration can be done using environment variables or command-line options. Use of environment variables and command-line options can be mixed, but using an environment variable at the same time as it's equivalent command-line option can result in unexpected behaviour.

#### Basic options:
* `TWISTD_COMMAND`/first command-line argument: the command to pass to `twistd` (default: `vumi_worker`)
* `WORKER_CLASS`/`--worker-class`: the Vumi worker class to use
* `CONFIG_FILE`/`--config`: the path to the YAML configuration file to use
* `SENTRY_DSN`/`--sentry`: the Sentry DSN to use for reporting errors

#### AMQP options:
AMQP/RabbitMQ options can be set via environment variables. At a minimum, the `AMQP_HOST` variable must be set or else none of the other AMQP variables will take effect.
* `AMQP_HOST`/`--hostname`: the address for the RabbitMQ server
* `AMQP_PORT`/`--port`: the port for the RabbitMQ server (default: `5672`)
* `AMQP_VHOST`/`--vhost`: the name of the RabbitMQ vhost to use (default: `/`)
* `AMQP_USERNAME`/`--username`: the username to authenticate with RabbitMQ (default: `guest`)
* `AMQP_PASSWORD`/`--password`: the password to authenticate with RabbitMQ (default: `guest`)

#### `VUMI_OPT_` options
Additional options can be passed to Vumi via variables that start with `VUMI_OPT_`. These variables will be converted to `--set-option` CLI options. For example, the environment variable `VUMI_OPT_BUCKET=1` will result in the CLI option `--set-option=bucket:1`.

### `/app` directory
The `/app` directory is created and set as the current working directory. This is the directory where the files (e.g. YAML config) for your application should be put.

### Examples
Running a built-in worker class without a config file:
```shell
docker run --rm -it \
  -e AMQP_HOST=rabbitmq.service.consul \
  -e VUMI_OPT_BUCKETS=3 \
  -e VUMI_OPT_BUCKET_SIZE=10 \
  praekeltfoundation/vumi \
    --worker-class vumi.blinkenlights.MetricTimeBucket
```

Dockerfile for an image with an external worker class and a config file:
```dockerfile
FROM praekeltfoundation/vumi
RUN pip install vumi-http-api
COPY ./my-config.yaml /app/my-config.yaml
ENV WORKER_CLASS="vumi_http_api.VumiApiWorker" \
    CONFIG_FILE="my-config.yaml" \
    AMQP_HOST="rabbitmq.service.consul"
EXPOSE 8000
```

Dockerfile for an image with custom arguments:
```dockerfile
FROM praekeltfoundation/vumi
RUN pip install go-metrics-api
COPY ./my-config.yaml /app/my-config.yaml
ENV TWISTD_COMMAND="cyclone"
EXPOSE 8000
CMD ["--app", "go_metrics.server.MetricsApi", \
     "--port", "8000", \
     "--app-opts", "my-config.yaml"]
```
