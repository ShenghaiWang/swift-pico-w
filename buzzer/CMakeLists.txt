cmake_minimum_required(VERSION 3.13)
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(buzzer C CXX ASM)
pico_sdk_init()

if(APPLE)
execute_process(COMMAND xcrun -f swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
else()
execute_process(COMMAND which swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

add_executable(buzzer)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    COMMAND
        ${SWIFTC}
        -target armv6m-none-none-eabi -Xcc -mfloat-abi=soft -Xcc -fshort-enums
        -Xcc -DCYW43_LWIP
        -Xcc -DPICO_CYW43_ARCH_THREADSAFE_BACKGROUND
        -Xcc -I$ENV{PICO_SDK_PATH}/lib/lwip/src/include
        -Xcc -I$ENV{PICO_SDK_PATH}/src/rp2_common/hardware_pwm/include
        -Xcc -I$ENV{PICO_SDK_PATH}/src/rp2_common/hardware_clocks/include
        -Xcc -I$ENV{PICO_SDK_PATH}/src/rp2_common/pico_cyw43_arch/include
        # -Xcc -I$ENV{PICO_SDK_PATH}/src/rp2040/hardware_regs/include
        # -Xcc -I$ENV{PICO_SDK_PATH}/src/rp2040/hardware_structs/include
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/include
        -Xfrontend -function-sections -enable-experimental-feature Embedded -wmo -parse-as-library
        $$\( echo '$<TARGET_PROPERTY:buzzer,INCLUDE_DIRECTORIES>' | tr '\;' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        $$\( echo '${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}'             | tr ' '  '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
        -c -o ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    DEPENDS
        ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
)
pico_set_program_name(buzzer "buzzer")
pico_set_program_version(buzzer "0.1")
pico_enable_stdio_uart(buzzer 1)
pico_enable_stdio_usb(buzzer 1)
add_custom_target(buzzer-swiftcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o)
target_link_libraries(buzzer
    pico_stdlib hardware_pwm
    ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
)
add_dependencies(buzzer buzzer-swiftcode)
pico_add_extra_outputs(buzzer)
