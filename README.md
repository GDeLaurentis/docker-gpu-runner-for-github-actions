# Self-hosted github-actions runner with GPU access using Docker

Loosely based on: [testdriven.io/blog/github-actions-docker](https://testdriven.io/blog/github-actions-docker/)

## Prerequisites

Get the nvidia docker image
```
nvidia/cuda:12.2.0-devel-ubuntu22.04
```
using
```
docker pull nvidia/cuda:12.2.0-devel-ubuntu22.04
```
and make sure `nvidia-smi` is working outside the container.

Install the `nvidia-container-toolkit` from the [nvidia install-guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

## Set up

Create two files
```
.ORGANIZATION and .ACCESS_TOKEN
```
respectively with content
```
ORGANIZATION="{user-name}/{repo-name}"
ACCESS_TOKEN="******"
```

<span style="color:red">**Warning**: do NOT commit your access token! </span>

For safety, these files are in `.gitignore`

Create the docker image `runner-image` from the provided `Dockerfile`
```
docker build --tag runner-image .
```

A different docker image needs to be created for each different repository (repeat the previous steps).

Note: since docker images are built on a diff-basis, the memory penalty from multiple images differing only by one or two text files is tiny.


## Usage

Spin up the docker container granting it gpu access
```
docker run --rm --name runner --gpus all runner-image
```

it will connect to GitHub, spawn a new self-hosted runner, and start listening for jobs. It should become visible at:
```
https://github.com/{user_name}/{repo-name}/settings/actions/runners
```

To terminate send a single `KeyboardInterrupt` (`CTRL-C`). This will remove the runner (clean-up). The docker container is also removed.

## Advanced Usage and Debugging

To override the entry point, which defaults to `start.sh`, and start an interactive session (e.g. for debugging):
```
docker run -it --entrypoint /bin/bash --gpus all runner-image
```

To check if docker sees `nvcc` (or `nvidia-smi`)
```
docker run --rm --runtime=nvidia nvidia/cuda:11.4.0-devel-ubuntu20.04 which nvcc
```

Packages can either be installed in the `Dockerfile` or in the github workflow file.

## Generic Docker usage notes

list images:
`docker image ls -a`

remove images
`docker rmi IMAGE-ID`

list containers:
`docker container ls -a`

remove containers:
`docker rm CONTAINER-NAME`