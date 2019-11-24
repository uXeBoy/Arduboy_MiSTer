# Arduboy_MiSTer

Finally found a DE10-Nano locally for a reasonable price, and have managed to find the time to get the beginnings of an 'Arduboy core' running on it!

So, with a bit more development time / effort we could bring Arduboy games to FPGA gaming platforms like the MiSTer, the upcoming 'Analogue Pocket', or even the new GameBoy-shaped Hackaday Supercon Badge!

https://github.com/MiSTer-devel/Main_MiSTer/wiki <br />
https://www.analogue.co/pocket/ <br />
https://hackaday.com/2019/11/04/gigantic-fpga-in-a-game-boy-form-factor-2019-supercon-badge-is-a-hardware-siren-song/

This is using a modified version of the Arduboy2 library, with the code running on a 'soft' RISC-V microcontroller implemented within the FPGA, and outputting video through the MiSTer's HDMI port... I have bodged menloparkinnovation's DE10-Nano fork of the FPGArduino project together with an example I found for using the HDMI output:

http://www.nxlab.fer.hr/fpgarduino/ <br />
https://github.com/menloparkinnovation/f32c <br />
https://github.com/nhasbun/de10nano_vgaHdmi_chip

All of my customisations are made to the 32K/100MHz RISC-V variation of the core, with serial RX/TX mapped to USER_IN[0] and USER_OUT[1] of the MiSTer (aka. SCL / SDA on the DE10-Nano's Arduino header) which are then connected to one of these USB-to-serial cables:

https://www.adafruit.com/product/954

There is a corresponding Arduino IDE boards package which allows uploading new sketches over this serial connection, but it is also possible to just upload pre-complied hex files to the bootloader without the Arduino IDE - for example using 'Send File' in TeraTerm.
