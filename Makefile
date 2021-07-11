OVMF_CODE    = /usr/share/ovmf/x64/OVMF_CODE.fd
OVMF_VARS    = /usr/share/ovmf/x64/OVMF_VARS.fd
CARGO_TARGET = build/x86_64-kboot.json
BUILD_FLAGS  = \
	-Zbuild-std \
	-Zbuild-std-features=compiler-builtins-mem \
	--target $(CARGO_TARGET)

all: build make-img

build:
	cargo build $(BUILD_FLAGS)
	cp target/x86_64-kboot/debug/kboot.efi .

build-release:
	cargo build $(BUILD_FLAGS) --release
	cp target/x86_64-kboot/release/kboot.efi .

make-img:
	@echo "Creating & formatting kboot.img..."
	dd if=/dev/zero of=kboot.img bs=512 count=93750
	parted kboot.img -s -a minimal mklabel gpt
	parted kboot.img -s -a minimal mkpart EFI FAT16 2048s 93716s

	@echo "Creating & formatting efipart.img..."
	dd if=/dev/zero of=efipart.img bs=512 count=91669
	mformat -i efipart.img -h 32 -t 32 -n 64 -c 1

	@echo "Copying EFI binary..."
	mcopy -i efipart.img kboot.efi ::
	dd if=efipart.img of=kboot.img count=91669 seek=2048 conv=notrunc

	@echo "Cleaning up..."
	rm -v efipart.img

qemu:
	qemu-system-x86_64 -cpu qemu64 \
		-drive if=pflash,format=raw,unit=0,file=$(OVMF_CODE),readonly=on \
		-drive if=pflash,format=raw,unit=1,file=$(OVMF_VARS) \
		-drive if=ide,format=raw,file=kboot.img