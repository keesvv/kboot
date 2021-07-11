all: build

build:
	cargo build --target thumbv7em-none-eabihf

build-local:
	cargo rustc -- -C link-arg=-nostartfiles
