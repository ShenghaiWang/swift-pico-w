enum PIO {
    static let pio0: UnsafeMutablePointer<pio_hw_t> = UnsafeMutablePointer(bitPattern: 0x50200000)!
}

@main
struct Main {
    static func main() {
        let WS2812_PIN: UInt32 = 22
        let sm: UInt32 = 0
        var program = ws2812_program
        let offset = pio_add_program(PIO.pio0, &program)

        stdio_init_all()
        ws2812_program_init(PIO.pio0, sm, UInt32(offset), WS2812_PIN, 800000, true)

        while true {
            for cnt in UInt32(0)...0xff {
                put_rgb(red: cnt, green: 0xff - cnt, blue: 0);
                sleep_ms(3)
            }
            for cnt in UInt32(0)...0xff {
                put_rgb(red: 0xff - cnt, green: 0, blue: cnt)
                sleep_ms(3)
            }
            for cnt in UInt32(0)...0xff {
                put_rgb(red: 0, green: cnt, blue: 0xff - cnt)
                sleep_ms(3);
            }
        }
    }

    static func put_rgb(red: UInt32, green: UInt32, blue: UInt32) {
        let mask = (green << 16) | (red << 8) | (blue << 0)
        pio_sm_put_blocking(PIO.pio0, 0, mask << 8)
    }
}

