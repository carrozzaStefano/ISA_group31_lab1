LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY level4 IS
PORT(
-- lines at input
	line1: in  std_logic_vector(47 downto 0);
	line2: in  std_logic_vector(47 downto 0);
	line3: in  std_logic_vector(47 downto 0);
	line4: in  std_logic_vector(47 downto 0);
	line5: in  std_logic_vector(47 downto 0);
	line6: in  std_logic_vector(47 downto 0);
	line7: in  std_logic_vector(47 downto 0);
	line8: in  std_logic_vector(47 downto 0);
	line9: in  std_logic_vector(47 downto 0);	
-- output lines 
	out1: out  std_logic_vector(47 downto 0);
	out2: out  std_logic_vector(47 downto 0);
	out3: out  std_logic_vector(47 downto 0);
	out4: out  std_logic_vector(47 downto 0);
	out5: out  std_logic_vector(47 downto 0);
	out6: out  std_logic_vector(47 downto 0)

);
END ENTITY level4;

ARCHITECTURE beh OF level4 IS

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
-- on this level we need 3
	signal carry1 : std_logic_vector(47 downto 0);
	signal carry2 : std_logic_vector(47 downto 0);
	signal carry3 : std_logic_vector(47 downto 0);
	
BEGIN

-- generate of FA 
	FA_GEN_FIRST:
	for i in 11 to 39 generate
	FAx : FA port map(line1(i), line2(i), line3(i), out1(i), carry1(i+1));
	end generate;
	FA_GEN_SECOND:
	for i in 13 to 37 generate
	FAx : FA port map(line4(i), line5(i), line6(i), out2(i), carry2(i+1));
	end generate;
	FA_GEN_THIRD:
	for i in 15 to 35 generate
	FAx : FA port map(line7(i), line8(i), line9(i), out3(i), carry3(i+1));
	end generate;
	
-- generate of HA begin
	HAx14 : HA port map(line7(14), line8(14), out3(14), carry3(15));
	HAx12 : HA port map(line4(12), line5(12), out2(12), carry2(13));
	HAx10 : HA port map(line1(10), line2(10), out1(10), carry1(11));
	
-- HA end
	HAx36 : HA port map(line7(36), line8(36), out3(36), carry3(37));
	HAx38 : HA port map(line4(38), line5(38), out2(38), carry2(39));
	HAx40 : HA port map(line1(40), line2(40), out1(40), carry1(41));
	

-- output definition: we have to group together the carry, the results of the adders and the unchanged dots
--definition of out1 --> 10->40 ok;
--unchanged dots in column 
	out1(9 downto 0) <= line1(9 downto 0);
	out1(47 downto 41) <= line1(47 downto 41);
	
--definition of out2 --> 12->37 ok;
--unchanged dot in column 0-->9
	out2(9 downto 0) <= line2(9 downto 0);
	out2(10) <= line3(10);
	out2(11) <= line4(11);	
-- last unchanged dot
	out2(39) <= line4(39);
	out2(40) <= line3(40);
	out2(47 downto 41) <= line2(47 downto 41);

--definition of out3 --> 14->35 ok
-- unchanged dots begin
	out3(0) <= '0';
	out3(1) <= '0';
	out3(9 downto 2) <= line3(9 downto 2);
	out3(10) <= line4(10);
	out3(11) <= line5(11);
	out3(12) <= line6(12);
	out3(13) <= line7(13);
-- unchanged dots end
	out3(37) <= line7(37);
	out3(38) <= line6(38);
	out3(39) <= line5(39);
	out3(40) <= line4(40);
	out3(46 downto 41) <= line3(46 downto 41);
	out3(47) <= '0';
	
--definition of out4 --> unchanged dots begin
	out4(3 downto 0) <= (others => '0');
	out4(9 downto 4) <= line4(9 downto 4);
	out4(10) <= line5(10);
	out4(11) <= line6(11);
	out4(12) <= line7(12);
	out4(13) <= line8(13);
	out4(14) <= line9(14);	
-- carry3 vector
	out4(37 downto 15) <= carry3(37 downto 15);
-- unchanged dots end
	out4(38) <= line7(38);
	out4(39) <= line6(39);
	out4(40) <= line5(40);
	out4(44 downto 41) <= line4(44 downto 41);
	out4(47 downto 45) <= (others => '0');
	
--definition of out5 --> unchanged dots begin
	out5(5 downto 0) <= (others => '0');
	out5(9 downto 6) <= line5(9 downto 6);
	out5(10) <= line6(10);
	out5(11) <= line7(11);
	out5(12) <= line8(12);		
-- carry2 vector
	out5(39 downto 13) <= carry2(39 downto 13);
-- unchanged dots end
	out5(40) <= line6(40);
	out5(42 downto 41) <= line5(42 downto 41);
	out5(47 downto 43) <= (others => '0');
	
--definition of out6 --> unchanged dots begin
	out6(7 downto 0) <= (others => '0');
	out6(9 downto 8) <= line6(9 downto 8);
	out6(10) <= line7(10);		
-- carry1 vector
	out6(41 downto 11) <= carry1(41 downto 11);
-- unchanged dots end
	out6(47 downto 42) <= (others => '0');
	
END ARCHITECTURE;
