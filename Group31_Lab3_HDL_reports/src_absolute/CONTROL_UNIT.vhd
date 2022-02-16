LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity CONTROL_UNIT is
  port(
	op_code 	: in std_logic_vector(6 downto 0); --opcode from the instruction, is the the 6 LSBs of the instruction
	
	--additional code used in the R and I instruction to find the case
	-- in the scheme this is used in ALU control but we do all the selections together
	-- MAYBE IN PIPELINE THIS SHOULD BE CHANGED
	func3		: in std_logic_vector(2 downto 0); 
	
	
	-- outputs are all the control signals:
	-- signal to be sent to immediate calculation
	-- should be 000,001,010,011,100; 111 for non immediate
	immediate_case_selection	: out std_logic_vector(2 downto 0);
	
	-- these are signals to be sent to the ALU and differs depending on the operation to be done
	-- these are used for ALU control, the latter are used to define if sub/add and and/xor
	sum_sub_sel, and_xor_sel, shift_sel, LUI_sel, SLT_sel : out std_logic;
	absolute_sel: out std_logic;
	Sumn_Sub, andin_xor : out std_logic;
	
	--other control signals not used to define the ALU operation:
	-- signal to see if branch and modify the MUX select on the next PC address
	-- should be ANDed with is zero and sent to PC selector
	is_branch	: out std_logic;
	
	-- signal to see if jump without any condition
	jump_control : out std_logic;
	
	-- signal sent to the mux on the input of the ALU
	-- it choses if use immediate or second source register 
	-- as a input of ALU
	-- connected to MUX_ALU (second input)
	ALUsrc		: out std_logic;
	
	-- stage signals, to be clear if we want to stall the pipe
	stage_0 : out std_logic;
	stage_1 : out std_logic;
	stage_2 : out std_logic;
	stage_3 : out std_logic;
	stage_4 : out std_logic;
	
	-- NOP in case of branch we use the is_branched signal
	-- WB signals
	
	WB : out std_logic;
	WB_mux : out std_logic;
	
	--reg file read control
	read_reg1 : out std_logic;
	read_reg2 : out std_logic;
	
	-- signal used to see if we have to use the PC in the ALU
	is_PC_used : out std_logic;
	wrt_mem	   : out std_logic;
	rd_mem 	   : out std_logic
	
	);
    
end CONTROL_UNIT;
architecture beh of CONTROL_UNIT is
begin
	
	process(op_code, func3) --process to find in which instruction we are
	begin
		-- default values for the signals
		-- ALU control
		sum_sub_sel <= '0';
		and_xor_sel <= '0';
		shift_sel <= '0';
		LUI_sel <= '0';
		SLT_sel <= '0';
		Sumn_Sub <= '0';
		andin_xor <= '0';
		wrt_mem	 <= '0';
		rd_mem 	  <= '0';
		absolute_sel <= '0';
		
		--stage signals
		stage_0 <= '1'; --set to enabled
		stage_1 <= '1';
		stage_2 <= '1';
		stage_3 <= '1';
		stage_4 <= '1';
		
		-- is_branch to see if branch case
		is_branch <= '0';
		-- jump allways when JAL, to be ORed with is_zero of ALU
		jump_control <= '0';
		
		-- WB default signals, by default we don't write
		WB <= '0';
		WB_mux <= '0';
		
		--read reg control
		read_reg1 <= '0';
		read_reg2 <= '0';
		
		--PC used in ALU
		is_PC_used <= '0';
		ALUsrc <= '0';
		
		--immediate selection
		immediate_case_selection <= "111";
		
		case op_code is
		when "1111111" => -- New absolute instruction case
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '0';
			absolute_sel <= '1';

		when "0110011" => -- R case
			if func3 = "000" then -- ADD case
			sum_sub_sel <= '1';
			Sumn_Sub <= '0';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			read_reg2 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '0';
			
			elsif func3 = "100" then -- XOR case
			and_xor_sel <= '1';
			andin_xor <= '1';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			read_reg2 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '0';
			
			elsif func3 = "010" then -- SLT case
			SLT_sel <= '1';
			Sumn_Sub <= '1';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			read_reg2 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '0';
			ALUsrc	 <= '0';
			
			else
				--error, use default values
			end if;
		
		when "0010011" => -- I case
			immediate_case_selection <= "000"; -- I case
			
			if func3 = "000" then -- ADDI case
			sum_sub_sel <= '1';
			Sumn_Sub <= '0';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '1';
			
			elsif func3 = "111" then -- ANDI case
			and_xor_sel <= '1';
			andin_xor <= '0';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '1';
			
			elsif func3 = "101" then -- SRAI case
			shift_sel <= '1';
			WB <= '1';
			WB_mux <= '1';
			read_reg1 <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '1';
			
			else
				--error, use default values
			end if;
		
		when "0010111" => -- AUIPC case
			immediate_case_selection <= "101"; --U instr
			sum_sub_sel <= '1';
			Sumn_Sub <= '0';
			WB <= '1';
			WB_mux <= '1';
			is_PC_used <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '1';
				
		when "0110111" => -- LUI case
			immediate_case_selection <= "101"; --U instr
			LUI_sel <= '1';
			WB <= '1';
			WB_mux <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '1';
		
		when "1100011" => -- BEQ case
			immediate_case_selection <= "010"; -- B case
			-- the ALU looks if the operands are equal,
			-- the actual address calculation is done in the 64b adder
			Sumn_Sub <= '1';
			is_branch <= '1';
			-- the PC should not update!
			stage_0 <= '0';
			WB <= '0';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			read_reg1	 <= '1';
			read_reg2	 <= '1';
			ALUsrc	 <= '0';
			
		
		when "0000011" => -- LW case
			immediate_case_selection <= "000"; -- I case
			sum_sub_sel <= '1';
			Sumn_Sub <= '0';
			WB <= '1';
			WB_mux <= '0'; --this time we use the memory
			read_reg1 <= '1';
			read_reg2 <= '1';
			rd_mem	<= '1';
			wrt_mem	 <= '0';
			ALUsrc	 <= '1';		
		when "1101111" => -- JAL case
			immediate_case_selection <= "100"; -- J case
			
			is_branch <= '1';
			jump_control <= '1';
			-- the PC should not update!
			stage_0 <= '0';
			WB <= '1';
			WB_mux <= '1';
			is_PC_used <= '1';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '0';

		when "0100011" => -- SW case
			immediate_case_selection <= "001"; -- S case
			sum_sub_sel <= '1';
			Sumn_Sub <= '0';
			WB <= '0';
			read_reg1 <= '1';
			read_reg2 <= '1';
			wrt_mem		<='1';
			rd_mem 	  <= '0';
			ALUsrc	 <= '1';

		when others => --we have an error or a NOP case therefore we do an addition I
		-- if it is a NOP driven by a signal then the destination register should be x0
		immediate_case_selection <= "000";
		sum_sub_sel <= '1';
		Sumn_Sub <= '0';
		read_reg1 <= '1';
		-- also the PC should not update because it's an internal nop
		stage_0 <= '0';
			wrt_mem	 <= '0';
			rd_mem 	  <= '1';
			ALUsrc	 <= '0';
	end case;
end process;
	

	


end architecture;
