/**
Descripcion,
Modulo que sincroniza las senales (hsync y vsync)
de un controlador VGA de 640x480 60hz, funciona con un reloj de 25Mhz

Ademas tiene las coordenadas de los pixeles H (eje x),
y de los pixeles V (eje y). Para enviar la senal RGB correspondiente
a cada pixel

-----------------------------------------------------------------------------
Author : Nicolas Hasbun, nhasbun@gmail.com
File   : vgaHdmi.v
Create : 2017-06-15 15:07:05
Editor : sublime text3, tab size (2)
-----------------------------------------------------------------------------
*/

// **Info Source**
// https://eewiki.net/pages/viewpage.action?pageId=15925278

module vgaHdmi(
  input clock, clock50, clock100,
  input reset,
  output reg hsync, vsync,
  output reg dataEnable,
  output reg vgaClock,
  input oled_dc,
  input oled_clk,
  input  [7:0] oled_data,
  output [23:0] RGBchannel
);

// (* ram_init_file = "test.mif" *)
reg [7:0] mem [0:1023];
reg [9:0] waddr;

always @(posedge oled_clk)
begin
  if (oled_dc) begin
    mem[waddr] <= oled_data;
    waddr <= waddr + 1'b1; // Increment address
  end
  else begin
    waddr <= 10'd0; // 'VSYNC'
  end
end

always @(posedge clock100)
begin
  tempByte <= mem[bytePosition];
end

wire [6:0] pixelX;
wire [5:0] pixelY;
wire [2:0] pixelZ;
wire [2:0] bitPosition;
wire [9:0] bytePosition;
reg  [7:0] tempByte;
wire       pixelValue;
assign pixelX = pixelH / 5;
assign pixelY = pixelV / 5;
assign pixelZ = pixelY[5:3];
assign bitPosition = pixelY % 8;
assign bytePosition = (pixelZ * 128) + pixelX;
assign pixelValue = (dataEnable) ? tempByte[bitPosition] : 1'b0;

wire reset_n;
assign reset_n = ~reset;

reg [9:0] pixelH, pixelV; // estado interno de pixeles del modulo

initial begin
  hsync      = 1;
  vsync      = 1;
  pixelH     = 0;
  pixelV     = 0;
  dataEnable = 0;
  vgaClock   = 0;
end

// Manejo de Pixeles y Sincronizacion

always @(posedge clock or posedge reset_n) begin
  if(reset_n) begin
    hsync  <= 1;
    vsync  <= 1;
    pixelH <= 0;
    pixelV <= 0;
  end
  else begin
    // Display Horizontal
    if(pixelH==0 && pixelV!=524) begin
      pixelH <= pixelH + 1'b1;
      pixelV <= pixelV + 1'b1;
    end
    else if(pixelH==0 && pixelV==524) begin
      pixelH <= pixelH + 1'b1;
      pixelV <= 0; // pixel 525
    end
    else if(pixelH<=640) pixelH <= pixelH + 1'b1;
    // Front Porch
    else if(pixelH<=656) pixelH <= pixelH + 1'b1;
    // Sync Pulse
    else if(pixelH<=752) begin
      pixelH <= pixelH + 1'b1;
      hsync  <= 0;
    end
    // Back Porch
    else if(pixelH<799) begin
      pixelH <= pixelH+1'b1;
      hsync  <= 1;
    end
    else pixelH<=0; // pixel 800

    // Manejo Senal Vertical
    // Sync Pulse
    if(pixelV == 491 || pixelV == 492)
      vsync <= 0;
    else
      vsync <= 1;
  end
end

// dataEnable signal
always @(posedge clock or posedge reset_n) begin
  if(reset_n) dataEnable <= 0;

  else begin
    if(pixelH > 0 && pixelH <= 640 && pixelV > 0 && pixelV <= 480)
      dataEnable <= 1;
    else
      dataEnable <= 0;
  end
end

// VGA pixeClock signal
// Los clocks no deben manejar salidas directas, se debe usar un truco
initial vgaClock = 0;

always @(posedge clock50 or posedge reset_n) begin
  if(reset_n) vgaClock <= 0;
  else      vgaClock <= ~vgaClock;
end

// **************************************************************
// Screen colours

assign RGBchannel = ((pixelV < 320) && (pixelH < 640) && pixelValue && dataEnable)? 24'hFFFFFF : 24'd0;

endmodule