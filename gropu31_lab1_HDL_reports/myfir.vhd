library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity myfir is
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
	DIN     : in std_logic_vector(10 downto 0);
	VOUT    : out std_logic;
    DOUT    : out std_logic_vector(10 downto 0)
	);

end myfir;

architecture beh of myfir is
--when VIN=1 you load a new sample
	constant tco : time := 1 ns;

	--output of the shift register
	signal out_register0: std_logic_vector(10 downto 0);
	signal out_register1: std_logic_vector(10 downto 0);
	signal out_register2: std_logic_vector(10 downto 0);
	signal out_register3: std_logic_vector(10 downto 0);
	signal out_register4: std_logic_vector(10 downto 0);
	signal out_register5: std_logic_vector(10 downto 0);
	signal out_register6: std_logic_vector(10 downto 0);
	signal out_register7: std_logic_vector(10 downto 0);
	signal out_register8: std_logic_vector(10 downto 0);

	--output of the multipliers
	signal out_mult0: signed(21 downto 0);
	signal out_mult1: signed(21 downto 0);
	signal out_mult2: signed(21 downto 0);
	signal out_mult3: signed(21 downto 0);
	signal out_mult4: signed(21 downto 0);
	signal out_mult5: signed(21 downto 0);
	signal out_mult6: signed(21 downto 0);
	signal out_mult7: signed(21 downto 0);
	signal out_mult8: signed(21 downto 0);

	--added value
	signal added_value0: signed(21 downto 0);
	signal added_value1: signed(21 downto 0);
	signal added_value2: signed(21 downto 0);
	signal added_value3: signed(21 downto 0);
	signal added_value4: signed(21 downto 0);
	signal added_value5: signed(21 downto 0);
	signal added_value6: signed(21 downto 0);
	signal added_value7: signed(21 downto 0);

	signal VOUT_internal: std_logic;
begin
	process (CLK, RST_n) --shift register process
		begin
		if RST_n = '0' then                 -- asynchronous reset (active low)
      out_register0 <= (others => '0') after tco; 
      out_register1 <= (others => '0') after tco; 
      out_register2 <= (others => '0') after tco; 
      out_register3 <= (others => '0') after tco; 
      out_register4 <= (others => '0') after tco; 
      out_register5 <= (others => '0') after tco; 
      out_register6 <= (others => '0') after tco; 
      out_register7 <= (others => '0') after tco; 
      out_register8 <= (others => '0') after tco;      
      VOUT_internal <= '0' after tco;
      
    	elsif CLK'event and CLK = '1' then  -- rising clock edge
			if VIN = '1' then
				--shift the coefficients
				out_register1 <= out_register0;
				out_register2 <= out_register1;
				out_register3 <= out_register2;
				out_register4 <= out_register3;
				out_register5 <= out_register4;
				out_register6 <= out_register5;
				out_register7 <= out_register6;
				out_register8 <= out_register7;
				--load new value
				out_register0 <= DIN;
				--change VOUT
				VOUT_internal <= '1';
			else
				VOUT_internal <= '0';
			end if;
		end if;
	end process;

	--multipliers
	out_mult0 <= signed(out_register0) * signed(H0);
	out_mult1 <= signed(out_register1) * signed(H1);
	out_mult2 <= signed(out_register2) * signed(H2);
	out_mult3 <= signed(out_register3) * signed(H3);
	out_mult4 <= signed(out_register4) * signed(H4);
	out_mult5 <= signed(out_register5) * signed(H5);
	out_mult6 <= signed(out_register6) * signed(H6);
	out_mult7 <= signed(out_register7) * signed(H7);
	out_mult8 <= signed(out_register8) * signed(H8);

	--adders
	added_value7 <= out_mult8 + out_mult7;
	added_value6 <= added_value7 + out_mult6;
	added_value5 <= added_value6 + out_mult5;
	added_value4 <= added_value5 + out_mult4;
	added_value3 <= added_value4 + out_mult3;
	added_value2 <= added_value3 + out_mult2;
	added_value1 <= added_value2 + out_mult1;
	added_value0 <= added_value1 + out_mult0;

	process (CLK, RST_n) --output process
		begin
			if RST_n = '0' then                 -- asynchronous reset (active low)

				DOUT <= (others => '0') after tco;
      
    		elsif CLK'event and CLK = '1' then  -- rising clock edge
				
				DOUT <= std_logic_vector(added_value0( 20 downto 10));
			end if;
		end process;

	process (CLK, RST_n) --vout process
		begin
			if RST_n = '0' then                 -- asynchronous reset (active low)

				VOUT <= '0' after tco;
      
    		elsif CLK'event and CLK = '1' then  -- rising clock edge
				
				VOUT <= VOUT_internal;
			end if;
		end process;
	end beh;
		

