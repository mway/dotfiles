DOCKER_DIR := env_var_or_default("DOCKER_DIR", "/opt/docker")

@default:
    just --list | grep -v default

env FLAVOR $SRC_DIR=invocation_directory():
    just -f "{{ DOCKER_DIR }}/justfile" run {{ FLAVOR }}
