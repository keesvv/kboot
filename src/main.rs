#![no_std]
#![no_main]
#![feature(asm)]
#![feature(abi_efiapi)]

extern crate rlibc;

use core::fmt::Write;
use uefi::prelude::*;
use uefi::table::runtime::ResetType;

static mut SYS_TABLE: Option<&SystemTable<Boot>> = None;

// Prints text to the screen
fn print(st: &SystemTable<Boot>, msg: &str) {
    st.stdout().write_str(msg).unwrap();
}

// Cold reboots the system
fn reboot(rs: &RuntimeServices) {
    rs.reset(ResetType::Cold, Status::SUCCESS, None);
}

#[entry]
fn main(_image: Handle, st: SystemTable<Boot>) -> Status {
    let bs = st.boot_services();
    let rs = st.runtime_services();

    // unsafe {
    //     let bor: &'static SystemTable<Boot> = &st;
    //     SYS_TABLE = Some(bor);
    // };

    // Clear the screen
    st.stdout().reset(true).unwrap().unwrap();

    print(&st, "Hello, world!\n");

    // Pause the CPU for 3 seconds
    bs.stall(3 * 1000 * 1000);

    reboot(&rs);
    loop {}
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    if unsafe { SYS_TABLE.is_none() } {
        loop {}
    }

    let st = unsafe { SYS_TABLE.unwrap() };

    print(&st, "! PANIC !\n A fatal error occured\n");
    print(&st, "Halting the system...");

    let rs = st.runtime_services();
    reboot(&rs);

    loop {}
}
