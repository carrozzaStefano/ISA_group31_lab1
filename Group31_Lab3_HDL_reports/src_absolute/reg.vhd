library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity reg is
  generic (N : integer := 32);
  port (
    CLK  : in  std_logic;
	RST  : in  std_logic;
	EN   : in  std_logic;
    DATA_IN : in std_logic_vector(N-1 downto 0);
	DATA_OUT : out std_logic_vector(N-1 downto 0));
	
end reg;

architecture beh of reg is

	begin
	process(CLK)
		begin	
		if CLK'event and CLK = '1' then
			if RST = '0' then
				if EN = '1' then
					DATA_OUT <= DATA_IN;
				end if;
			else
			DATA_OUT <= (others => '0');
			end if;
		end if;
	end process;

end architecture;
