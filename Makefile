all: build

build:
	cargo build -Zbuild-std --target build/x86_64-kboot.json
