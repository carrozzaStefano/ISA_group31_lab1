LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity adder64bit is
  port (
    Input1,Input2		: in std_logic_vector(63 downto 0);
	Output		: out std_logic_vector(63 downto 0));
end adder64bit;
architecture beh of adder64bit is
	signal sum : signed(63 downto 0);
begin
	sum <= signed(Input1) + signed(Input2);
	Output <= std_logic_vector(sum);
end architecture;
