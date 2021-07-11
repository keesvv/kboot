# kboot
A tiny bootable EFI executable, written in Rust. 

> I have no plans for this whatsoever, this is just yet another challenge for me to further learn low level development.

## Compiling

### Dependencies
- Rust Nightly
- `mtools`
- `ovmf`
- `parted`

```bash
make && sudo make qemu
```
