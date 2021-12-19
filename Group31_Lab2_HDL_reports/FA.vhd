library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity FA is
  port (
    A : in std_logic;
	B : in std_logic;
	Cin : in std_logic;
	S : out std_logic;
	Cout : out std_logic); 
end FA;

architecture beh of FA is

begin
	-- S is the sum bit
	S <= A xor B xor Cin;

	-- Cout is the carry out bit
	Cout <= (A and (B or Cin)) or (B and Cin);
end beh;
