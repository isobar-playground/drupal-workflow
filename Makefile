include .env
include .env.local

default: up

COMPOSER_ROOT ?= /var/www/html
DRUPAL_ROOT ?= /var/www/html/web

## help	:	Print commands help.
.PHONY: help
ifneq (,$(wildcard docker.mk))
help : docker.mk
	@sed -n 's/^##//p' $<
else
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up	:	Start up containers.
.PHONY: up
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	@touch -a .env.local
	docker-compose --env-file .env --env-file .env.local pull
	docker-compose --env-file .env --env-file .env.local up -d --remove-orphans
	@git config core.hooksPath .hooks

.PHONY: mutagen
mutagen:
	mutagen-compose up

## down	:	Stop containers.
.PHONY: down
down: stop

## start	:	Start containers without updating.
.PHONY: start
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker-compose --env-file .env --env-file .env.local start

## stop	:	Stop containers.
.PHONY: stop
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose --env-file .env --env-file .env.local stop

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb solr	: Prune `mariadb` and `solr` containers and remove their volumes.
.PHONY: prune
prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose --env-file .env --env-file .env.local down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## shell	:	Access `php` container via shell.
##		You can optionally pass an argument with a service name to open a shell on the specified container
.PHONY: shell
shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'php')' --format "{{ .ID }}") sh

## composer	:	Executes `composer` command in a specified `COMPOSER_ROOT` directory (default is `/var/www/html`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make composer "update drupal/core --with-dependencies"
.PHONY: composer
composer:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_php' --format "{{ .ID }}") composer --working-dir=$(COMPOSER_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## drush	:	Executes `drush` command in a specified `DRUPAL_ROOT` directory (default is `/var/www/html/web`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make drush "watchdog:show --type=cron"
.PHONY: drush
drush:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker-compose --env-file .env --env-file .env.local logs -f $(filter-out $@,$(MAKECMDGOALS))

.PHONY: export-config
export-config:
	@$(MAKE) --no-print-directory drush -- cex --yes

.PHONY: import-config
import-config:
	@$(MAKE) --no-print-directory drush -- cim --yes

.PHONY: ssh
ssh:
	@ssh ${SSH_HOST}

.PHONY: deploy-code
deploy-code:
	@echo "Get changes from master branch."
	@ssh ${SSH_HOST} "cd ${SSH_PROJECT_ROOT} && git pull --rebase"
	@echo "Update composer dependencies."
	@ssh ${SSH_HOST} "cd ${SSH_PROJECT_ROOT} && make composer install"
	@echo "Update Drupal."
	@ssh ${SSH_HOST} "cd ${SSH_PROJECT_ROOT} && make drush deploy && make drush config:status"
#	@echo "Compile theme CSS files."
#	@ssh ${SSH_HOST} "cd ${SSH_THEME_DIR} && npm -s ci && npm run compile"
	@echo "Warm frontpage cache."
	@curl -s https://api.iso-playground.ovh
	@echo "Done."

.PHONY: compile
compile:
	@docker-compose --env-file .env --env-file .env.local run --rm node npm run --no-update-notifier compile

.PHONY: copy-database
copy-database:
	@echo "Creating database dump."
	@ssh ${SSH_HOST} "cd ${SSH_PROJECT_ROOT}/html && drush cr && drush sql:dump --gzip"
	@scp ${SSH_HOST}:${SSH_PROJECT_ROOT}/mysql/dump.sql.gz mysql/init.sql.gz
	@echo "Done."

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
