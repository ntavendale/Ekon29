-- Copyright 2025 Nigel Tavendale
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this code 
-- associated documentation files (the “Code”), to deal in the Code without restriction, including 
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Code, and to permit persons to whom the Code is furnished to do so, 
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial 
-- portions of the Code.
--
-- THE CODE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
-- SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Use at least VHDL 2008 when building.

entity UART_Loopback_Top is
  generic (
      BASYS3_CLKS_PER_BIT : integer := 868; -- 100,000,000 / 115,200 = 868
      DEBOUNCE_LIMIT : integer := 1000000 
  );
  port (
    -- Main clock 100 MHz
    clk   : in std_logic;
    -- UART Data
    RsRx : in  std_logic;
    -- center button
    btnC  : in std_logic;
    
    RsTx : out std_logic;
    -- There are 4 anode pins. Reference them as a vector instead of individually
    an   : out std_logic_vector (3 downto 0);
    -- There are 7 segment pins. Reference them as a vector instead of individually
    seg  : out std_logic_vector (6 downto 0)
  );
end UART_Loopback_Top;

architecture RTL of UART_Loopback_Top is
  signal w_RX_DV     : std_logic;
  signal w_RX_Byte   : std_logic_vector(7 downto 0);
  signal w_TX_Active : std_logic;
  signal w_TX_Serial : std_logic;
  signal w_Center_Button : std_logic := '0';
begin
  -- Decounce_Filter.vhd
  Debouncer : entity work.Debounce_Filter
    generic map (DEBOUNCE_LIMIT => DEBOUNCE_LIMIT)
    port map (
      i_Clk_Signal   => clk,
      i_Noisy_Signal => btnC,
      o_Debounced    => w_Center_Button);
      
  -- UART_RX.vhd
  ART_RX_Inst : entity work.UART_RX
    generic map (CLKS_PER_BIT => BASYS3_CLKS_PER_BIT)
    port map (
      i_Rx_Clk    => clk,
      i_RX_Serial => RsRx,
      i_Reset     => w_Center_Button,
      o_RX_DV     => w_RX_DV,
      o_RX_Byte   => w_RX_Byte);
 
 
  -- Creates a simple loopback to test TX and RX
  -- UART_TX.vhd
  UART_TX_Inst : entity work.UART_TX
    generic map (
      CLKS_PER_BIT => BASYS3_CLKS_PER_BIT)               
    port map (
      i_TX_Clk    => clk,
      i_TX_DV     => w_RX_DV,
      i_TX_Byte   => w_RX_Byte,
      o_TX_Active => w_TX_Active,
      o_TX_Serial => w_TX_Serial,
      o_TX_Done   => open
      );
 
  --This will Drive UART line high when transmitter is not active, indicating idle.
  -- Otherwise the Byte transmitted will be echoed back. When running in a terminal 
  -- it is the echo back that causes the key characters to print, NOT the key press itself.
  -- Replace this with RsTx <= '1' and you can press the keys, and see the key code
  -- displayed on the board's seven segment display, but you won't see characters in the terminal.
  RsTx <= w_TX_Serial when w_TX_Active = '1' else '1';
  
  -- Seven_Segment_Display_Binary.vhd
  -- Drive Basys 3 Display to show scan codes of key presses
  -- The right most two of the seven segment displays wil display
  -- a nibble (0-F) each. The leftmost will display 0s.
  SevenSeg1_Inst : entity work.Seven_Segment_Display_Binary
    port map (
      i_Clock       => clk,
      i_Reset       => w_Center_Button,
      i_Displayed   => (7 downto 0 => w_RX_Byte, others => '0'),
      o_Anodes      => an,
      o_Segments    => seg
      );

end RTL;
