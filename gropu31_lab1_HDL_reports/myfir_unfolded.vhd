library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--modifications are commented (see unfolding.txt)

entity myfir_unfolded is
	port(
	CLK     : in  std_logic;
    RST_n   : in  std_logic;
	VIN     : in  std_logic;
	H0      : in std_logic_vector(10 downto 0);
    H1      : in std_logic_vector(10 downto 0);
    H2      : in std_logic_vector(10 downto 0);
    H3      : in std_logic_vector(10 downto 0);
	H4      : in std_logic_vector(10 downto 0);
    H5      : in std_logic_vector(10 downto 0);
    H6      : in std_logic_vector(10 downto 0);
	H7      : in std_logic_vector(10 downto 0);
    H8      : in std_logic_vector(10 downto 0);
--input and output splitted in 3k, 3k+1, 3k+2
	DINK0   : in std_logic_vector(10 downto 0);
	DINK1   : in std_logic_vector(10 downto 0);
	DINK2   : in std_logic_vector(10 downto 0);
	VOUT    : out std_logic;
    DOUTK0  : out std_logic_vector(10 downto 0);
	DOUTK1  : out std_logic_vector(10 downto 0);
	DOUTK2  : out std_logic_vector(10 downto 0)
	);

end myfir_unfolded;

architecture beh of myfir_unfolded is
--when VIN=1 you load a new sample
	constant tco : time := 1 ns;

--2 more signals and output renamed to match new design
--the first number represent k sub and the second the add
--example: out_register12 = (x[k-1]+2)
	--output of the shift register
	signal out_register00: std_logic_vector(10 downto 0);
	signal out_register01: std_logic_vector(10 downto 0);
	signal out_register02: std_logic_vector(10 downto 0);
	signal out_register10: std_logic_vector(10 downto 0);
	signal out_register11: std_logic_vector(10 downto 0);
	signal out_register12: std_logic_vector(10 downto 0);
	signal out_register20: std_logic_vector(10 downto 0);
	signal out_register21: std_logic_vector(10 downto 0);
	signal out_register22: std_logic_vector(10 downto 0);
	signal out_register31: std_logic_vector(10 downto 0);
	signal out_register32: std_logic_vector(10 downto 0);

--we need 27 multipliers
--the first 2 numbers represents the k coefficient and the third the parameter that is multiplied
--example: out_mult217 = x[(3k-2)+1]*7
	--output of the multipliers
	signal out_mult000: signed(21 downto 0);
	signal out_mult001: signed(21 downto 0);
	signal out_mult002: signed(21 downto 0);
	signal out_mult010: signed(21 downto 0);
	signal out_mult011: signed(21 downto 0);
	signal out_mult020: signed(21 downto 0);
	signal out_mult103: signed(21 downto 0);
	signal out_mult104: signed(21 downto 0);
	signal out_mult105: signed(21 downto 0);
	signal out_mult112: signed(21 downto 0);
	signal out_mult113: signed(21 downto 0);
	signal out_mult114: signed(21 downto 0);
	signal out_mult121: signed(21 downto 0);
	signal out_mult122: signed(21 downto 0);
	signal out_mult123: signed(21 downto 0);
	signal out_mult206: signed(21 downto 0);
	signal out_mult207: signed(21 downto 0);
	signal out_mult208: signed(21 downto 0);
	signal out_mult215: signed(21 downto 0);
	signal out_mult216: signed(21 downto 0);
	signal out_mult217: signed(21 downto 0);
	signal out_mult224: signed(21 downto 0);
	signal out_mult225: signed(21 downto 0);
	signal out_mult226: signed(21 downto 0);
	signal out_mult318: signed(21 downto 0);
	signal out_mult327: signed(21 downto 0);
	signal out_mult328: signed(21 downto 0);

--we introduce a pipeline after the multiplication thus we need to replicate these signals out of a register
--the notation is the same as before, we just add r

	signal out_mult000r: signed(21 downto 0);
	signal out_mult001r: signed(21 downto 0);
	signal out_mult002r: signed(21 downto 0);
	signal out_mult010r: signed(21 downto 0);
	signal out_mult011r: signed(21 downto 0);
	signal out_mult020r: signed(21 downto 0);
	signal out_mult103r: signed(21 downto 0);
	signal out_mult104r: signed(21 downto 0);
	signal out_mult105r: signed(21 downto 0);
	signal out_mult112r: signed(21 downto 0);
	signal out_mult113r: signed(21 downto 0);
	signal out_mult114r: signed(21 downto 0);
	signal out_mult121r: signed(21 downto 0);
	signal out_mult122r: signed(21 downto 0);
	signal out_mult123r: signed(21 downto 0);
	signal out_mult206r: signed(21 downto 0);
	signal out_mult207r: signed(21 downto 0);
	signal out_mult208r: signed(21 downto 0);
	signal out_mult215r: signed(21 downto 0);
	signal out_mult216r: signed(21 downto 0);
	signal out_mult217r: signed(21 downto 0);
	signal out_mult224r: signed(21 downto 0);
	signal out_mult225r: signed(21 downto 0);
	signal out_mult226r: signed(21 downto 0);
	signal out_mult318r: signed(21 downto 0);
	signal out_mult327r: signed(21 downto 0);
	signal out_mult328r: signed(21 downto 0);
 
--every path needs 8 adders
--the first number represents the k path and the second the adder number (0 should become the output)
	--added value
	signal added_value00: signed(21 downto 0);
	signal added_value01: signed(21 downto 0);
	signal added_value02: signed(21 downto 0);
	signal added_value03: signed(21 downto 0);
	signal added_value04: signed(21 downto 0);
	signal added_value05: signed(21 downto 0);
	signal added_value06: signed(21 downto 0);
	signal added_value07: signed(21 downto 0);

	signal added_value10: signed(21 downto 0);
	signal added_value11: signed(21 downto 0);
	signal added_value12: signed(21 downto 0);
	signal added_value13: signed(21 downto 0);
	signal added_value14: signed(21 downto 0);
	signal added_value15: signed(21 downto 0);
	signal added_value16: signed(21 downto 0);
	signal added_value17: signed(21 downto 0);

	signal added_value20: signed(21 downto 0);
	signal added_value21: signed(21 downto 0);
	signal added_value22: signed(21 downto 0);
	signal added_value23: signed(21 downto 0);
	signal added_value24: signed(21 downto 0);
	signal added_value25: signed(21 downto 0);
	signal added_value26: signed(21 downto 0);
	signal added_value27: signed(21 downto 0);

--because of new pipeline level we need another VOUT_internal signal
	signal VOUT_internal1: std_logic;
	signal VOUT_internal2: std_logic;
begin

--the process now has to distinguish between k paths to shift 
	process (CLK, RST_n) --shift register process
		begin
		if RST_n = '0' then                 -- asynchronous reset (active low)
--path 0
      out_register00 <= (others => '0') after tco; 
      out_register10 <= (others => '0') after tco; 
      out_register20 <= (others => '0') after tco; 
      
--path 1
	  out_register01 <= (others => '0') after tco; 
      out_register11 <= (others => '0') after tco; 
      out_register21 <= (others => '0') after tco; 
      out_register31 <= (others => '0') after tco;
--path2
	  out_register02 <= (others => '0') after tco; 
      out_register12 <= (others => '0') after tco; 
      out_register22 <= (others => '0') after tco; 
      out_register32 <= (others => '0') after tco;
           
      VOUT_internal1 <= '0' after tco;
      
    	elsif CLK'event and CLK = '1' then  -- rising clock edge
			if VIN = '1' then
				--shift the coefficients
-- path 0
				out_register10 <= out_register00;
				out_register20 <= out_register10;
-- path 1
				out_register11 <= out_register01;
				out_register21 <= out_register11;
				out_register31 <= out_register21;
-- path 2
				out_register12 <= out_register02;
				out_register22 <= out_register12;
				out_register32 <= out_register22;
--new value added for each path
				out_register00 <= DINK0;
				out_register01 <= DINK1;
				out_register02 <= DINK2;
				--change VOUT
				VOUT_internal1 <= '1';
			else
				VOUT_internal1 <= '0';
			end if;
		end if;
	end process;

--now we need to perform 27 multiplications following the unfolding.txt file

	out_mult000 <= signed(out_register00) * signed(H0);
	out_mult001 <= signed(out_register00) * signed(H1);
	out_mult002 <= signed(out_register00) * signed(H2);
	out_mult010 <= signed(out_register01) * signed(H0);
	out_mult011 <= signed(out_register01) * signed(H1);
	out_mult020 <= signed(out_register02) * signed(H0);

	out_mult103 <= signed(out_register10) * signed(H3);
	out_mult104 <= signed(out_register10) * signed(H4);
	out_mult105 <= signed(out_register10) * signed(H5);
	out_mult112 <= signed(out_register11) * signed(H2);
	out_mult113 <= signed(out_register11) * signed(H3);
	out_mult114 <= signed(out_register11) * signed(H4);
	out_mult121 <= signed(out_register12) * signed(H1);
	out_mult122 <= signed(out_register12) * signed(H2);
	out_mult123 <= signed(out_register12) * signed(H3);

	out_mult206 <= signed(out_register20) * signed(H6);
	out_mult207 <= signed(out_register20) * signed(H7);
	out_mult208 <= signed(out_register20) * signed(H8);
	out_mult215 <= signed(out_register21) * signed(H5);
	out_mult216 <= signed(out_register21) * signed(H6);
	out_mult217 <= signed(out_register21) * signed(H7);
	out_mult224 <= signed(out_register22) * signed(H4);
	out_mult225 <= signed(out_register22) * signed(H5);
	out_mult226 <= signed(out_register22) * signed(H6);

	out_mult318 <= signed(out_register31) * signed(H8);
	out_mult327 <= signed(out_register32) * signed(H7);
	out_mult328 <= signed(out_register32) * signed(H8);

--now we add a process to simulate the pipeline after the multipliers

process (CLK, RST_n) --shift register process
		begin
		if RST_n = '0' then                 -- asynchronous reset (active low)
			out_mult000r <= (others => '0') after tco;
			out_mult001r <= (others => '0') after tco;
			out_mult002r <= (others => '0') after tco;
			out_mult010r <= (others => '0') after tco;
			out_mult011r <= (others => '0') after tco;
			out_mult020r <= (others => '0') after tco;
			out_mult103r <= (others => '0') after tco;
			out_mult104r <= (others => '0') after tco;
			out_mult105r <= (others => '0') after tco;
			out_mult112r <= (others => '0') after tco;
			out_mult113r <= (others => '0') after tco;
			out_mult114r <= (others => '0') after tco;
			out_mult121r <= (others => '0') after tco;
			out_mult122r <= (others => '0') after tco;
			out_mult123r <= (others => '0') after tco;
			out_mult206r <= (others => '0') after tco;
			out_mult207r <= (others => '0') after tco;
			out_mult208r <= (others => '0') after tco;
			out_mult215r <= (others => '0') after tco;
			out_mult216r <= (others => '0') after tco;
			out_mult217r <= (others => '0') after tco;
			out_mult224r <= (others => '0') after tco;
			out_mult225r <= (others => '0') after tco;
			out_mult226r <= (others => '0') after tco;
			out_mult318r <= (others => '0') after tco;
			out_mult327r <= (others => '0') after tco;
			out_mult328r <= (others => '0') after tco;
	
			VOUT_internal2 <= '0' after tco;

		elsif CLK'event and CLK = '1' then  -- rising clock edge
			
	out_mult000r <= out_mult000;
	out_mult001r <= out_mult001;
	out_mult002r <= out_mult002;
	out_mult010r <= out_mult010;
	out_mult011r <= out_mult011;
	out_mult020r <= out_mult020;

	out_mult103r <= out_mult103 ;
	out_mult104r <= out_mult104;
	out_mult105r <= out_mult105;
	out_mult112r <= out_mult112;
	out_mult113r <= out_mult113;
	out_mult114r <= out_mult114;
	out_mult121r <= out_mult121;
	out_mult122r <= out_mult122;
	out_mult123r <= out_mult123;

	out_mult206r <= out_mult206;
	out_mult207r <= out_mult207;
	out_mult208r <= out_mult208;
	out_mult215r <= out_mult215;
	out_mult216r <= out_mult216;
	out_mult217r <= out_mult217;
	out_mult224r <= out_mult224;
	out_mult225r <= out_mult225;
	out_mult226r <= out_mult226;

	out_mult318r <= out_mult318;
	out_mult327r <= out_mult327;
	out_mult328r <= out_mult328;

			--change VOUT
			VOUT_internal2 <= VOUT_internal1;
			
		end if;
	end process;

-- we need 8 additions for each path using the signals out of the pipeline register
--path 0
	added_value07 <= out_mult318r + out_mult327r;
	added_value06 <= added_value07 + out_mult224r;
	added_value05 <= added_value06 + out_mult215r;
	added_value04 <= added_value05 + out_mult206r;
	added_value03 <= added_value04 + out_mult121r;
	added_value02 <= added_value03 + out_mult112r;
	added_value01 <= added_value02 + out_mult103r;
	added_value00 <= added_value01 + out_mult000r;
--path 1
	added_value17 <= out_mult328r + out_mult225r;
	added_value16 <= added_value17 + out_mult216r;
	added_value15 <= added_value16 + out_mult207r;
	added_value14 <= added_value15 + out_mult122r;
	added_value13 <= added_value14 + out_mult113r;
	added_value12 <= added_value13 + out_mult104r;
	added_value11 <= added_value12 + out_mult010r;
	added_value10 <= added_value11 + out_mult001r;
--path 2
	added_value27 <= out_mult226r + out_mult217r;
	added_value26 <= added_value27 + out_mult208r;
	added_value25 <= added_value26 + out_mult123r;
	added_value24 <= added_value25 + out_mult114r;
	added_value23 <= added_value24 + out_mult105r;
	added_value22 <= added_value23 + out_mult020r;
	added_value21 <= added_value22 + out_mult011r;
	added_value20 <= added_value21 + out_mult002r;

--the 3 output are separated
	process (CLK, RST_n) --output process
		begin
			if RST_n = '0' then                 -- asynchronous reset (active low)

				DOUTK0 <= (others => '0') after tco;
				DOUTK1 <= (others => '0') after tco;
				DOUTK2 <= (others => '0') after tco;
      
    		elsif CLK'event and CLK = '1' then  -- rising clock edge
				
--every sum is assigned to the corresponding output
				DOUTK0 <= std_logic_vector(added_value00( 20 downto 10));
				DOUTK1 <= std_logic_vector(added_value10( 20 downto 10));
				DOUTK2 <= std_logic_vector(added_value20( 20 downto 10));
			end if;
		end process;

--same as the other one but we use VOUT_internal2
	process (CLK, RST_n) --vout process
		begin
			if RST_n = '0' then                 -- asynchronous reset (active low)

				VOUT <= '0' after tco;
      
    		elsif CLK'event and CLK = '1' then  -- rising clock edge
				
				VOUT <= VOUT_internal2;
			end if;
		end process;
end beh;
		

