DOCKER_DIR := env_var_or_default("DOCKER_DIR", "/opt/docker")

alias clean-docker := docker-clean

@default:
    just --list | grep -v default

docker-clean:
    docker images | grep none | awk '{print $3}' | xargs docker rmi

env FLAVOR $SRC_DIR=invocation_directory():
    just -f "{{ DOCKER_DIR }}/justfile" run {{ FLAVOR }}

update:
    brew update
    brew upgrade
