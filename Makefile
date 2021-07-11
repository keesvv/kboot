OVMF_CODE = /usr/share/ovmf/x64/OVMF_CODE.fd
OVMF_VARS = /usr/share/ovmf/x64/OVMF_VARS.fd

all: build

build:
	cargo build -Zbuild-std --target build/x86_64-kboot.json

qemu:
	qemu-system-x86_64 -cpu qemu64 \
		-drive if=pflash,format=raw,unit=0,file=$(OVMF_CODE),readonly=on \
		-drive if=pflash,format=raw,unit=1,file=$(OVMF_VARS) \
		-net none