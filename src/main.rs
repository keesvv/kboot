#![no_std]
#![no_main]
#![feature(asm)]
#![feature(abi_efiapi)]

extern crate rlibc;

use core::fmt::Write;
use uefi::prelude::*;
use uefi::table::runtime::ResetType;

#[entry]
fn main(_image: Handle, st: SystemTable<Boot>) -> Status {
    let bs = st.boot_services();
    let rs = st.runtime_services();

    st.stdout().reset(true).unwrap().unwrap();
    st.stdout().write_str("Hello, world!\n").unwrap();

    bs.stall(3000 * 1000);

    rs.reset(ResetType::Cold, Status::SUCCESS, None);
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
