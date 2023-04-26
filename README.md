# Self-hosted github-actions runner with GPU access using Docker

Loosely based on: [testdriven.io/blog/github-actions-docker](https://testdriven.io/blog/github-actions-docker/)

## Set up

Get the nvidia docker image (is this automated?)
```
nvidia/cuda:11.4.0-devel-ubuntu20.04
```
and make sure `nvidia-smi` is working outside the container.

Create the docker image `runner-image` from the provided `Dockerfile`
```
docker build --tag runner-image .
```

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