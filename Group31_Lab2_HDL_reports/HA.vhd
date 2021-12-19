library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity HA is
  port (
    A : in std_logic;
	B : in std_logic;
	S : out std_logic;
	C : out std_logic); 
end HA;

architecture beh of HA is

begin
	-- S is the sum bit
	S <= A xor B;

	-- C is the carry out bit
	C <= A and B;
end beh;
