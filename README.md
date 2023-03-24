# Workflow API example

Drupal codebase for https://api.workflow.dentsu.ct8.pl/

## Project setup

1. Spin-up environment

```shell
make
```

2. Install composer dependencies

```shell
make composer install
```

3. Clear cache and start developing

```shell
make drush cr
make drush uli
```

## Makefile

```
Usage: make COMMAND

Commands:
    help            List available commands and their description 
    up              Start up all container from the current docker-compose.yml 
    start           Start stopped containers 
    stop            Stop all containers for the current docker-compose.yml (docker-compose stop) 
    down            Same as stop
    prune [service] Stop and remove containers, networks, images, and volumes (docker-compose down)
    ps              List container for the current project (docker ps with filter by name)
    shell [service] Access a container via shell as a default user (by default [service] is php)
    logs [service]  Show containers logs, use [service] to show logs of specific service
```