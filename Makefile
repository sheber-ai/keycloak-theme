.DEFAULT_GOAL := help
.PHONY: help unpack pack check up down logs reset

THEME := sheber
ARCHIVE := $(THEME).tar.gz

help: ## Show commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

unpack: ## Unpack the theme into ./sheber
	@test ! -d $(THEME) || (echo "$(THEME)/ already exists. Pack it (make pack) or remove it first" && exit 1)
	tar -xzf $(ARCHIVE)
	@echo "Unpacked to $(THEME)/login/"

pack: ## Pack ./sheber into the archive and remove the folder
	@test -d $(THEME)/login || (echo "$(THEME)/login not found, nothing to pack" && exit 1)
	find $(THEME) \( -name '.DS_Store' -o -name '._*' \) -delete
	COPYFILE_DISABLE=1 tar -czf $(ARCHIVE) $(THEME)/login
	@$(MAKE) --no-print-directory check
	rm -rf $(THEME)

check: ## Validate archive structure
	@if tar -tzf $(ARCHIVE) | grep -v '^$(THEME)/login/'; then echo "Archive has paths outside $(THEME)/login/ (see above)"; exit 1; fi
	@tar -tzf $(ARCHIVE) | grep -qx '$(THEME)/login/theme.properties' || (echo "Archive has no $(THEME)/login/theme.properties" && exit 1)
	@echo "Archive OK: $$(tar -tzf $(ARCHIVE) | wc -l | tr -d ' ') entries"

up: ## Start Keycloak + Mailpit (unpacks the theme if needed)
	@test -d $(THEME) || $(MAKE) --no-print-directory unpack
	docker compose up -d

down: ## Stop
	docker compose down

logs: ## Follow Keycloak logs
	docker compose logs -f keycloak

reset: ## Recreate Keycloak and re-import realm/sheber-realm.json
	docker compose down
	docker compose up -d --force-recreate
