# base
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# set the github runner version
ARG RUNNER_VERSION="2.311.0"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python-is-python3 python3-dev python3.10 python3-venv python3.10-dev python3-pip git \
    libpython3-dev libboost-all-dev locate emacs singular

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh /home/docker/start.sh
COPY .ORGANIZATION /home/docker/.ORGANIZATION
COPY .ACCESS_TOKEN /home/docker/.ACCESS_TOKEN

# make the script executable
RUN chmod +x /home/docker/start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./home/docker/start.sh"]