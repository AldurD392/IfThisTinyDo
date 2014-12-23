CC=gcc
CFLAGS=-Wall
CFLAGS+=-I..

all: ruleBuilder

ruleBuilder: ruleBuilder.c
		$(CC) $(CFLAGS) ruleBuilder.c -o ruleBuilder 

.PHONY: clean
clean:
		rm -rf ruleBuilder
