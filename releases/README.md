OK - now ready to release a work-in-progress core that can run games!

.HEX game files are selected from the MiSTer On Screen Display (OSD) menu - then just Reset the core (also from OSD) and the core's bootloader will receive and run that .HEX file at startup. **The flashing colours are sort of the 'loading screen' (address lines are tied to RGB during the loading sequence to provide some kind of visual activity indication).** The .HEX files as produced by the Arduino IDE have been modified for use with the core, an empty block of 512 bytes is added to the start and used for non-volatile EEPROM storage, and an end-of-file marker (0x1A) is added to the end.

(Note: this is not a 1:1 FPGA based emulation of the ATmega32U4 microcontroller used in the Arduboy - at this stage it is more a 'simulation' of an Arduboy, using a RISC-V 'soft' microcontroller and a modified version of the Arduboy libraries to re-compile games for this platform... so, existing pre-compiled Arduboy .HEX files are not going to run on this right now! But the majority of Arduboy games are open-source anyway, so it is not a big deal to make any necessary adjustments to the code and then re-compile a compatible .HEX file.)

The test .HEX files I have included are 'The Curse of AstaroK' by Press Play On Tape:

https://github.com/Press-Play-On-Tape/The-Curse-Of-AstaroK [(LICENSE)](https://github.com/Press-Play-On-Tape/The-Curse-Of-AstaroK/blob/master/LICENSE)

and 'Rooftop Rescue' by Bert Veer:

https://github.com/BertVeer/Rooftop [(LICENSE)](https://github.com/BertVeer/Rooftop/blob/master/LICENSE)

and 'Super Crate Buino' by Aurélien Rodot:

https://github.com/Rodot/Super-Crate-Buino [(LICENSE)](https://www.gnu.org/licenses/lgpl-3.0.en.html)

and 'Ardynia' by Matt Greer:

https://www.city41.games/ardynia/help [(LICENSE)](https://github.com/city41/ardynia/blob/master/LICENSE)

and 'Circuit Dude' by Jonathan Holmes:

http://www.crait.net/


I did initially look at basing this core on Alorium Technology's implementation of an ATmega328 microcontroller on an FPGA - but part of it is closed-source and unfortunately only compatible with the Intel MAX 10, not the Cyclone V:

https://github.com/AloriumTechnology/XLR8Core/issues/1
