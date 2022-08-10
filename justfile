@default:
    just --list | grep -v default

env FLAVOR $SRC_DIR=invocation_directory():
    just -f /opt/docker/justfile run {{ FLAVOR }} -v $SRC_DIR:/opt/src
