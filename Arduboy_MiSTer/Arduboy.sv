//============================================================================
//  Arduboy MiSTer core by uXeBoy (Dan O'Shea)
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
    //Master input clock
    input         CLK_50M,

    //Async reset from top-level module.
    //Can be used as initial reset.
    input         RESET,

    //Must be passed to hps_io module
    inout  [45:0] HPS_BUS,

    //Base video clock. Usually equals to CLK_SYS.
    output        CLK_VIDEO,

    //Multiple resolutions are supported using different CE_PIXEL rates.
    //Must be based on CLK_VIDEO
    output        CE_PIXEL,

    //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
    output  [7:0] VIDEO_ARX,
    output  [7:0] VIDEO_ARY,

    output  [7:0] VGA_R,
    output  [7:0] VGA_G,
    output  [7:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,
    output        VGA_DE,    // = ~(VBlank | HBlank)
    output        VGA_F1,
    output  [1:0] VGA_SL,

    output        LED_USER,  // 1 - ON, 0 - OFF.

    // b[1]: 0 - LED status is system status OR'd with b[0]
    //       1 - LED status is controled solely by b[0]
    // hint: supply 2'b00 to let the system control the LED.
    output  [1:0] LED_POWER,
    output  [1:0] LED_DISK,

    // I/O board button press simulation (active high)
    // b[1]: user button
    // b[0]: osd button
    output  [1:0] BUTTONS,

    output [15:0] AUDIO_L,
    output [15:0] AUDIO_R,
    output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
    output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

    //ADC
    inout   [3:0] ADC_BUS,

    //SD-SPI
    output        SD_SCK,
    output        SD_MOSI,
    input         SD_MISO,
    output        SD_CS,
    input         SD_CD,

    //High latency DDR3 RAM interface
    //Use for non-critical time purposes
    output        DDRAM_CLK,
    input         DDRAM_BUSY,
    output  [7:0] DDRAM_BURSTCNT,
    output [28:0] DDRAM_ADDR,
    input  [63:0] DDRAM_DOUT,
    input         DDRAM_DOUT_READY,
    output        DDRAM_RD,
    output [63:0] DDRAM_DIN,
    output  [7:0] DDRAM_BE,
    output        DDRAM_WE,

    //SDRAM interface with lower latency
    output        SDRAM_CLK,
    output        SDRAM_CKE,
    output [12:0] SDRAM_A,
    output  [1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQML,
    output        SDRAM_DQMH,
    output        SDRAM_nCS,
    output        SDRAM_nCAS,
    output        SDRAM_nRAS,
    output        SDRAM_nWE,

    input         UART_CTS,
    output        UART_RTS,
    input         UART_RXD,
    output        UART_TXD,
    output        UART_DTR,
    input         UART_DSR,

    // Open-drain User port.
    // 0 - D+/RX
    // 1 - D-/TX
    // 2..6 - USR2..USR6
    // Set USER_OUT to 1 to read from USER_IN.
    input   [6:0] USER_IN,
    output  [6:0] USER_OUT,

    input         OSD_STATUS
);

assign CLK_VIDEO = clk_100m;
assign VIDEO_ARX = 4;
assign VIDEO_ARY = 3;
assign VGA_F1    = 0;
assign VGA_SL    = 0;
assign LED_POWER = 0;
assign LED_DISK  = 0;
assign BUTTONS   = 0;
assign USER_OUT  = 0;
assign AUDIO_S   = 0;
assign AUDIO_MIX = 3;
assign AUDIO_L   = (audio1 && !busy) ? 16'h7FFF : 16'd0;
assign AUDIO_R   = (audio2 && !busy) ? 16'h7FFF : 16'd0;
assign ADC_BUS   = 'Z;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_RD, DDRAM_DIN, DDRAM_BE, DDRAM_WE} = 0;
assign {SDRAM_CLK, SDRAM_CKE, SDRAM_A, SDRAM_BA, SDRAM_DQ, SDRAM_DQML, SDRAM_DQMH, SDRAM_nCS, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nWE} = 'Z;
assign {UART_RTS, UART_DTR} = 0;

`include "build_id.v"
localparam CONF_STR =
{
    "Arduboy;;",
    "S0,HEX;",
    "R0,Reset;",
    "J1,A,B;",
    "V,v",`BUILD_DATE
};

wire [31:0] joystick;
wire [31:0] status;

wire lba;
reg [8:0] sd_lba;
always @(posedge clk_100m) if (lba) sd_lba <= address;
wire [8:0] busy_lba;
assign busy_lba = (busy) ? lba_count : sd_lba;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
    .clk_sys(clk_100m),
    .HPS_BUS(HPS_BUS),
    .conf_str(CONF_STR),
    .joystick_0(joystick),
    .status(status),

    .sd_lba(busy_lba),
    .sd_rd(sd_rd),
    .sd_wr(sd_wr),
    .sd_ack(sd_ack),
    .sd_conf(0),
    .sd_buff_addr(sd_buff_addr),
    .sd_buff_dout(sd_buff_dout),
    .sd_buff_din(sd_buff_din),
    .sd_buff_wr(sd_buff_wr)
);

wire [3:0] R,G,B;
wire VSync,HSync,HBlank,VBlank;

wire [3:0] busyR,busyG,busyB;
assign busyR = (busy) ? {4{char_count[14]}} : {4{pixelValue}};
assign busyG = (busy) ? {4{char_count[13]}} : {4{pixelValue}};
assign busyB = (busy) ? {4{char_count[12]}} : {4{pixelValue}};

video_cleaner video_cleaner
(
    .clk_vid(clk_100m),
    .ce_pix(clk_25m),

    .R(busyR),
    .G(busyG),
    .B(busyB),

    .HSync(hsync),
    .VSync(vsync),
    .HBlank(hblank),
    .VBlank(vblank),

    .VGA_R(R),
    .VGA_G(G),
    .VGA_B(B),
    .VGA_VS(VSync),
    .VGA_HS(HSync),

    .HBlank_out(HBlank),
    .VBlank_out(VBlank)
);

video_mixer #(.LINE_LENGTH(800), .HALF_DEPTH(1)) video_mixer
(
    .*,

    .clk_vid(clk_100m),
    .ce_pix(clk_25m),
    .ce_pix_out(CE_PIXEL),

    .scandoubler(0),
    .scanlines(0),
    .hq2x(0),
    .mono(~busy),
    .gamma_bus()
);

wire clk_100m, clk_25m;

pll_50m pll_50m
(
    .refclk(CLK_50M),
    .rst(RESET),
    .outclk_0(clk_100m),
    .outclk_1(clk_25m)
);

wire [7:0] random_dout;

unstable_counters unstable_counters
(
    .clk(CLK_50M),
    .rst(RESET),
    .dat(random_dout)
);

reg [7:0] tx_data_r;
reg dvalid;
wire tx_rd;

UART UART
(
    .CLK(CLK_50M),
    .RST(RESET),
    .SYNC(sync),
    .UART_TXD(tx),
    .DIN(tx_data_r),
    .DIN_VLD(dvalid),
    .DIN_RDY(tx_rd)
);

reg busy;
reg [8:0] lba_count;
reg [17:0] char_count;

always @(posedge clk_100m)
begin
  if (status[0] || RESET) begin
    lba_count <= 0;
  end
  else if (busy) begin
    if (risingSD_RD) lba_count <= lba_count + 1'b1;
  end
end

always @(posedge clk_25m)
begin
  if (status[0] || RESET) begin
    busy <= 1'b1;
    dvalid <= 1'b0;
    char_count <= 502;
  end
  else if (busy) begin
    if (buffer_dout == 8'h1A) begin // End of File
      busy <= 1'b0;
      dvalid <= 1'b0;
    end
    else if (tx_rd && !dvalid) begin
      if (char_count < 512) tx_data_r <= char_count - 454; // ASCII 0-9
      else tx_data_r <= buffer_dout;
      dvalid <= 1'b1;
      char_count <= char_count + 1'b1;
    end
    else begin
      dvalid <= 1'b0;
    end
  end
end

wire tx;
wire audio1;
wire audio2;
wire sync;
wire glue_rd_in;
wire sd_wr_in;
wire glue_wr;
wire [8:0] address;
wire [7:0] buffer_din;
wire [7:0] buffer_dout;
wire sd_ack;
wire hsync, vsync;
wire hblank, vblank;
wire pixelValue;

glue glue
(
    .clk_100m(clk_100m),
    .clk_25m(clk_25m),
    .reset(status[0] || RESET),
    .rs232_rxd(tx),
    .rs232_txd(UART_TXD),
    .led(LED_USER),
    .buttons(joystick[5:0]),
    .audio1(audio1),
    .audio2(audio2),
    .lba(lba),
    .sync(sync),
    .sd_rd(glue_rd_in),
    .sd_wr(sd_wr_in),
    .glue_wr(glue_wr),
    .address(address),
    .buffer_din(buffer_din),
    .buffer_dout(buffer_dout),
    .random_dout(random_dout),
    .sd_ack(sd_ack),
    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank),
    .pixelValue(pixelValue)
);

wire sd_buff_wr;
wire [8:0] sd_buff_addr;
wire [7:0] sd_buff_dout;
wire [7:0] sd_buff_din;
wire [8:0] busy_addr;
assign busy_addr = (busy) ? char_count[8:0] : address;

sdbuf buffer
(
    .clock_a(clk_100m),
    .address_a(sd_buff_addr),
    .data_a(sd_buff_dout),
    .wren_a(sd_buff_wr),
    .q_a(sd_buff_din),

    .clock_b(clk_100m),
    .address_b(busy_addr),
    .data_b(buffer_din),
    .wren_b(glue_wr),
    .q_b(buffer_dout)
);

reg sd_rd;
reg sd_wr;
reg delaySD_RD, delaySD_WR;
wire risingSD_RD, risingSD_WR;
assign risingSD_RD = (sd_rd_in & ~delaySD_RD);
assign risingSD_WR = (sd_wr_in & ~delaySD_WR);
wire sd_rd_in;
assign sd_rd_in = (busy) ? (char_count[8:0] == 511) : glue_rd_in;

always @(posedge clk_100m)
begin
  if (sd_ack) begin
    sd_wr <= 1'b0;
    sd_rd <= 1'b0;
  end
  else if (risingSD_WR) sd_wr <= 1'b1;
  else if (risingSD_RD) sd_rd <= 1'b1;

  delaySD_WR <= sd_wr_in;
  delaySD_RD <= sd_rd_in;
end

endmodule
