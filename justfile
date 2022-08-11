DOCKER_DIR := env_var_or_default("DOCKER_DIR", "/opt/docker")

alias clean-docker := docker-clean
export MOUNT_HOST := invocation_directory()

@default:
    just --justfile {{ justfile() }} --list | grep -v default

# update ~/Brewfile
bundle:
    brew bundle dump -f ~/Brewfile

# push Chezmoi changes to remote
chezmoi CMD *ARGS:
    {{ if CMD == "push" { "chezmoi cd && git push && exit 0" } else { CMD + " " + ARGS } }}

# clean up unused Docker artifacts
docker-clean:
    docker images | grep none | awk '{print $3}' | xargs docker rmi

# run a development environment container with the given FLAVOR
env FLAVOR *ARGS:
    just -f "{{ DOCKER_DIR }}/justfile" run {{ FLAVOR }} {{ ARGS }}

# update and upgrade packages
update:
    brew update
    brew upgrade
