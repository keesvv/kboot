#![no_std]
#![no_main]
#![feature(asm)]
#![feature(abi_efiapi)]

extern crate rlibc;
use core::fmt::Write;
use uefi::prelude::*;

#[entry]
fn main(_image: Handle, st: SystemTable<Boot>) -> Status {
    st.stdout().reset(true).unwrap().unwrap();
    st.stdout().write_str("Hello, world!\n").unwrap();
    loop {}
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
