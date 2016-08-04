#!/usr/bin/env bash
set -e

if [[ "$#" < "1" ]]; then
  echo "Usage: $0 IMAGE_TAG [--default]"
  echo "  IMAGE_TAG : the Docker image tag for the Vumi image to test"
  echo "  --default : option to tag the image with the 'latest' and version tag"
  exit 1
fi

IMAGE_TAG="$1"; shift

# Parse the version of Vumi from the requirements file
VUMI_VERSION="$(sed -E 's/\s*vumi\s*==\s*([^\s\;]+).*/\1/' requirements.txt)"

TAGS=("$VUMI_VERSION-${IMAGE_TAG##*:}")
if [[ "$1" == "--default" ]]; then
  TAGS+=("$VUMI_VERSION" "latest")
fi

# Push the current tag
docker push "$IMAGE_TAG"

# Tag the other tags and push them
IMAGE_NAME="${IMAGE_TAG%%:*}"
for tag in "${TAGS[@]}"; do
  image_tag="$IMAGE_NAME:$tag"
  docker tag "$IMAGE_TAG" "$image_tag"
  docker push "$image_tag"
done
