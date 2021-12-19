LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY level2 IS
PORT(
-- lines at input
	line1: in  std_logic_vector(47 downto 0);
	line2: in  std_logic_vector(47 downto 0);
	line3: in  std_logic_vector(47 downto 0);
	line4: in  std_logic_vector(47 downto 0);
-- output lines 
	out1: out  std_logic_vector(47 downto 0);
	out2: out  std_logic_vector(47 downto 0);
	out3: out  std_logic_vector(47 downto 0)

);
END ENTITY level2;

ARCHITECTURE beh OF level2 IS

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
	signal carry : std_logic_vector(47 downto 0);
	
BEGIN

-- generate of FA
	FA_GEN:
	for i in 5 to 45 generate
	FAx : FA port map(line1(i), line2(i), line3(i), out1(i), carry(i+1));
	end generate;
	
-- generate of HA begin
	HAx4 : HA port map(line1(4), line2(4), out1(4), carry(5));
-- HA end
	HAx46 : HA port map(line1(46), line2(46), out1(46), carry(47));
	

-- output definition: we have to group together the carry, the results of the adders and the unchanged dots
--definition of out1 --> unchanged dots in column 0,1,2,3,44
	out1(3 downto 0) <= line1(3 downto 0);
	out1(47) <= line1(47);
	
--definition of out2 --> the carry vector and unchanged dot in column 0,1,2,3,4
	out2(3 downto 0) <= line2(3 downto 0);
	out2(4) <= line3(4);
	out2(45 downto 5) <= line4(45 downto 5);
	out2(46) <= line3(46);
	out2(47) <= line2(47);

--definition of out3 --> unchanged bits
	out3(0) <= '0';
	out3(1) <= '0';
	out3(2) <= line3(2);
	out3(3) <= line3(3);
	out3(4) <= line4(4);
	
	out3(47 downto 5) <= carry(47 downto 5);
	
END ARCHITECTURE;
