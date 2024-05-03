[Snapcast](https://github.com/badaix/snapcast) client for the ESP32. Works on the standard ESP32, does not need versions with extra memory / PSRAM.

Supported codecs:
- PCM
- Flac
- OPUS (builds, but crashes instantly)

## Building

You need to provide the `SSID` and `PASS` environment variables, for your wifi settings:

```bash
export SSID=<your wifi name>
export PASS=<your wifi password>
```

If you want to build the `opus` backend, you also need:
```bash
export CC=xtensa-esp32-elf-gcc
export CXX=xtensa-esp32-elf-g++
```

To build the project, you can run `make build`

Note that mDNS (automatic discovery) is not yet implemented, so you must set the IP for the snapcast server on `src/main.rs`.

### Flashing

To flash the project into an ESP32 you can run `make flashm`

## Hardware

I use an [UDA1334A](https://nl.aliexpress.com/item/1005006140641304.html) module with an [ESP32-WROOM-32](https://nl.aliexpress.com/item/1005006500507950.html) (a 320KiB RAM model).

Wire the pins according to this table:

|ESP | I2s board|
|----|----|
D21 | BCLK
D19 | DIN
D18| WSEL
GND | GND
3v3 | VIN

The specific pinout is not required, you only need pins that can output, are not bootstrap pins, and do not output garbage on boot.
If you want to change the wiring, you also need to modify the `i2s`, `dout`, `ws` and `bclk` variables in `main()`.

A pull-down resistor on WSEL makes for quiet reboots; without this, there's a lot of garbled noise until playback starts.


## Recommended snapserver settings

```
chunk_ms = 30
buffer = 690
codec = flac
```

## Bandwidth

On stereo at 48KHz:

- PCM requires ~1.6Mbit/s
- Flac requires ~1Mbit/s
- Opus requires ~250Kbit/s

All of which seem perfectly fine on the ESP32.


## Memory usage

Basic heap analysis:

* On startup, heap low water mark 273KiB
* After setup, heap low water mark 188KiB

Free heap space:

|Buffer Duration|PCM    |FLAC   |OPUS   |
|---------------|-------|-------|-------|
|150ms          |167KiB |173KiB |146KiB |
|500ms          |93KiB  |117KiB |?      |
|700ms          |31KiB\*| 53KiB |?      |

\* Got a random OOM a few times, investigating

## Known issues

- There still _may be_ scenarios which cause a missed frame, and there's no stretching/cutting, so it's a jarring transition.
	- Have not seen this since increasing the buffer sizes
- The ESP32's clock is very inaccurate -- I've measured ~100ms drift per hour with the standard configuration
	- The SNTP client _should_ correct the drift accumulation
