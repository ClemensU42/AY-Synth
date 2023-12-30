cmake_minimum_required(VERSION 3.25)

project(ay-synth)

set(F_CPU 16000000UL)
set(MCU atmega32)
set(BAUD 9600)
set(PROG_TYPE avrispmkII)

set(H_FUSE 0xD1)
set(L_FUSE 0xFF)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_ASM_COMPILER avr-gcc)

add_definitions(
    -DF_CPU=${F_CPU}
    -DBAUD=${BAUD}
)

set(CMAKE_EXE_LINKER_FLAGS -mmcu=${MCU})

add_compile_options(
    -mmcu=${MCU} # MCU
    -std=gnu99 # C99 standard
    -Os # optimize
    -Wall # enable warnings
    -Wno-main
    -Wundef
    -pedantic
    -Wstrict-prototypes
    -Werror
    -Wfatal-errors
    -Wl,--relax,--gc-sections
    -g
    -gdwarf-2
    -funsigned-char # a few optimizations
    -funsigned-bitfields
    -fpack-struct
    -fshort-enums
    -ffunction-sections
    -fdata-sections
    -fno-split-wide-types
    -fno-tree-scev-cprop
)

add_executable(${PROJECT_NAME} src/main.c)

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME}.elf)

add_custom_target(strip ALL avr-strip ${PROJECT_NAME}.elf DEPENDS ${PROJECT_NAME})

add_custom_target(hex ALL avr-objcopy -R .eeprom -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex DEPENDS strip)

add_custom_target(eeprom avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.eep DEPENDS strip)

add_custom_target(upload avrdude -c ${PROG_TYPE} -p ${MCU} -U flash:w:${PROJECT_NAME}.hex DEPENDS hex)

add_custom_target(upload_eeprom avrdude -c ${PROG_TYPE} -p ${MCU} -U eeprom:w:${PROJECT_NAME}.eep DEPENDS eeprom)

add_custom_target(fuses avrdude -c ${PROJECT_NAME} -p ${MCU} -U lfuse:w:${L_FUSE}:m -U hfuse:w:${H_FUSE}:m)

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${PRODUCT_NAME}.hex;${PRODUCT_NAME}.eeprom;${PRODUCT_NAME}.lst")
