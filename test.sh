#!/usr/bin/env bash
set -e

# For a basic test, do pretty much what's described in the tutorial:
# http://vumi.readthedocs.io/en/latest/intro/tutorial01.html

if [[ "$#" != "1" ]]; then
  echo "Usage: $0 IMAGE_TAG"
  echo "  IMAGE_TAG is the Docker image tag for the Vumi image to test"
  exit 1
fi

IMAGE_TAG="$1"; shift

echo "Launching RabbitMQ container..."
docker run -d --name vumi-rabbitmq rabbitmq

echo "Launching Vumi telnet transport container..."
docker run -d --name vumi-telnet --link vumi-rabbitmq:rabbitmq -p 9010:9010 \
  -e AMQP_HOST=rabbitmq \
  -e WORKER_CLASS=vumi.transports.telnet.TelnetServerTransport \
  -e VUMI_OPT_TRANSPORT_NAME=telnet -e VUMI_OPT_TELNET_PORT=9010 \
  "$IMAGE_TAG"
sleep 2

echo "Checking container logs to see if it started correctly..."
docker logs vumi-telnet \
  | fgrep "Starting a TelnetServerTransport worker with config: {'telnet_port': '9010', 'transport_name': 'telnet'}"

echo "Launching Vumi echo worker container..."
docker run -d --name vumi-echo --link vumi-rabbitmq:rabbitmq \
  -e AMQP_HOST=rabbitmq \
  -e WORKER_CLASS=vumi.demos.words.EchoWorker \
  -e VUMI_OPT_TRANSPORT_NAME=telnet \
  "$IMAGE_TAG"
sleep 2

# Wait for the session to start, send our message, wait for reply
echo "Checking if the echo server works over the telnet interface..."
{ sleep 1; echo 'hallo world'; sleep 1; } \
  | telnet localhost 9010 \
  | fgrep 'hallo world'

echo "Checking container logs to see if message was logged..."
docker logs vumi-echo | fgrep 'User message: hallo world'

echo "Stopping and removing all containers..."
docker stop vumi-telnet vumi-echo vumi-rabbitmq
docker rm vumi-telnet vumi-echo vumi-rabbitmq

echo
echo "Done"
