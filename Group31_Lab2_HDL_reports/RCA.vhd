library ieee;
use ieee.std_logic_1164.all;
 
entity RCA is
  
  port (
    i_add_term1  : in std_logic_vector(47 downto 0);
    i_add_term2  : in std_logic_vector(47 downto 0);
    --
    o_result   : out std_logic_vector(48 downto 0)
    );
end RCA;
 
 
architecture rtl of RCA is
 
  component FA is
    port (
    A : in std_logic;
	B : in std_logic;
	Cin : in std_logic;
	S : out std_logic;
	Cout : out std_logic); 
  end component;
 
  signal w_CARRY : std_logic_vector(48 downto 0);
  signal w_SUM   : std_logic_vector(47 downto 0);
 
   
begin
 
  w_CARRY(0) <= '0';                    -- no carry input on first full adder
   
  SET_WIDTH : for ii in 0 to 47 generate
    i_FULL_ADDER_INST : FA
      port map (
        A => i_add_term1(ii),
        B => i_add_term2(ii),
        Cin=> w_CARRY(ii),
        S  => w_SUM(ii),
        Cout => w_CARRY(ii+1)
        );
  end generate SET_WIDTH;
 
  o_result <= w_CARRY(48) & w_SUM;  -- VHDL Concatenation
   
end rtl;
