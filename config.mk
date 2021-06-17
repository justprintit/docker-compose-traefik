TRAEFIK_BRIDGE ?= traefiknet
NAME ?= justprintit
HOSTNAME ?= $(NAME).docker.localhost
IMAGE ?= amery/docker-golang-modd:latest
BINDIR ?= ../bin
DATADIR ?= ../data
