LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU is
  port (
  --for reg1 and mux of reg2 and immediate
    Input1,Input2		: in std_logic_vector(63 downto 0);
  --CONTROL Input1
  -- mux signals used to select the case
  -- ONLY ONE OF THEM SHOULD BE SET AT THE SAME TIME!!
  -- else we could encode them in some way
	sum_sub_sel, and_xor_sel, shift_sel, LUI_sel, SLT_sel : in std_logic;
  -- control for absolute unit
	absolute_sel : in std_logic;
  -- sum and sub bit 0 if sum, 1 if sub
	Sumn_Sub	: in std_logic;
  -- and xor bit 0 if and, 1 if xor
	andin_xor	: in std_logic;
  -- is 1 if the result of the subtraction is 0, => should be sent to control unit for branch mux
	IsZero		: out std_logic;
  --result of the operation	
	Output		: out std_logic_vector(63 downto 0));
end ALU;
architecture beh of ALU is
-- possible results of the ALU op depending on control signals 
	signal sum : signed (63 downto 0);
	signal shifted : std_logic_vector(63 downto 0);
	signal and_xor : std_logic_vector(63 downto 0);
	signal overwrite : std_logic_vector(63 downto 0);

-- signal added for absolute
	signal absolute : std_logic_vector(63 downto 0);
-- component added for absolute unit
component abs_unit is
  port(
	data_in :in  std_logic_vector(63 downto 0);
	data_out :out  std_logic_vector(63 downto 0)
	
	);
    
end component;
begin

ABSOLUTE_CALCULATION: abs_unit port map(Input1, absolute);
	
First_alu:	process(Input1, Input2, Sumn_Sub, andin_xor)
	begin
		
		-- sum and sub; sub sign is also used for SLT case
		if (Sumn_Sub = '0') then
			sum <= signed(Input1) + signed(Input2);
		else	
			sum <= signed(Input1) - signed(Input2);
		end if;
		-- shift calc
		-- shift right of the Input2 value
		shifted <= std_logic_vector(shift_right(signed(Input1), to_integer(unsigned(Input2))));
--shifted <= std_logic_vector(shift_right(unsigned(Input1), 31));
		-- andi xor calc
		if (andin_xor = '0') then
			and_xor <= Input1 and Input2;
		else
			and_xor <= Input1 xor Input2;
		end if;
		-- overwrite value used only in LUI operation
		overwrite (63 downto 44) <= Input2(31 downto 12);
		overwrite (43 downto 0) <= (others => '0');
	end process;
	
	-- output decision process
Second_Alu:	process(sum, shifted, and_xor, overwrite, sum_sub_sel, and_xor_sel, shift_sel, LUI_sel, absolute_sel, absolute)
	begin
		if(sum_sub_sel = '1') then
			Output <= std_logic_vector(sum);
		elsif(and_xor_sel = '1') then
			Output <= and_xor;
		elsif(shift_sel = '1') then
			Output <= shifted;
		elsif(SLT_sel = '1') then
			Output <= (others => sum(63));
		elsif(LUI_sel = '1') then
			Output <= (overwrite);
		elsif(absolute_sel ='1') then
			Output <= absolute;
		else
			--BEQ or maybe NOP
			Output <= (others => '0');
		end if;
	end process;
	
	--is zero process
summing:	process(sum, Sumn_Sub)

	begin	
		IsZero <= '0';
		if (Sumn_Sub = '1') then
			if sum = "0000000000000000000000000000000000000000000000000000000000000000" then
				IsZero <= '1';
			end if;
		end if;			
	end process;
	
end architecture;
