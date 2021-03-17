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
	scripts/build-linux

x86_64-apple-darwin: build

release: $(target)
	mkdir -p releases
	zip -r releases/$(name)-$(version)-$(target).zip bin share

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/batch" "${PWD}/share/batch/scripts/rename" "${PWD}/share/batch/scripts/convert" "${PWD}/share/batch/scripts/relink" ~/.local/bin

uninstall:
	rm -f ~/.local/bin/batch ~/.local/bin/rename ~/.local/bin/convert ~/.local/bin/relink

test:
	crystal spec

clean:
	rm -Rf bin lib releases shard.lock
	cd examples; make clean
