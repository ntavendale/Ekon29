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
-- OTHER DEALINGS IN THE CODE.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Debounce_Filter is
  -- DEBOUNCE_LIMIT is like a parameter with a default of 1,000,000
  -- The Basys3 has a 100MHz clock (100 cycles per uSec) and we 
  -- want the noisy signal to be stable for 10 ms. 
  -- 100 cycles per uSec = 100,000 cycles per mSec so 10 mSec is
  -- 100,000 cycles x 10 = 1,000,0000 clock cycles.
  -- When using this module from a top level moduel we can set this 
  -- to a different number
  generic (DEBOUNCE_LIMIT : integer := 1000000);
  port (
    i_Clk_Signal   : in std_logic;
    i_Noisy_Signal : in std_logic;
    o_Debounced    : out std_logic
    );
end entity Debounce_Filter;

architecture RTL of Debounce_Filter is  
  -- register to hold the number of time we have processed
  -- a rising edge clock signal
  -- it maxes out at (DEBOUNCE_LIMIT - 1) so once it's value hits 
  -- that limit it can't be incremented any further.
  -- in synthesis you get an error. On actual hardware ith will wrap to 0 
  signal r_Count : integer range 0 to DEBOUNCE_LIMIT := 0;
  
  signal r_State : std_logic := '0';
begin
  process (i_Clk_Signal) is
  begin
    -- change our state on rising edge
    if rising_edge(i_Clk_Signal) then
      -- is the input signal different from r_state (i.e "1" for high)
      -- and does the r_Count register hold a value less then DEBOUNCE_LIMIT?
      -- if this state is true then incremrnt the r_Count register value.  
      if (i_Noisy_Signal /= r_State and r_Count < DEBOUNCE_LIMIT - 1) then
        r_Count <= r_Count + 1;
      elsif r_count = DEBOUNCE_LIMIT -1 then 
        -- r_Count has maxed out This occurs after input_signal has been different 
        -- from r_State (ie inpout is high) for DEBOUNCE_LIMIT clock cycles
        -- At this point we can be sure it was actuaslly pressed and assign it's value to the 
        -- r_State signal 
        r_State <= i_Noisy_Signal;
        r_Count <= 0;
      else
        -- input_signal is not high so reset r_count regisater value to 0
        -- if it was previously high but less then DEBOUNCE_LIMIT clock cycles
        -- had occured and it is now low, the high was most likely noise.
        r_Count <= 0;
      end if;  
    end if;
  end process;
  -- now we have processed the clock pulse we can set out output signal
  o_Debounced <= r_State;
end architecture RTL;
