DOCKER ?= docker
DOCKER_COMPOSE ?= docker-compose

PYGMENTIZE ?= $(shell which pygmentize)

DOCKER_COMPOSE_UP_OPT =

FILES = docker-compose.yml
SHELL = /bin/sh

CONFIG_MK = config.mk
GEN_MK = gen.mk

ifneq ($(PYGMENTIZE),)
COLOUR_YAML = $(PYGMENTIZE) -l yaml
else
COLOUR_YAML = cat
endif

TPL = $(addsuffix .in, $(FILES))
DEPS = $(CURDIR)/get_vars.sh $(TPL) Makefile
GEN_MK_VARS = $(shell $(CURDIR)/get_vars.sh $(TPL))

.PHONY: all files clean files pull build
.PHONY: up start stop restart logs
.PHONY: config inspect
ifneq ($(SHELL),)
.PHONY: shell
endif

all: pull build

#
#
clean:
	rm -f $(FILES) *~

.gitignore: Makefile
	for x in $(FILES); do \
		grep -q "^$$x$$" $@ || echo "$$x" >> $@; \
	done
	touch $@

$(GEN_MK): $(CURDIR)/gen_mk.sh $(DEPS)
	$< $(GEN_MK_VARS) > $@~
	mv $@~ $@

$(CONFIG_MK): $(CURDIR)/config_mk.sh $(DEPS)
	$< $@ $(GEN_MK_VARS)
	touch $@

files: $(FILES) $(CONFIG_MK) $(GEN_MK) .gitignore

pull: files
	$(DOCKER_COMPOSE) pull

build: files
	$(DOCKER_COMPOSE) build --pull

include $(GEN_MK)
include $(CONFIG_MK)

up: files
	$(DOCKER_COMPOSE) up $(DOCKER_COMPOSE_UP_OPT)

start: files
	$(DOCKER_COMPOSE) up -d $(DOCKER_COMPOSE_UP_OPT)

stop: files
	$(DOCKER_COMPOSE) down --remove-orphans

restart: files
	$(DOCKER_COMPOSE) restart

logs: files
	$(DOCKER_COMPOSE) logs -f

ifneq ($(SHELL),)
shell: files
	$(DOCKER_COMPOSE) exec $(NAME) $(SHELL)
endif

config: files
	$(DOCKER_COMPOSE) config | $(COLOUR_YAML)

inspect:
	$(DOCKER_COMPOSE) ps
	$(DOCKER) network inspect -v $(TRAEFIK_BRIDGE) | $(COLOUR_YAML)
