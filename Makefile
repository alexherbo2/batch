build:
	shards build --release

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/batch" "${PWD}/scripts/rename" "${PWD}/scripts/convert" "${PWD}/scripts/relink" ~/.local/bin

uninstall:
	rm -f ~/.local/bin/batch ~/.local/bin/rename ~/.local/bin/convert ~/.local/bin/relink

test:
	crystal spec

clean:
	rm -Rf bin lib shard.lock
	cd examples; make clean
