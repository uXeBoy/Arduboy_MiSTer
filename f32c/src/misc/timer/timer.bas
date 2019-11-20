NEW
  10 REM THIS DOESNT WORK REGISTER LOCATIONS HAVE CHANGED
  100 TIMADR%=-128
  110 COUNTER%=TIMADR%
  120 PERIOD%=TIMADR%+4*1
  130 ENHANCE%=TIMADR+4*3
  140 INC%=TIMADR%+4*2
  150 APPLY%=TIMADR%+4*7
  160 DIM ICP_START%(2),ICP_STOP%(2)
  170 ICP_START%(1)=TIMADR%+4*12:ICP_START%(2)=TIMADR%+4*14
  180 ICP_STOP%(1)=TIMADR%+4*13:ICP_STOP%(2)=TIMADR%+4*15
  190 OCP_START%(1)=TIMADR%+4*8:OCP_START%(2)=TIMADR%+4*10
  200 OCP_STOP%(1)=TIMADR%+4*9:OCP_STOP%(2)=TIMADR%+4*11
  210 CONTROL%=TIMADR%+4*6
  220 AND_OR%=CONTROL%+1
  230 REM set output compare 1 and 2
  240 POKE OCP_START%(1)+3,0:POKE OCP_START%(1)+2,0:POKE OCP_START%(1)+1,0:POKE OCP_START%(1),0
  250 POKE OCP_STOP%(1)+3,0:POKE OCP_STOP%(1)+2,0:POKE OCP_STOP%(1)+1,10:POKE OCP_STOP%(1),0
  260 POKE OCP_START%(2)+3,0:POKE OCP_START%(2)+2,0:POKE OCP_START%(2)+1,0:POKE OCP_START%(2),0
  270 POKE OCP_STOP%(2)+3,20:POKE OCP_STOP%(2)+2,250:POKE OCP_STOP%(2)+1,20:POKE OCP_STOP%(2),0
  280 POKE APPLY%+1,15: REM apply ocp values
  290 REM set timer step (unused)
  300 POKE INC%+3,0:POKE INC%+2,0:POKE INC%+1,0:POKE INC%+0,10
  310 REM commit timer step (not implemented, not needed)
  320 POKE APPLY%,4
  330 REM set period
  340 POKE PERIOD%+3,250:POKE PERIOD%+2,250:POKE PERIOD%+1,250:POKE PERIOD%+0,250
  350 REM set period enhancement
  360 POKE ENHANCE%+3,0:POKE ENHANCE%+2,0:POKE ENHANCE%+1,0:POKE ENHANCE%+0,0
  370 REM commit timer period and enhancement
  380 POKE APPLY%,2+8
  390 REM set initial timer value (commited later)
  400 POKE COUNTER%+3,1:POKE COUNTER%+2,10:POKE COUNTER%+1,0: POKE COUNTER%,0
  410 FOR I%=1 TO 10
  420 ?PEEK(COUNTER%+3),PEEK(COUNTER%+2),PEEK(COUNTER%+1),PEEK(COUNTER%)
  430 IF I%=5 THEN ?"commit changes":POKE APPLY%,1
  440 NEXT
  450 REM set capture range 1 and 2
  460 POKE ICP_START%(1)+3,0:POKE ICP_START%(1)+2,0:POKE ICP_START%(1)+1,0:POKE ICP_START%(1),0
  470 POKE ICP_STOP%(1)+3,20:POKE ICP_STOP%(1)+2,250:POKE ICP_STOP%(1)+1,120:POKE ICP_STOP%(1),250
  480 POKE ICP_START%(2)+3,0:POKE ICP_START%(2)+2,0:POKE ICP_START%(2)+1,0:POKE ICP_START%(2),0
  490 POKE ICP_STOP%(2)+3,20:POKE ICP_STOP%(2)+2,250:POKE ICP_STOP%(2)+1,120:POKE ICP_STOP%(2),250
  500 POKE APPLY%+1,16+32+64+128: REM apply ICP setting
  510 REM input capture mixing: 16+32 AND, output compare mixing: 1+2 AND
  520 POKE AND_OR%,16+32+1+2
  530 POKE APPLY%,64: REM apply control register (and/or setting)
  540 SLEEP(0.1)
  550 REM blink led0 and led1 to activate input capture
  560 POKE -240,0:POKE -240,1:POKE -240,3
  570 ?
  580 FOR I%=0 TO 15
  590 ?PEEK(TIMADR%+3+4*I%),PEEK(TIMADR%+2+4*I%),PEEK(TIMADR%+1+4*I%),PEEK(TIMADR%+4*I%)
  600 NEXT
  610 POKE -240,0
RUN