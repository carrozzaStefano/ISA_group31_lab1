LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity riscv_lite is
	generic  (
		inst_size : integer := 32;
		Numbit	  : integer := 64;
		AddressMem : integer := 6
	);

	port (
	
	clk:in std_logic;
	rst:in std_logic;

	IR: in std_logic_vector(inst_size-1 downto 0); --input of the program counter coming from the testbench
	DMEM_IN: in std_logic_vector(Numbit-1 downto 0); --comes from the data memory in the testbench
	PC: out std_logic_vector(Numbit-1 downto 0);  -- goes to the instruction memory in the testbench
	DMEM_OUT: out std_logic_vector(Numbit-1 downto 0); -- goes to the data memory in the testbench
	DMEM_ADDR: out std_logic_vector( AddressMem-1 downto 0); -- goes to the data memory address in the testbench
	wrt_mem: out std_logic;  --write signal for memory 
	rd_mem: out std_logic);  --read signal for memory
	
end entity;

architecture absolute of riscv_lite is

component data_path is 

	generic  (
		inst_size : integer := 32;
		Numbit	  : integer := 64;
		AddressMem : integer := 6
	);
	
	port (
	
	CLK	: in std_logic;
	RST : in std_logic;
	
	stage_0 : in std_logic;
	IR		 : in std_logic_vector(inst_size-1 downto 0);
	
	stage_1 : in std_logic;
	reg_file1: in std_logic;
	reg_file2: in std_logic;
	ctrl_imm : in std_logic_vector(2 downto 0);
	
	stage_2 : in std_logic;
	ALU_src	 : in std_logic;
	is_PC_used : in std_logic;
	sum_sub_sel, and_xor_sel, shift_sel, LUI_sel, SLT_sel : in std_logic;
	absolute_sel: in std_logic;
	Sumn_Sub	: in std_logic;
	andin_xor	: in std_logic;

	
	stage_3 : in std_logic;
	ctrl_branch : in std_logic;
	jump_control : in std_logic;	--ADDED TO SEE IF JAL INSTR
	wrt_mem	: in std_logic;
	rd_mem	: in std_logic;
	
	stage_4 : in std_logic;
	WB_mux  : in std_logic;
	WB      : in std_logic;
	
	DMEM_IN : in std_logic_vector ( Numbit-1 downto 0);
	DMEM_OUT: out std_logic_vector( Numbit-1 downto 0);
	DMEM_ADDR: out std_logic_vector ( AddressMem-1 downto 0);
	
	flush : out std_logic;
	PC_out :out std_logic_vector(Numbit-1 downto 0);
	IR_out :out std_logic_vector(inst_size-1 downto 0) 
	
	
	
	);
end component;

component CONTROL_UNIT is
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
    
end component;

component FF
	port (
    CLK  : in  std_logic;
	RST  : in  std_logic;
	EN   : in  std_logic;
    DATA_IN : in std_logic;
	DATA_OUT : out std_logic);
	
end component;



signal	op_code_i 	:  std_logic_vector(6 downto 0); 
signal	func3_i		:  std_logic_vector(2 downto 0); 

signal	stage_0_i : std_logic;
	
signal	stage_1_i : std_logic;
signal	reg_file1_i:  std_logic;
signal	reg_file2_i:  std_logic;
signal 	ctrl_imm_i : std_logic_vector(2 downto 0);
	
signal	stage_2_i :  std_logic;
signal	ALU_src_i :  std_logic;
signal	is_PC_used_i :  std_logic;
signal	Sumn_Sub_i,andin_xor_i,sum_sub_sel_i, and_xor_sel_i, shift_sel_i, LUI_sel_i, SLT_sel_i :  std_logic;
signal absolute_sel_i : std_logic;
	
signal	stage_3_i :  std_logic;
signal	ctrl_branch_i :  std_logic;
signal	jump_control_i :  std_logic;	

	
signal	stage_4_i :  std_logic;
signal	WB_mux_i  :  std_logic;
signal	WB_i      :  std_logic;
signal	wrt_mem_i,wrt_mem_EX,wrt_mem_MEM :  std_logic;
signal  rd_mem_i,rd_mem_EX,rd_mem_MEM  :  std_logic;
signal 	ir_out_ex :  std_logic_vector(4 downto 0);

signal  ir_signal :  std_logic_vector(31 downto 0);

	
begin

CU : CONTROL_UNIT 

port map(


	op_code 	=> op_code_i,	
	func3		=> func3_i,
	
	

	immediate_case_selection	=> ctrl_imm_i,
	

	sum_sub_sel => sum_sub_sel_i ,
	and_xor_sel => and_xor_sel_i,
	shift_sel   => shift_sel_i,
	LUI_sel		=> LUI_sel_i,
	SLT_sel		=> SLT_sel_i,
	absolute_sel=> absolute_sel_i,
	Sumn_Sub 	=> Sumn_Sub_i,
	andin_xor	=> andin_xor_i,
	

	is_branch	=> ctrl_branch_i,
	

	jump_control => jump_control_i,
	

	ALUsrc	=> ALU_src_i,
	

	stage_0 => stage_0_i,
	stage_1 => stage_1_i,
	stage_2 => stage_2_i,
	stage_3 => stage_3_i,
	stage_4 => stage_4_i,
	WB      => WB_i,
	WB_mux  => WB_mux_i,
	read_reg1 => reg_file1_i,
	read_reg2 => reg_file2_i,
	
	is_PC_used => is_PC_used_i,
	wrt_mem	   => wrt_mem_i,
	rd_mem 	   => rd_mem_i
	);
	
DataPath : data_path

port map(

	CLK	=> CLK,
	RST => RST,
	
	stage_0 => stage_0_i,
	IR		=> IR,
	
	stage_1 => stage_1_i,
	reg_file1 => reg_file1_i,
	reg_file2 => reg_file2_i,
	ctrl_imm  => ctrl_imm_i,
	
	stage_2  => stage_2_i,
	ALU_src	 => ALU_src_i,
	is_PC_used => is_PC_used_i,
	sum_sub_sel => sum_sub_sel_i,
	and_xor_sel => and_xor_sel_i,
	shift_sel	=> shift_sel_i,
	LUI_sel		=> LUI_sel_i,
	SLT_sel		=> SLT_sel_i,
	absolute_sel=> absolute_sel_i,
	Sumn_Sub	=> Sumn_Sub_i,
	andin_xor	=> andin_xor_i,

	
	stage_3 	=> stage_3_i,
	ctrl_branch => ctrl_branch_i,
	jump_control => jump_control_i,
	wrt_mem		=>  wrt_mem_i,
	rd_mem		=>  rd_mem_i,
	
	stage_4 	=> stage_4_i,
	WB_mux  	=> WB_mux_i,
	WB      	=> WB_i,
	
	DMEM_IN 	=>DMEM_IN,
	DMEM_OUT	=> DMEM_OUT,
	DMEM_ADDR 	=> DMEM_ADDR,
	PC_out =>	PC,
	IR_out => ir_signal
	
);
	op_code_i <= ir_signal(6 downto 0);
	ir_out_ex <= ir_signal(11 downto 7);
	func3_i <= ir_signal(14 downto 12);

ID_EX_WR :
	FF port map(CLK, '0', '1', wrt_mem_i, wrt_mem_EX);
EX_MEM_WR :
	FF port map(CLK, '0', '1', wrt_mem_EX, wrt_mem_MEM);

ID_EX_RD :
	FF port map(CLK, '0', '1', rd_mem_i, rd_mem_EX);
EX_MEM_RD :
	FF port map(CLK, '0', '1', rd_mem_EX, rd_mem_MEM);
wrt_mem <= wrt_mem_MEM;
rd_mem	<= rd_mem_MEM;
end architecture;
	


