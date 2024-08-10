.PHONY: build flash flashm monitor only_build
ELF = target/xtensa-esp32s3-espidf/release/esp-snapcast
SERIAL_DEVICE = /dev/ttyACM0

build: only_build
	python3 replacer.py ${ELF}
only_build:
	cargo build --release
monitor:
	espflash monitor -p ${SERIAL_DEVICE}
flash: build
	espflash flash -p ${SERIAL_DEVICE} -f 80mhz -B 921600 --partition-table partitions.csv ${ELF}
flashm: build
	espflash flash -p ${SERIAL_DEVICE} -f 80mhz -B 921600 --flash-mode dio -M --partition-table partitions.csv ${ELF}
