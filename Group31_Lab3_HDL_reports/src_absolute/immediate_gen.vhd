LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity immediate_gen is
  port (
    Input		: in std_logic_vector(31 downto 0);
	-- signal that come from the CU and select in which case of immediate we are
	case_selection : in std_logic_vector(2 downto 0);
	Output		: out std_logic_vector(63 downto 0));
end immediate_gen;
architecture beh of immediate_gen is

begin
-- choice should be done in control unit
process(case_selection, input)
	begin
	case case_selection is
	when "000" =>
	--Immediate
	Output(11 downto 0) <= Input(31 downto 20);
	Output(63 downto 12) <= (Others => Input(31));

	
	when "001" =>
	--Store
	Output(10 downto 5) <= Input(30 downto 25);
	Output(63 downto 11) <= (Others => Input(31));
	Output(4 downto 0) <= Input(11 downto 7);
	
	
	when "010" =>
	--Branch
	Output(10 downto 5) <= Input(30 downto 25);
	Output(63 downto 12) <= (Others => Input(31));
	Output(4 downto 1) <= Input(11 downto 8);
	Output(11) <= Input(7);
	Output(0) <= '0';
	
	
	when "100" =>
	--jump
	Output(19 downto 12) <= Input(19 downto 12);
	Output(10 downto 1) <= Input(30 downto 21);
	Output(20) <= Input(31);
	Output(11) <= Input(20);
	Output(0) <= '0';
	Output(63 downto 21) <= (Others => Input(31));
	
	when "101" =>
	--U LUI and AUIPC
	
	output (31 downto 12) <= input(31 downto 12);
	output (63 downto 32) <=(others => '0');
	output (11 downto 0) <=(others => '0');	
	
	when others => -- error or not an immediate 
	output <= (others => '0');
	
	end case;
end process;

end architecture;
