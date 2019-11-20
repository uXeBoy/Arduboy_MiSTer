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
    clk_50m: in std_logic;
    rs232_txd: out std_logic;
    rs232_rxd: in std_logic;
    led: out std_logic_vector(7 downto 0);
    btn_left, btn_right: in std_logic;
    sw: in std_logic_vector(3 downto 0);
    gpioa: inout std_logic_vector(33 downto 16);

    HDMI_TX_D:      out std_logic_vector(23 downto 0);
    HDMI_TX_VS:     out std_logic;
    HDMI_TX_HS:     out std_logic;
    HDMI_TX_DE:     out std_logic;
    HDMI_TX_CLK:    out std_logic;
    HDMI_TX_INT:     in std_logic;
    HDMI_I2C_SDA: inout std_logic;
    HDMI_I2C_SCL:   out std_logic
    );
end glue;

architecture Behavioral of glue is

    component vgaHdmi
    port (
    clock:       in std_logic;
    clock50:     in std_logic;
    clock100:    in std_logic;
    reset:       in std_logic;
    hsync:      out std_logic;
    vsync:      out std_logic;
    dataEnable: out std_logic;
    vgaClock:   out std_logic;
    oled_dc:     in std_logic;
    oled_clk:    in std_logic;
    oled_data:   in std_logic_vector(7 downto 0);
    RGBchannel: out std_logic_vector(23 downto 0)
    );
    end component;

    component I2C_HDMI_Config
    port (
    iCLK:        in std_logic;
    I2C_SCLK:   out std_logic;
    I2C_SDAT: inout std_logic;
    HDMI_TX_INT: in std_logic
    );
    end component;

    component pll_50m
    port (
    refclk:    in std_logic;
    outclk_0: out std_logic;
    outclk_1: out std_logic;
    locked:   out std_logic
    );
    end component;

    signal clk_100m: std_logic;
    signal clk_25m:  std_logic;
    signal lock:     std_logic;
    signal dc:       std_logic;
    signal clk:      std_logic;
    signal data:     std_logic_vector(7 downto 0);

begin

    video: vgaHdmi
    port map (
    clock      => clk_25m,
    clock50    => clk_50m,
    clock100   => clk_100m,
    reset      => lock,
    hsync      => HDMI_TX_HS,
    vsync      => HDMI_TX_VS,
    dataEnable => HDMI_TX_DE,
    vgaClock   => HDMI_TX_CLK,
    oled_dc    => dc,
    oled_clk   => clk,
    oled_data  => data,
    RGBchannel => HDMI_TX_D
    );

    I2C: I2C_HDMI_Config
    port map (
    iCLK        => clk_50m,
    I2C_SCLK    => HDMI_I2C_SCL,
    I2C_SDAT    => HDMI_I2C_SDA,
    HDMI_TX_INT => HDMI_TX_INT
    );

    clock: pll_50m
    port map (
    refclk   => clk_50m,
    outclk_0 => clk_100m,
    outclk_1 => clk_25m,
    locked   => lock
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
    sio_txd(0) => rs232_txd, sio_rxd(0) => rs232_rxd,
    sio_break(0) => open,
    gpio(31 downto 16) => gpioa(31 downto 16), gpio(15 downto 0) => open,
    spi_miso => "",
    simple_out(31 downto 18) => open, simple_out(17) => dc, simple_out(16) => clk,
    simple_out(15 downto 8) => data, simple_out(7 downto 0) => led,
    simple_in(31 downto 20) => open, simple_in(19 downto 16) => sw,
    simple_in(15) => btn_left, simple_in(14) => btn_right,
    simple_in(13 downto 0) => open
    );

end Behavioral;
