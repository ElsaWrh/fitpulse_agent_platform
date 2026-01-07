SHELL := /bin/bash

DEV_COMPOSE := docker-compose.yml
PROD_COMPOSE := docker-compose.yml
DEV_ENV := .env
PROD_ENV := .env.prod

.PHONY: dev-up dev-down dev-build dev-logs prod-up prod-down prod-build prod-logs

dev-up:
	@if [ ! -f $(DEV_ENV) ]; then cp .env.example $(DEV_ENV); fi
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) up -d --build

dev-down:
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) down

dev-build:
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) build

dev-logs:
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) logs -f

prod-up:
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) up -d --build

prod-down:
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) down

prod-build:
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) build

prod-logs:
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) logs -f
