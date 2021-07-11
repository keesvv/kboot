#![no_std]
#![no_main]
#![feature(asm)]

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let buf = 0xb8000 as *mut u8;
    static HELLO_WORLD: &[u8] = b"Hello, world!";

    // Loop through each character
    for (i, &b) in HELLO_WORLD.iter().enumerate() {
        unsafe {
            // Print character
            *buf.offset(i as isize * 2) = b;

            // 0x0 = VGA color black
            *buf.offset(i as isize * 2 + 1) = 0x0;
        }
    }

    loop {}
}
