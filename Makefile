OVMF_CODE    = /usr/share/ovmf/x64/OVMF_CODE.fd
OVMF_VARS    = /usr/share/ovmf/x64/OVMF_VARS.fd
CARGO_TARGET = build/x86_64-kboot.json
OUTPUT_EFI   = kboot.efi
OUTPUT_IMG   = kboot.img
IMG_SIZE     = 4000000

BUILD_FLAGS  = \
	-Zbuild-std \
	-Zbuild-std-features=compiler-builtins-mem \
	--target $(CARGO_TARGET)

BLOCK_SIZE=512
SECTORS=$(shell echo $(IMG_SIZE) / $(BLOCK_SIZE) | bc)
SECTORS_EFIPART=$(shell echo $(SECTORS) - 2048 - 33 | bc)

all: build make-img

build:
	cargo build $(BUILD_FLAGS)
	cp target/x86_64-kboot/debug/kboot.efi $(OUTPUT_EFI)

build-release:
	cargo build $(BUILD_FLAGS) --release
	cp target/x86_64-kboot/release/kboot.efi $(OUTPUT_EFI)

make-img: # 93750
	@echo "Creating & formatting kboot.img..."
	dd if=/dev/zero of=$(OUTPUT_IMG) bs=$(BLOCK_SIZE) count=$(SECTORS)
	parted $(OUTPUT_IMG) -s -a minimal mklabel gpt
	parted $(OUTPUT_IMG) -s -a minimal mkpart EFI FAT16 2048s 100%

	@echo "Creating & formatting efipart.img..."
	dd if=/dev/zero of=efipart.img bs=$(BLOCK_SIZE) count=$(SECTORS_EFIPART)
	mformat -i efipart.img -h 32 -t 32 -n 64 -c 1

	@echo "Copying EFI binary..."
	mcopy -i efipart.img $(OUTPUT_EFI) ::
	dd if=efipart.img of=$(OUTPUT_IMG) count=$(SECTORS_EFIPART) seek=2048 conv=notrunc

	@echo "Cleaning up..."
	rm -v efipart.img

qemu:
	qemu-system-x86_64 -cpu qemu64 \
		-drive if=pflash,format=raw,unit=0,file=$(OVMF_CODE),readonly=on \
		-drive if=pflash,format=raw,unit=1,file=$(OVMF_VARS) \
		-drive if=ide,format=raw,file=$(OUTPUT_IMG)