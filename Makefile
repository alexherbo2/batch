name := batch
version := $(shell git describe --tags --always)
target := $(shell llvm-config --host-target)
static ?= no

ifeq ($(static),yes)
  flags += --static
endif

build:
	shards build --release $(flags)

x86_64-unknown-linux-musl:
	scripts/docker-run make static=yes

x86_64-apple-darwin: build

release: $(target)
	mkdir -p releases
	zip -r releases/$(name)-$(version)-$(target).zip bin share

install: build
	install -d ~/.local/bin
	install bin/batch share/batch/scripts/* ~/.local/bin

uninstall:
	rm -f ~/.local/bin/batch

test:
	crystal spec

clean:
	rm -Rf bin lib releases shard.lock
	cd examples; make clean
