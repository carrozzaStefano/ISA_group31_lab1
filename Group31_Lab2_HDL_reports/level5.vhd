LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY level5 IS
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
	line10: in  std_logic_vector(47 downto 0);
	line11: in  std_logic_vector(47 downto 0);
	line12: in  std_logic_vector(47 downto 0);
	line13: in  std_logic_vector(47 downto 0);	
-- output lines 
	out1: out  std_logic_vector(47 downto 0);
	out2: out  std_logic_vector(47 downto 0);
	out3: out  std_logic_vector(47 downto 0);
	out4: out  std_logic_vector(47 downto 0);
	out5: out  std_logic_vector(47 downto 0);
	out6: out  std_logic_vector(47 downto 0);
	out7: out  std_logic_vector(47 downto 0);
	out8: out  std_logic_vector(47 downto 0);
	out9: out  std_logic_vector(47 downto 0)

);
END ENTITY level5;

ARCHITECTURE beh OF level5 IS

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
-- on this level we need 4
	signal carry1 : std_logic_vector(47 downto 0);
	signal carry2 : std_logic_vector(47 downto 0);
	signal carry3 : std_logic_vector(47 downto 0);
	signal carry4 : std_logic_vector(47 downto 0);
	
BEGIN

-- generate of FA 
	FA_GEN_FIRST:
	for i in 17 to 27 generate
	FAx : FA port map(line1(i), line2(i), line3(i), out1(i), carry1(i+1));
	end generate;
	FA_GEN_SECOND:
	for i in 19 to 29 generate
	FAx : FA port map(line4(i), line5(i), line6(i), out2(i), carry2(i+1));
	end generate;
	FA_GEN_THIRD:
	for i in 21 to 31 generate
	FAx : FA port map(line7(i), line8(i), line9(i), out3(i), carry3(i+1));
	end generate;
	FA_GEN_FOURTH:
	for i in 23 to 33 generate
	FAx : FA port map(line10(i), line11(i), line12(i), out4(i), carry4(i+1));
	end generate;
	
-- generate of HA begin
	HAx22 : HA port map(line10(22), line11(22), out4(22), carry4(23));
	HAx20 : HA port map(line7(20), line8(20), out3(20), carry3(21));
	HAx18 : HA port map(line4(18), line5(18), out2(18), carry2(19));
	HAx16 : HA port map(line1(16), line2(16), out1(16), carry1(17));
	
-- HA end
	HAx34 : HA port map(line11(34), line12(34), out4(34), carry4(35));
	HAx32 : HA port map(line8(32), line9(32), out3(32), carry3(33));
	HAx30 : HA port map(line5(30), line6(30), out2(30), carry2(31));
	HAx28 : HA port map(line2(28), line3(28), out1(28), carry1(29));
	

-- output definition: we have to group together the carry, the results of the adders and the unchanged dots
--definition of out1
--unchanged dots in column 
	out1(15 downto 0) <= line1(15 downto 0);
	out1(30 downto 29) <= line3(30 downto 29);
	out1(32 downto 31) <= line4(32 downto 31);
	out1(34 downto 33) <= line5(34 downto 33);
	out1(36 downto 35) <= line6(36 downto 35);
	out1(38 downto 37) <= line7(38 downto 37);
	out1(40 downto 39) <= line8(40 downto 39);
	out1(42 downto 41) <= line9(42 downto 41);
	out1(44 downto 43) <= line10(44 downto 43);
	out1(46 downto 45) <= line11(46 downto 45);
	out1(47) <= line12(47); 
	
--definition of out2 
	out2(15 downto 0) <= line2(15 downto 0);
	out2(16) <= line3(16);
	out2(17) <= line4(17);
	out2(32 downto 31) <= line5(32 downto 31);
	out2(34 downto 33) <= line6(34 downto 33);
	out2(36 downto 35) <= line7(36 downto 35);
	out2(38 downto 37) <= line8(38 downto 37);
	out2(40 downto 39) <= line9(40 downto 39);
	out2(42 downto 41) <= line10(42 downto 41);
	out2(44 downto 43) <= line11(44 downto 43);
	out2(46 downto 45) <= line12(46 downto 45);
	out2(47) <= line13(47); 

--definition of out3 
	out3(1 downto 0) <= (others =>'0');
	out3(15 downto 2) <= line3(15 downto 2);
	out3(16) <= line4(16);
	out3(17) <= line5(17);
	out3(18) <= line6(18);
	out3(19) <= line7(19);
	out3(34 downto 33) <= line7(34 downto 33);
	out3(36 downto 35) <= line8(36 downto 35);
	out3(38 downto 37) <= line9(38 downto 37);
	out3(40 downto 39) <= line10(40 downto 39);
	out3(42 downto 41) <= line11(42 downto 41);
	out3(44 downto 43) <= line12(44 downto 43);
	out3(46 downto 45) <= line13(46 downto 45);
	out3(47) <= '0'; 
	
--definition of out4 
	out4(3 downto 0) <= (others =>'0');
	out4(15 downto 4) <= line4(15 downto 4);
	out4(16) <= line5(16);
	out4(17) <= line6(17);
	out4(18) <= line7(18);
	out4(19) <= line8(19);
	out4(20) <= line9(20);
	out4(21) <= line10(21);
	out4(36 downto 35) <= line9(36 downto 35);
	out4(38 downto 37) <= line10(38 downto 37);
	out4(40 downto 39) <= line11(40 downto 39);
	out4(42 downto 41) <= line12(42 downto 41);
	out4(44 downto 43) <= line13(44 downto 43);
	out4(47 downto 45) <= (others => '0');
	
	
--definition of out5 --> unchanged dots begin
	out5(5 downto 0) <= (others =>'0');
	out5(15 downto 6) <= line5(15 downto 6);
	out5(16) <= line6(16);
	out5(17) <= line7(17);
	out5(18) <= line8(18);
	out5(19) <= line9(19);
	out5(20) <= line10(20);
	out5(21) <= line11(21);
	out5(22) <= line12(22);
	out5(29 downto 23) <= line13(29 downto 23);
	out5(30) <= line4(30);
	out5(32 downto 31) <= line6(32 downto 31);
	out5(34 downto 33) <= line8(34 downto 33);
	out5(36 downto 35) <= line10(36 downto 35);
	out5(38 downto 37) <= line11(38 downto 37);
	out5(40 downto 39) <= line12(40 downto 39);
	out5(42 downto 41) <= line13(42 downto 41);
	out5(47 downto 43) <= (others => '0');
	
--definition of out6 --> unchanged dots begin
	out6(7 downto 0) <= (others =>'0');
	out6(15 downto 8) <= line6(15 downto 8);
	out6(16) <= line7(16);
	out6(17) <= line8(17);
	out6(18) <= line9(18);
	out6(19) <= line10(19);
	out6(20) <= line11(20);
	out6(21) <= line12(21);
	out6(22) <= line13(22);
-- carry4 vector
	out6(29 downto 23) <= carry1(29 downto 23);

	out6(31 downto 30) <= line13(31 downto 30);
	out6(32) <= line7(32);
	out6(34 downto 33) <= line9(34 downto 33);
	out6(36 downto 35) <= line11(36 downto 35);
	out6(38 downto 37) <= line12(38 downto 37);
	out6(40 downto 39) <= line13(40 downto 39);

	out6(47 downto 41) <= (others => '0');

--definition of out7 --> unchanged dots begin
	out7(9 downto 0) <= (others =>'0');
	out7(15 downto 10) <= line7(15 downto 10);
	out7(16) <= line8(16);
	out7(17) <= line9(17);
	out7(18) <= line10(18);
	out7(19) <= line11(19);
	out7(20) <= line12(20);
-- carry3 vector
	out7(33 downto 21) <= carry3(33 downto 21); 
	
	out7(34) <= line10(34);
	out7(36 downto 35) <= line12(36 downto 35);
	out7(38 downto 37) <= line13(38 downto 37);

	out7(47 downto 39) <= (others => '0');

--definition of out8 --> unchanged dots begin
	out8(11 downto 0) <= (others =>'0');
	out8(15 downto 12) <= line8(15 downto 12);
	out8(16) <= line9(16);
	out8(17) <= line10(17);
	out8(18) <= line11(18);
-- carry vector
	out8(31 downto 19) <= carry2(31 downto 19); 

	out8(36 downto 32) <= line13(36 downto 32);	

	out8(47 downto 37) <= (others => '0');
	
--definition of out9 --> unchanged dots begin
	out9(13 downto 0) <= (others =>'0');
	out9(15 downto 14) <= line9(15 downto 14);
	out9(16) <= line10(16);
-- carry vector
	out9(35 downto 23) <= carry4	(35 downto 23); 
    out9(22 downto 17) <= carry1    (22 downto 17);

	out9(47 downto 36) <= (others => '0');
	
END ARCHITECTURE;
