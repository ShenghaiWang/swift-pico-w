# How to build and run

## Export the following environment varibales

``` console
$ export TOOLCHAINS='<toolchain-name>'
$ export PICO_BOARD=pico_w
$ export PICO_SDK_PATH='<path-to-your-pico-sdk>'
$ export PICO_TOOLCHAIN_PATH='<path-to-the-arm-toolchain>'
```
## Inside the sub project folders, build them using the following commands

``` console
$ cmake -B build -G Ninja .
$ cmake --build build
```

For detailed setup, please refer to [This article](https://levelup.gitconnected.com/unlocking-the-power-of-embedded-swift-your-step-by-step-roadmap-af902cd8b836).