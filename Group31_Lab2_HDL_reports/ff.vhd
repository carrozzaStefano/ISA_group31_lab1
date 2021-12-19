library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity ff is
  
  port (
    CLK  : in  std_logic;
    DATA_IN : in std_logic;
	DATA_OUT : out std_logic);
	
end ff;

architecture beh of ff is

	begin
	process(CLK)
		begin
		if CLK'event and CLK = '1' then
			DATA_OUT <= DATA_IN;
		end if;
	end process;

end architecture;
