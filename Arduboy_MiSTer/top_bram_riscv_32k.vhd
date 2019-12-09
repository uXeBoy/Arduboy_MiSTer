--
-- Copyright (c) 2015 Marko Zec, University of Zagreb
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
-- OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
-- SUCH DAMAGE.
--
-- $Id$
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.f32c_pack.all;

entity glue is
    generic (
    -- ISA
    C_arch: integer := ARCH_RV32;

    -- Main clock freq, in multiples of 10 MHz
    C_clk_freq: integer := 100;

    -- SoC configuration options (32K in this configuration)
    C_bram_size: integer := 32;

    -- Debugging
    C_debug: boolean := false
    );
    port (
    clk_100m:    in std_logic;
    clk_25m:     in std_logic;
    lock:        in std_logic;
    rs232_txd:  out std_logic;
    rs232_rxd:   in std_logic;
    led:        out std_logic;
    buttons:     in std_logic_vector(5 downto 0);
    audio:      out std_logic;
    sd_rd:      out std_logic;
    sd_wr:      out std_logic;
    glue_wr:    out std_logic;
    address:    out std_logic_vector(8 downto 0);
    buffer_din: out std_logic_vector(7 downto 0);
    buffer_dout: in std_logic_vector(7 downto 0);
    sd_ack:      in std_logic;
    HSync:      out std_logic;
    VSync:      out std_logic;
    HBlank:     out std_logic;
    VBlank:     out std_logic;
    pixelValue: out std_logic
    );
end glue;

architecture Behavioral of glue is

    component vgaHdmi
    port (
    clock:       in std_logic;
    clock100:    in std_logic;
    reset:       in std_logic;
    oled_dc:     in std_logic;
    oled_clk:    in std_logic;
    oled_data:   in std_logic_vector(7 downto 0);
    buffer_din: out std_logic_vector(7 downto 0);
    hsync:      out std_logic;
    vsync:      out std_logic;
    hblank:     out std_logic;
    vblank:     out std_logic;
    pixelValue: out std_logic
    );
    end component;

    component music
    port (
    clk:      in std_logic;
    fullnote: in std_logic_vector(5 downto 0);
    speaker: out std_logic
    );
    end component;

    signal dc:       std_logic;
    signal clk:      std_logic;
    signal data:     std_logic_vector(7 downto 0);
    signal fullnote: std_logic_vector(5 downto 0);

begin

    video: vgaHdmi
    port map (
    clock      => clk_25m,
    clock100   => clk_100m,
    reset      => lock,
    oled_dc    => dc,
    oled_clk   => clk,
    oled_data  => data,
    buffer_din => buffer_din,
    hsync      => HSync,
    vsync      => VSync,
    hblank     => HBlank,
    vblank     => VBlank,
    pixelValue => pixelValue
    );

    sound: music
    port map (
    clk      => clk_25m,
    fullnote => fullnote,
    speaker  => audio
    );

    -- generic BRAM glue
    glue_bram: entity work.glue_bram
    generic map (
    C_clk_freq => C_clk_freq,
    C_arch => C_arch,
    C_bram_size => C_bram_size,
    C_debug => C_debug
    )
    port map (
    clk => clk_100m,
    sio_rxd(0) => rs232_rxd, -- PIN_AG11 USER_IO[0] (Arduino SCL)
    sio_txd(0) => rs232_txd, -- PIN_AH9  USER_IO[1] (Arduino SDA)
    sio_break(0) => open, spi_miso => "",
    simple_in(31 downto 15) => open,
    simple_in(14 downto 7) => buffer_dout,
    simple_in(6) => sd_ack, simple_in(5 downto 0) => buttons,
    simple_out(31) => sd_rd, simple_out(30) => sd_wr,
    simple_out(29) => glue_wr, simple_out(28 downto 23) => fullnote,
    simple_out(22) => dc, simple_out(21) => clk,
    simple_out(20 downto 18) => open,
    simple_out(17 downto 10) => data,
    simple_out(9 downto 1) => address,
    simple_out(0) => led -- PIN_Y15 LED_USER (GPIO_1[0])
    );

end Behavioral;
