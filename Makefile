.PHONY: help install start stop restart build rebuild shell composer symfony db-create db-drop db-reset db-migrate db-diff db-validate clear cache-clear uninstall asset-install asset-dev asset-watch asset-build init-project

.EXPORT_ALL_VARIABLES:
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

# Variables for Docker
DOCKER_COMPOSE = docker compose
EXEC = $(DOCKER_COMPOSE) exec php
COMPOSER = $(EXEC) composer
SYMFONY = $(EXEC) bin/console
NPM = $(EXEC) npm

##
## General commands
##

help: ## Display this help
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

install: ## Initialize the project (build, start containers and install dependencies)
	@$(MAKE) build
	@$(MAKE) start
	@$(MAKE) composer-install
	@$(MAKE) db-create
	@$(MAKE) init-project
	@$(MAKE) asset-install

uninstall: ## Remove all containers, volumes and networks
	@$(DOCKER_COMPOSE) down --volumes --remove-orphans

start: ## Start containers
	@$(DOCKER_COMPOSE) up -d

stop: ## Stop containers
	@$(DOCKER_COMPOSE) stop

restart: ## Restart containers
	@$(MAKE) stop
	@$(MAKE) start

build: ## Build Docker images
	@$(DOCKER_COMPOSE) build

rebuild: ## Rebuild Docker images and restart containers
	@$(DOCKER_COMPOSE) down --remove-orphans
	@$(DOCKER_COMPOSE) build --no-cache
	@$(MAKE) start

shell: ## Open a shell in the PHP container
	@$(EXEC) bash

init-project: ## Initialize project directories with correct permissions
	@$(DOCKER_COMPOSE) exec php bash -c "mkdir -p var/cache var/log public/build .npm-cache node_modules"
	@$(DOCKER_COMPOSE) exec php bash -c "chmod -R 777 var/cache var/log public/build .npm-cache node_modules"

##
## Composer commands
##

composer-install: ## Install Composer dependencies
	@$(COMPOSER) install

##
## Symfony commands
##

symfony: ## Execute a Symfony command (usage: make symfony cmd="command")
	@$(SYMFONY) $(cmd)

##
## Database commands
##

db-create: ## Create the database
	@$(SYMFONY) doctrine:database:create --if-not-exists

db-drop: ## Drop the database
	@$(SYMFONY) doctrine:database:drop --force --if-exists

db-reset: ## Reset the database (drop + create + migrate)
	@$(MAKE) db-drop
	@$(MAKE) db-create
	@$(MAKE) db-migrate

db-migrate: ## Execute migrations
	@$(SYMFONY) doctrine:migrations:migrate --no-interaction

db-diff: ## Generate a migration by comparing entities and database
	@$(SYMFONY) doctrine:migrations:diff

db-validate: ## Validate entity mapping
	@$(SYMFONY) doctrine:schema:validate

##
## Asset commands
##

asset-install: ## Install npm dependencies
	@$(NPM) install --force --cache ./.npm-cache

asset-dev: ## Build assets for development
	@$(NPM) run dev

asset-watch: ## Build assets for development and watch for changes
	@$(NPM) run watch

asset-build: ## Build assets for production
	@$(NPM) run build

##
## Cleanup commands
##

clear: ## Clean caches, logs, etc.
	@$(MAKE) cache-clear

cache-clear: ## Clear Symfony cache
	@$(SYMFONY) cache:clear
