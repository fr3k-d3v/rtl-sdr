# RTL-SDR Setup & Spectrum Scanning

Omarchy (Arch-based) host setup for an RTL-SDR (RTL2832U) dongle, plus spectrum scanning helpers and scan results.

## Hardware

- Device: Generic RTL2832U, serial `77771111153705700`
- Tuner: Fitipower FC0013
- USB: `0bda:2832`
- Note: reports as generic (no EEPROM); tuner is FC0013, not the R820T2 found in RTL-SDR Blog v2.

## Driver setup (Arch/Omarchy)

```bash
sudo pacman -S rtl-sdr
# Blacklist conflicting DVB modules so the dongle is usable for SDR
sudo tee /etc/modprobe.d/rtlsdr.conf >/dev/null <<'EOF'
blacklist dvb_usb_rtl28xxu
blacklist e4000
blacklist rtl2832
blacklist rtl2830
EOF
sudo rmmod dvb_usb_rtl28xxu rtl2832 dvb_usb_v2 dvb_core 2>/dev/null
sudo udevadm control --reload-rules
sudo usermod -aG rtlsdr $USER
```

Verify:

```bash
rtl_test   # should report 1 device, 0 samples lost
```

## Installed tools

- `rtl-sdr` (rtl_test, rtl_sdr, rtl_fm, rtl_power, rtl_eeprom)
- `rtl_433` — ISM band decoder
- `dump1090_rs` — ADS-B (1090 MHz)
- `multimon-ng` — pager/FSK decoders
- `soapyrtlsdr`, `soapy_power`

## Spectrum scan helper

```bash
./scripts/sdr-scan.sh [start_MHz] [stop_MHz] [step_kHz] [seconds]
# example: ./scripts/sdr-scan.sh 24 1000 250 30
```

## Scan results (2026-11-09)

Strongest signals above noise floor (24–1700 MHz, ~30 s):

| Freq (MHz) | Power (dB) | Notes |
|---|---|---|
| 141.75 | +16.9 | unidentified VHF transmitter |
| 859.65 | +15.9 | |
| 875.90 | +13.9 | |
| 946–949 | +2..+5 | LTE Band 8 region |
| 1204.9 / 1275.6 | ~-10 | weak |

- FM (88–108): no strong carriers in scan window
- ADS-B (1090): no aircraft decoded in 20 s
- ISM (433.92/868/915): no devices decoded in 60 s

## Next steps

- Better antenna for target band
- NOAA APT weather sat capture (137 MHz)
- FM audio via `rtl_fm ... | aplay`
- GUI waterfall: GQRX / SDR++ (AUR)
