# Workflow API example

Drupal codebase for https://api.iso-playground.ovh/

## Project setup

1. Put database backup in `mysql` directory or download it using

```shell 
make copy-database
```

2. Spin-up environment and then access it at http://api.workflow.localhost/ using

```shell
make
```

3. Copy local settings overrides using

```shell
  cp html/web/sites/default/example.settings.local.php html/web/sites/default/settings.local.php
 ```

4. Install composer dependencies

```shell
make drush cr
make drush uli
```

4. Clear cache and start developing

```shell
make drush cr
make drush uli
```

6.Clear cache and start developing

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
    deploy-code     Deploy changes to staging environment. Script will update repository, 
                    install composer dependencies, run drush deploy and compile CSS files
    copy-database   Download current database dump from test environment.
    compile         Compile local CSS files.
```