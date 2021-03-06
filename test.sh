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

CONTAINERS=()
function docker_run {
  # Run a detached container temporarily for tests. Removes the container when
  # the script exits and sleeps a bit to wait for it to start.
  local container
  container="$(docker run -d "$@")"
  echo "$container"
  CONTAINERS+=("$container")
  sleep 5
}

function remove_containers {
  echo "Stopping and removing containers..."
  for container in "${CONTAINERS[@]}"; do
    docker stop "$container"
    docker rm "$container"
  done
}
trap remove_containers EXIT

echo "Launching RabbitMQ container..."
docker_run --name vumi-rabbitmq rabbitmq:alpine

echo "Launching Vumi telnet transport container..."
docker_run --name vumi-telnet --link vumi-rabbitmq:rabbitmq -p 9010:9010 \
  -e AMQP_HOST=rabbitmq \
  -e WORKER_CLASS=vumi.transports.telnet.TelnetServerTransport \
  -e VUMI_OPT_TRANSPORT_NAME=telnet -e VUMI_OPT_TELNET_PORT=9010 \
  "$IMAGE_TAG"

function try_a_few_times {
  # Stolen from http://unix.stackexchange.com/a/137639 with a few adjustments
  local n=1 max=5 delay=2
  until "$@"; do
    if [[ "$n" < "$max" ]]; then
      ((n++))
      echo "Command failed. Trying again ($n/$max)..."
      sleep $delay
    else
      fail "The command has failed after $n attempts."
    fi
  done
}

function check_transport_logs {
  echo "Checking container logs to see if it started correctly..."
  docker logs vumi-telnet \
    | fgrep "Starting a TelnetServerTransport worker with config: {'telnet_port': '9010', 'transport_name': 'telnet'}"
}
try_a_few_times check_transport_logs

echo "Launching Vumi echo worker container..."
docker_run --name vumi-echo --link vumi-rabbitmq:rabbitmq \
  -e AMQP_HOST=rabbitmq \
  -e WORKER_CLASS=vumi.demos.words.EchoWorker \
  -e VUMI_OPT_TRANSPORT_NAME=telnet \
  "$IMAGE_TAG"

function check_telnet_echo {
  echo "Checking if the echo server works over the telnet interface..."
  # Wait for the session to start, send our message, wait for reply
  { sleep 1; echo 'hallo world'; sleep 1; } \
    | telnet localhost 9010 \
    | fgrep 'hallo world'
}
try_a_few_times check_telnet_echo

echo "Checking container logs to see if message was logged..."
docker logs vumi-echo | fgrep 'User message: hallo world'

echo
echo "Done"
