LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY fpmul_tb IS

END fpmul_tb ;

ARCHITECTURE tb of fpmul_tb is

COMPONENT FPmul is
PORT( 
      FP_A : IN     std_logic_vector (31 DOWNTO 0);
      FP_B : IN     std_logic_vector (31 DOWNTO 0);
      clk  : IN     std_logic;
      FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
   );
END component;

COMPONENT data_maker is
port (
    CLK  : in  std_logic;
    DATA : out std_logic_vector(31 downto 0));
	
END component;

COMPONENT reg is
port (
    CLK  : in  std_logic;
    DATA_IN : in std_logic_vector(31 downto 0);
	DATA_OUT : out std_logic_vector(31 downto 0));
end COMPONENT;


signal		temp1, temp2    : std_logic_vector (31 DOWNTO 0);
signal 		inA    : std_logic_vector (31 DOWNTO 0);
signal      inB  :   std_logic_vector (31 DOWNTO 0);
signal      clock :  std_logic;
signal      outZ   : std_logic_vector (31 DOWNTO 0);

begin
	 process
		begin
		clock<='0';
		wait for 5 ns;
		clock<='1';
		wait for 5 ns;
	end process;
	
   	inA <= temp2;
	inB <= temp2;


	data_reg : reg PORT MAP (clock, temp1, temp2);
	data : data_maker PORT MAP (clock, temp1);
	DUT : FPmul PORT MAP (inA, inB, clock, outZ);
end tb;
