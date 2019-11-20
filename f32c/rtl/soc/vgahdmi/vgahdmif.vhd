--
-- Copyright (c) 2015 Davor Jadrijevic
-- All rights reserved.
--
-- LICENSE=BSD
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.f32c_pack.all;

-- vhdl wrapper for verilog module

entity vgahdmi is
  generic(
    dbl_x          : integer := 0;  -- 0-normal X, 1-double X
    dbl_y          : integer := 0;  -- 0-normal X, 1-double X
    mem_size_kb    : integer := 40 -- unused
  );
  port
  (
    clk_pixel  : in std_logic;  -- pixel clock, 25 MHz
    clk_tmds   : in std_logic := '0'; -- hdmi clock 250 MHz (or 0 if HDMI output is not used)
    test_picture : in std_logic := '0'; -- show test picture
    fetch_next : out std_logic; -- request FIFO to fetch next data
    red_byte, green_byte, blue_byte, bright_byte: in  std_logic_vector(7 downto 0); -- pixel data from FIFO
    vga_r, vga_g, vga_b:  out std_logic_vector(7 downto 0); -- VGA video signal
    vga_hsync, vga_vsync: out std_logic; -- VGA sync
    vga_vblank, vga_blank: out std_logic; -- Video blank
    line_repeat: out std_logic
  );
end vgahdmi;

architecture syn of vgahdmi is
  component vgahdmi_v
    generic (
      dbl_x          : integer := 0;  -- 0-normal X, 1-double X
      dbl_y          : integer := 0   -- 0-normal X, 1-double X
    );
    port (
      clk_pixel  : in std_logic;  -- pixel clock, 25 MHz
      clk_tmds   : in std_logic := '0'; -- hdmi clock 250 MHz (or 0 if HDMI output is not used)
      test_picture : in std_logic := '0'; -- show test picture
      fetch_next : out std_logic; -- request FIFO to fetch next data
      red_byte, green_byte, blue_byte, bright_byte: in  std_logic_vector(7 downto 0); -- pixel data from FIFO
      vga_r, vga_g, vga_b:  out std_logic_vector(7 downto 0); -- VGA video signal
      vga_hsync, vga_vsync: out std_logic; -- VGA sync, positive logic: active HIGH
      vga_vblank, vga_blank: out std_logic; -- VGA vertical blank, positive logic: active HIGH
      line_repeat: out std_logic
    );
  end component;

begin
  vgahdmi_inst: vgahdmi_v
  generic map(
    dbl_x => dbl_x,
    dbl_y => dbl_y
  )
  port map(
      clk_pixel => clk_pixel,
      clk_tmds  => clk_tmds,
      test_picture => test_picture,
      fetch_next => fetch_next,
      red_byte => red_byte,
      green_byte => green_byte,
      blue_byte => blue_byte,
      bright_byte => bright_byte,
      vga_r => vga_r,
      vga_g => vga_g,
      vga_b => vga_b,
      vga_hsync => vga_hsync,
      vga_vsync => vga_vsync,
      vga_vblank => vga_vblank,
      vga_blank => vga_blank,
      line_repeat => line_repeat
  );
end syn;
