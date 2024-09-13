cmake_minimum_required(VERSION 3.13)
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(rgb-led)
pico_sdk_init()

if(APPLE)
execute_process(COMMAND xcrun -f swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
else()
execute_process(COMMAND which swiftc OUTPUT_VARIABLE SWIFTC OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

add_executable(rgb-led)
pico_generate_pio_header(rgb-led ${CMAKE_CURRENT_LIST_DIR}/ws2812.pio OUTPUT_DIR ${CMAKE_CURRENT_LIST_DIR}/generated)

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
        -Xcc -I${CMAKE_CURRENT_LIST_DIR}/include
        -Xfrontend -function-sections -enable-experimental-feature Embedded -wmo -parse-as-library
        $$\( echo '$<TARGET_PROPERTY:rgb-led,INCLUDE_DIRECTORIES>' | tr '\;' '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        $$\( echo '${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}'             | tr ' '  '\\n' | sed -e 's/\\\(.*\\\)/-Xcc -I\\1/g' \)
        -import-bridging-header ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
        -c -o ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
    DEPENDS
        ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
        ${CMAKE_CURRENT_LIST_DIR}/Main.swift
)
add_custom_target(rgb-led-swiftcode DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o)

pico_enable_stdio_uart(rgb-led 1)
pico_enable_stdio_usb(rgb-led 1)

target_link_libraries(rgb-led
    pico_stdlib hardware_pio hardware_dma
    ${CMAKE_CURRENT_BINARY_DIR}/_swiftcode.o
)
add_dependencies(rgb-led rgb-led-swiftcode)
pico_add_extra_outputs(rgb-led)
