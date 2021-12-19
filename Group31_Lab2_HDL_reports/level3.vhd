LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


--REDO LEVEL 3!!

ENTITY level3 IS
PORT(
-- lines at input
	line1: in  std_logic_vector(47 downto 0);
	line2: in  std_logic_vector(47 downto 0);
	line3: in  std_logic_vector(47 downto 0);
	line4: in  std_logic_vector(47 downto 0);
	line5: in  std_logic_vector(47 downto 0);
	line6: in  std_logic_vector(47 downto 0);
-- output lines 
	out1: out  std_logic_vector(47 downto 0);
	out2: out  std_logic_vector(47 downto 0);
	out3: out  std_logic_vector(47 downto 0);
	out4: out  std_logic_vector(47 downto 0)

);
END ENTITY level3;

ARCHITECTURE beh OF level3 IS

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
-- on this level we need 2
	signal carry1 : std_logic_vector(47 downto 0);
	signal carry2 : std_logic_vector(47 downto 0);
	
BEGIN

-- generate of FA 
	FA_GEN_FIRST:
	for i in 7 to 43 generate
	FAx : FA port map(line1(i), line2(i), line3(i), out1(i), carry1(i+1));
	end generate;
	FA_GEN_SECOND:
	for i in 9 to 41 generate
	FAx : FA port map(line4(i), line5(i), line6(i), out2(i), carry2(i+1));
	end generate;
	
-- generate of HA begin
	HAx6 : HA port map(line1(6), line2(6), out1(6), carry1(7));
	HAx8 : HA port map(line4(8), line5(8), out2(8), carry2(9));	
-- HA end
	HAx42 : HA port map(line4(42), line5(42), out2(42), carry2(43));
	HAx44 : HA port map(line1(44), line2(44), out1(44), carry1(45));
	

-- output definition: we have to group together the carry, the results of the adders and the unchanged dots
--definition of out1 --> 6->44 ok;
--unchanged dots in column 
	out1(5 downto 0) <= line1(5 downto 0);
	out1(47 downto 45) <= line1(47 downto 45);
	
--definition of out2 8->42 ok
--unchanged dot in column 
	out2(5 downto 0) <= line2(5 downto 0);
	out2(6) <= line3(6);
	out2(7) <= line4(7);
	out2(43) <= line4(43);
	out2(44) <= line3(44);
	out2(47 downto 45) <= line2(47 downto 45);


--definition of out3 --> unchanged dots begin
	out3(0) <= '0';
	out3(1) <= '0';
	out3(5 downto 2) <= line3(5 downto 2);
	out3(6) <= line4(6);
	out3(7) <= line5(7);
	out3(8) <= line6(8);
-- carry2 vector
	out3(43 downto 9) <= carry2(43 downto 9);
-- unchanged dots end
	out3(44) <= line4(44);
	out3(45) <= line3(45);
	out3(46) <= line3(46);
	out3(47) <= '0';
	
--definition of out4 --> unchanged dots begin
	out4(3 downto 0) <= (others => '0');
	out4(5 downto 4) <= line4(5 downto 4);
	out4(6) <= line5(6);
-- carry1 vector
	out4(45 downto 7) <= carry1(45 downto 7);
-- unchanged dots end
	out4(47 downto 46) <= (others => '0');
	
END ARCHITECTURE;
