@main
struct Main {
    static func main() {
        let PWM_Pin: UInt32 = 12
        set_sys_clock_khz(125 * 1000, true)
        stdio_init_all()
        PWM_init(gpio: PWM_Pin, div: 250)
        PWM_set_duty(gpio: PWM_Pin, duty: 30);

        while true {
            (UInt16(600)..<1400).forEach { value in
                PWM_set_freq(gpio: PWM_Pin, freq: value)
                sleep_ms(1)
            }

            (UInt16(600)..<1400).reversed().forEach { value in
                PWM_set_freq(gpio: PWM_Pin, freq: value)
                sleep_ms(1)
            }            
        }
    }

    static func PWM_init(gpio: UInt32, div: Float) {
        gpio_set_function(gpio, GPIO_FUNC_PWM)
        let slice_num = pwm_gpio_to_slice_num(gpio)
        pwm_set_wrap(slice_num, 10000)
        pwm_set_chan_level(slice_num, gpio % 2, 0)
        pwm_set_clkdiv(slice_num, div)
        pwm_set_enabled(slice_num, true)
    }

    static func PWM_set_freq(gpio: UInt32, freq: UInt16) {
        var div = 12500 / Float(freq)
        if div >= 256 {
            div = 255
        }
        let slice_num = pwm_gpio_to_slice_num(gpio)
        pwm_set_clkdiv(slice_num, div)
    }

    static func PWM_set_duty(gpio: UInt32, duty: UInt16) {
        let normalisedDuty = min(duty, 100)
        let slice_num = pwm_gpio_to_slice_num(gpio)
        pwm_set_chan_level(slice_num, gpio % 2, normalisedDuty * 100)
    }
}

