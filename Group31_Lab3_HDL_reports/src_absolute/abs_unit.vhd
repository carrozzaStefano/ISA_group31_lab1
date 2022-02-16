LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity abs_unit is
  port(
	data_in: in std_logic_vector(63 downto 0);
	data_out: out  std_logic_vector(63 downto 0)
	
	);
    
end abs_unit;
architecture beh of abs_unit is
	signal signed_signal : signed(63 downto 0);
begin
	process(data_in)
	begin
		if data_in(63) = '1' then
			--negative
			signed_signal <= -signed(data_in);
		else
			signed_signal <= signed(data_in);
		end if;
	end process;
	data_out <= std_logic_vector(signed_signal);
end architecture;
