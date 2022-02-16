LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mux_gen is
  generic (N : integer := 32);
  port (
    selector	: in std_logic;
    In1,In2		: in std_logic_vector(N-1 downto 0);
	DATA_OUT 	: out std_logic_vector(N-1 downto 0));
end mux_gen;

architecture beh of mux_gen is
begin
muxing:	process(In1, In2, selector)
		begin
		if (selector = '0') then	
			DATA_OUT <= In1;
		else	
			DATA_OUT <= In2;
		end if;
	end process;
end architecture;
