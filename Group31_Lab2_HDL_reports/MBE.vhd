library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;


library std;
use std.textio.all;

entity MBE is
  port (
	a : in std_logic_vector(31 downto 0);
	b: in std_logic_vector(31 downto 0);
	DATAout : out std_logic_vector(63 downto 0)
    ); 
end MBE;

architecture beh of MBE is

component level5 IS
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
END component;

COMPONENT level4 IS
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
END COMPONENT;

COMPONENT level3 IS
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
END COMPONENT level3;

COMPONENT level2 IS
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
END COMPONENT level2;

COMPONENT level1 IS
PORT(
-- lines at input
	line1: in  std_logic_vector(47 downto 0);
	line2: in  std_logic_vector(47 downto 0);
	line3: in  std_logic_vector(47 downto 0);
-- output lines where for the first time length is 49
	out1: out  std_logic_vector(48 downto 0);
	out2: out  std_logic_vector(48 downto 0)

);
END COMPONENT level1;

component RCA is 

  port (
    i_add_term1  : in std_logic_vector(47 downto 0);
    i_add_term2  : in std_logic_vector(47 downto 0);
    
    o_result   : out std_logic_vector(48 downto 0)
    );
end component; 


	type p_array is array (0 to 12) of std_logic_vector(47 downto 0);
	-- 13 p signals
	signal p : p_array;

	type q_array is array (0 to 12) of std_logic_vector(24 downto 0);
	-- q signals output of muxes
	signal q : q_array;
	-- S vector
	signal S : std_logic_vector(11 downto 0);

	signal b_vector1 : std_logic_vector(24 downto 0);
	signal b_vector3 : std_logic_vector(24 downto 0);
	signal b_vector5 : std_logic_vector(24 downto 0);
	signal b_vector7 : std_logic_vector(24 downto 0);
	signal b_vector9 : std_logic_vector(24 downto 0);
	signal b_vector11 : std_logic_vector(24 downto 0);
	signal b_vector13 : std_logic_vector(24 downto 0);
	signal b_vector15 : std_logic_vector(24 downto 0);
	signal b_vector17 : std_logic_vector(24 downto 0);
	signal b_vector19 : std_logic_vector(24 downto 0);
	signal b_vector21 : std_logic_vector(24 downto 0);
	signal b_vector23 : std_logic_vector(24 downto 0);






-- interlevel signals
-- out signals
	signal output1 : std_logic_vector(48 downto 0);
	signal output2 : std_logic_vector(48 downto 0);
--level 1 in
	signal out2in11 : std_logic_vector(47 downto 0);
	signal out2in12 : std_logic_vector(47 downto 0);
	signal out2in13 : std_logic_vector(47 downto 0);
--level 2 in
signal out3in21 : std_logic_vector(47 downto 0);
signal out3in22 : std_logic_vector(47 downto 0);
signal out3in23 : std_logic_vector(47 downto 0);
signal out3in24 : std_logic_vector(47 downto 0);
--level 3 in
signal out4in31 : std_logic_vector(47 downto 0);
signal out4in32 : std_logic_vector(47 downto 0);
signal out4in33 : std_logic_vector(47 downto 0);
signal out4in34 : std_logic_vector(47 downto 0);
signal out4in35 : std_logic_vector(47 downto 0);
signal out4in36 : std_logic_vector(47 downto 0);
--level 4 in
signal out5in41 : std_logic_vector(47 downto 0);
signal out5in42 : std_logic_vector(47 downto 0);
signal out5in43 : std_logic_vector(47 downto 0);
signal out5in44 : std_logic_vector(47 downto 0);
signal out5in45 : std_logic_vector(47 downto 0);
signal out5in46 : std_logic_vector(47 downto 0);
signal out5in47 : std_logic_vector(47 downto 0);
signal out5in48 : std_logic_vector(47 downto 0);
signal out5in49 : std_logic_vector(47 downto 0);

-- sum signal
signal sum : std_logic_vector(48 downto 0);
begin
	
	-- b_vector definition
	b_vector1 <= (others => b(1));
	b_vector3 <= (others => b(3));
	b_vector5 <= (others => b(5));
	b_vector7 <= (others => b(7));
	b_vector9 <= (others => b(9));
	b_vector11 <= (others => b(11));
	b_vector13 <= (others => b(13));
	b_vector15 <= (others => b(15));
	b_vector17 <= (others => b(17));
	b_vector19 <= (others => b(19));
	b_vector21 <= (others => b(21));
	b_vector23 <= (others => b(23));



	--triplet evaluation
	process(a,b) -- muxs
		begin
		 --first triplet
		if( (not(b(0) xor '0') and (not(b(1) xor b(0)))) = '1') then
			q(0) <= (others => '0');
		elsif((b(0) xor '0') = '1') then
			q(0)(23 downto 0) <= a(23 downto 0);
			q(0)(24) <= '0';
		elsif((not(b(0) xor '0') and (b(1) xor b(0))) = '1') then
			q(0)(24 downto 1) <= a(23 downto 0);
			q(0)(0) <= '0';
		end if;
		S(0) <= b(1);
	
		-- other triplets
		for k in 1 to 11 loop
			if((not(b(2*k) xor b(2*k -1)) and (not(b(2*k +1) xor b(2*k)))) = '1') then
				q(k) <= (others => '0');
			elsif((b(2*k) xor b(2*k -1)) = '1') then
				q(k)(23 downto 0) <= a(23 downto 0);
				q(k)(24) <= '0';
			elsif((not(b(2*k) xor b(2*k -1)) and (b(2*k +1) xor b(2*k))) = '1') then
				q(k)(24 downto 1) <= a(23 downto 0);
				q(k)(0) <= '0';
			end if;
		S(k) <= b(2*k +1);

		end loop;
		-- last triplet
		if((not('0' xor b(23)) and (not('0' xor '0'))) = '1') then
			q(12) <= (others => '0');
		elsif(('0' xor b(23)) = '1') then
			q(12)(23 downto 0) <= a(23 downto 0);
			q(12)(24) <= '0';
		elsif((not('0' xor b(23)) and ('0' xor '0')) = '1') then
			q(12)(24 downto 1) <= a(23 downto 0);
			q(12)(0) <= '0';
		end if;

	end process;
	


-- p elaboration

	process(a,b,q,S)
		begin


		p(0)(24 downto 0) <= (b_vector1 xor q(0));
		p(0)(25) <= S(0);
		p(0)(26) <= S(0);
		p(0)(27) <= not S(0);
		p(0)(47 downto 28) <= ( others => '0');

		p(1)(0) <= S(0);
		p(1)(1) <= '0';
		p(1)(26 downto 2) <= (b_vector3 xor q(1));
		p(1)(27) <= not S(1);
		p(1)(28) <= '1';
		p(1)(47 downto 29) <= ( others => '0');

		
		p(2)(1 downto 0) <= ( others => '0');
		p(2)(2) <= S(1);
		p(2)(3) <= '0';
		p(2)(28 downto 4) <= (b_vector5 xor q(2));
		p(2)(29) <= not S(2);
		p(2)(30) <= '1';
		p(2)(47 downto 31) <= ( others => '0');

		p(3)(3 downto 0) <= ( others => '0');
		p(3)(4) <= S(2);
		p(3)(5) <= '0';
		p(3)(30 downto 6) <= (b_vector7 xor q(3));
		p(3)(31) <= not S(3);
		p(3)(32) <= '1';
		p(3)(47 downto 33) <= ( others => '0');


		p(4)(5 downto 0) <= ( others => '0');
		p(4)(6) <= S(3);
		p(4)(7) <= '0';
		p(4)(32 downto 8) <= (b_vector9 xor q(4));
		p(4)(33) <= not S(4);
		p(4)(34) <= '1';
		p(4)(47 downto 35) <= ( others => '0');


		p(5)(7 downto 0) <= ( others => '0');
		p(5)(8) <= S(4);
		p(5)(9) <= '0';
		p(5)(34 downto 10) <= (b_vector11 xor q(5));
		p(5)(35) <= not S(5);
		p(5)(36) <= '1';
		p(5)(47 downto 37) <= ( others => '0');


		p(6)(9 downto 0) <= ( others => '0');
		p(6)(10) <= S(5);
		p(6)(11) <= '0';
		p(6)(36 downto 12) <= (b_vector13 xor q(6));
		p(6)(37) <= not S(6);
		p(6)(38) <= '1';
		p(6)(47 downto 39) <= ( others => '0');


		p(7)(11 downto 0) <= ( others => '0');
		p(7)(12) <= S(6);
		p(7)(13) <= '0';
		p(7)(38 downto 14) <= (b_vector15 xor q(7));
		p(7)(39) <= not S(7);
		p(7)(40) <= '1';
		p(7)(47 downto 41) <= ( others => '0');


		p(8)(13 downto 0) <= ( others => '0');
		p(8)(14) <= S(7);
		p(8)(15) <= '0';
		p(8)(40 downto 16) <= (b_vector17 xor q(8));
		p(8)(41) <= not S(8);
		p(8)(42) <= '1';
		p(8)(47 downto 43) <= ( others => '0');


		p(9)(15 downto 0) <= ( others => '0');
		p(9)(16) <= S(8);
		p(9)(17) <= '0';
		p(9)(42 downto 18) <= (b_vector19 xor q(9));
		p(9)(43) <= not S(9);
		p(9)(44) <= '1';
		p(9)(47 downto 45) <= ( others => '0');


		p(10)(17 downto 0) <= ( others => '0');
		p(10)(18) <= S(9);
		p(10)(19) <= '0';
		p(10)(44 downto 20) <= (b_vector21 xor q(10));
		p(10)(45) <= not S(10);
		p(10)(46) <= '1';
		p(10)(47) <= '0';


		-- second last p
		p(11)(19 downto 0) <= ( others => '0');
		p(11)(20) <= S(10);
		p(11)(21) <= '0';
		p(11)(46 downto 22) <= (b_vector23 xor q(11));
		p(11)(47) <= not S(11);
		

		-- last p
		p(12)(21 downto 0) <= ( others => '0');
		p(12)(22) <= S(11);
		p(12)(23) <= '0';
		p(12)(47 downto 24) <= q(12)(23 downto 0);
	end process;









-- DADDA TREE
l1 : level1 PORT MAP(out2in11, out2in12, out2in13, output1, output2);
l2 : level2 PORT MAP(out3in21,out3in22,out3in23,out3in24, out2in11, out2in12, out2in13);
l3 : level3 PORT MAP(out4in31,out4in32,out4in33,out4in34,out4in35,out4in36, out3in21,out3in22,out3in23,out3in24);
l4 : level4 PORT MAP(out5in41,out5in42,out5in43,out5in44,out5in45,out5in46, out5in47,out5in48,out5in49, out4in31,out4in32,out4in33,out4in34,out4in35,out4in36);
l5 : level5 PORT MAP(p(0),p(1),p(2),p(3),p(4),p(5),p(6),p(7),p(8),p(9),p(10),p(11),p(12), out5in41,out5in42,out5in43,out5in44,out5in45,out5in46, out5in47,out5in48,out5in49);
adder : RCA PORT MAP(output1(47 downto 0), output2(47 downto 0), sum);

DATAout(47 downto 0) <= sum(47 downto 0);
DATAout(63 downto 48) <= ( others => '0');

	
end beh;
