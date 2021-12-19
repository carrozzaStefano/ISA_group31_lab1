LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY level1 IS
PORT(
-- lines at input
	line1: in  std_logic_vector(47 downto 0);
	line2: in  std_logic_vector(47 downto 0);
	line3: in  std_logic_vector(47 downto 0);
-- output lines where for the first time length is 49
	out1: out  std_logic_vector(48 downto 0);
	out2: out  std_logic_vector(48 downto 0)

);
END ENTITY level1;



	


ARCHITECTURE beh OF level1 IS

--components HA and FA
	component FA is
	port(
	A : in std_logic;
	B : in std_logic;
	Cin : in std_logic;
	S : out std_logic;
	Cout : out std_logic
	);
	end component;
	
	component HA is
	port(
	A : in std_logic;
	B : in std_logic;
	S : out std_logic;
	C : out std_logic
	);
	end component;
	
-- signal for carry bits
-- on this level we need 1
	signal carry : std_logic_vector(48 downto 0);
	
BEGIN

-- generate of FA 
	FA_GEN:
	for i in 3 to 47 generate
	FAx : FA port map(line1(i), line2(i), line3(i), out1(i), carry(i+1));
	end generate;
	
-- generate of HA
	HAx2 : HA port map(line1(2), line2(2), out1(2), carry(3));
	

-- output definition: we have to group together the carry, the results of the adders and the unchanged dots
--definition of out1 --> unchanged dots in column 0,1
	out1(1 downto 0) <= line1(1 downto 0);
	out1(48) <= '0';
	
--definition of out2 --> the carry vector and unchanged dot in column 0,1,2
	out2(48 downto 3) <= carry(48 downto 3);
	out2(0) <= line2(0);
	out2(1) <= line2(1);
	out2(2) <= line3(2);
	
END ARCHITECTURE;

