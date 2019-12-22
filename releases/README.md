OK - now ready to release an alpha work-in-progress core that can run games!

(Note: this is not a 1:1 FPGA based emulation of the ATmega32U4 microcontroller used in the Arduboy - at this stage it is more a 'simulation' of an Arduboy, using a RISC-V 'soft' microcontroller and a modified version of the Arduboy libraries to re-compile games for this platform... so, existing pre-compiled Arduboy hex files are not going to run on this right now! But the majority of Arduboy games are open-source anyway, so it is not a big deal to make any necessary adjustments to the code and then re-compile a compatible hex file.)

The hex files still need to be uploaded to the core over serial right now, but this can be done via the internal UART connection from MiSTer's linux console - just type in 'minicom' to open up a serial terminal to the Arduboy RISC-V core. Then press Ctrl-A to bring up the minicom 'menu bar' and press 'S' to send a file. Arrow down and select 'ascii' upload. Then tag the hex file to be sent using the space bar, and hit enter to send! And restart the Arduboy core from the MiSTer menu each time before sending a new file (or send a serial break from minicom to restart it instead by pressing Ctrl-A to bring up the minicom 'menu bar' and then pressing 'F' to send break).

(Would be great if sending a file over serial to a core like this could be worked into the MiSTer menu?)

The test hex files I have included are 'The Curse of AstaroK' by Press Play On Tape (see the GitHub page for gameplay instructions!):

https://github.com/Press-Play-On-Tape/The-Curse-Of-AstaroK [(LICENSE)](https://github.com/Press-Play-On-Tape/The-Curse-Of-AstaroK/blob/master/LICENSE)

and 'Circuit Dude' by Jonathan Holmes:

http://www.crait.net/

and 'Ardynia' by Matt Greer:

https://www.city41.games/ardynia/help [(LICENSE)](https://github.com/city41/ardynia/blob/master/LICENSE)

and 'Rooftop Rescue' by Bert Veer:

https://github.com/BertVeer/Rooftop [(LICENSE)](https://github.com/BertVeer/Rooftop/blob/master/LICENSE)

I did initially look at basing this core on Alorium Technology's implementation of an ATmega328 microcontroller on an FPGA - but part of it is closed-source and unfortunately only compatible with the Intel MAX 10, not the Cyclone V:

https://github.com/AloriumTechnology/XLR8Core/issues/1
