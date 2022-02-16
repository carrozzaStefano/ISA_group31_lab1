LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity adder4 is
  port (
    Input		: in std_logic_vector(63 downto 0);
	Output		: out std_logic_vector(63 downto 0));
end adder4;
architecture beh of adder4 is
	signal sum : unsigned (63 downto 0);
begin
	sum <= unsigned(Input) + 4;
	Output <= std_logic_vector(sum);
end architecture;