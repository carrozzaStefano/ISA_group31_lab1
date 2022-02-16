library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity data_path is 

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
	
end entity data_path;

Architecture strc of data_path is

-- signals:

signal CRNT_PC:				std_logic_vector(Numbit-1 downto 0);  		-- Current Program Counter -> Instruction Memory
signal NXT_PC:				std_logic_vector(Numbit-1 downto 0);  		-- Next Program Counter    -> Proguram Counter Register
signal CRNT_4_PC:			std_logic_vector(Numbit-1 downto 0);  		-- Current Program counter +4 out of the adder
signal ID_IR:				std_logic_vector(inst_size-1 downto 0); 	-- Instruction Register signal coming out from the IF/ID stage register
signal ID_PC:				std_logic_vector(Numbit-1 downto 0);		-- Program Counter signal coming out from the IF/ID stage register
signal ID_RS_1:				std_logic_vector(Numbit-1 downto 0);		-- Source register 1 out from the register file
signal ID_RS_2:				std_logic_vector(Numbit-1 downto 0);		-- Source register 2 out from the register file
signal ID_IMM:				std_logic_vector(Numbit-1 downto 0);		-- sign extention by immediate generator
signal EX_MEM_RD_IR:		std_logic_vector(4 downto 0);		-- Destination address register signal from the ID/EX stage register
signal EX_PC:				std_logic_vector(Numbit-1 downto 0);		-- Program Counter signal coming out from the ID/EX stage register
signal EX_RS_1_selected:	std_logic_vector(Numbit-1 downto 0);
signal EX_RS_1:				std_logic_vector(Numbit-1 downto 0);		-- Source register 1 signal out from the ID/EX stage register
signal EX_RS_2:				std_logic_vector(Numbit-1 downto 0);		-- Source register 2 signal out from the ID/EX stage register
signal EX_IMM:				std_logic_vector(Numbit-1 downto 0);		-- sign extention signal out from the ID/EX stage register
signal EX_OP2_ALU:			std_logic_vector(Numbit-1 downto 0);		-- Second operand into the ALU from MUX
signal EX_BRANCH_PC:		std_logic_vector(Numbit-1 downto 0);		-- Program counter coming out from the 64 adder for branch
signal EX_ALU_RES:			std_logic_vector(Numbit-1 downto 0);		-- ALU result produced in ID/EX stage
signal EX_ALU_ZERO:			std_logic;				-- Zero check for the ALU result
signal MEM_RD_IR:			std_logic_vector(4 downto 0);		-- Destination address register signal out of the EX/MEM stage
signal MEM_BRANCH_PC:		std_logic_vector(Numbit-1 downto 0);		-- Program counter coming out from the EX/MEM stage register
signal MEM_ALU_ZERO:		std_logic;									-- Zero check signal out of the EX/MEM stage register
signal MEM_SRC_PC:			std_logic;									-- Program Counter mux controller
signal MEM_ALU_RES:			std_logic_vector(Numbit-1 downto 0);		-- ALU result signal coming from EX/MEM stage register
signal MEM_RS_2:			std_logic_vector(Numbit-1 downto 0);		-- Source register 2 signal out from the EX/MEM stage register  
signal WB_RD_IR:			std_logic_vector(4 downto 0);		-- Destination address register signal out of the MEM/WB stage 
signal WB_ALU_RES:			std_logic_vector(Numbit-1 downto 0);		-- ALU result signal coming from MEM/WB stage register
signal WB_DMEM_DATA:		std_logic_vector(Numbit-1 downto 0);		-- DMEM DATA coming from the MEM/WB stage register
signal WB_IR_DATA:			std_logic_vector(Numbit-1 downto 0);		-- Destination DATA register signal out of the MEM/WB stage 
signal flsh:				std_logic;									-- flushing when branch
signal rst_i:				std_logic;									-- int reset signal
signal ir_i:				std_logic_vector(inst_size-1 downto 0);		-- int IR signal

signal sum_sub_sel_EX, and_xor_sel_EX, shift_sel_EX, LUI_sel_EX, SLT_sel_EX :  std_logic;	-- ALU signal pipelined to the EXE stage
signal Sumn_Sub_EX:  		std_logic;									-- ALU signal pipelined to the EXE stage
signal andin_xor_EX:  		std_logic;									-- ALU signal pipelined to the EXE stage

signal EX_ctrl_branch:		std_logic;									-- EXE part of branch control signal
signal MEM_ctrl_branch:		std_logic;									-- MEM part of branch control signal

signal EX_jump_control:		std_logic;									-- EXE part of the unconditional jump signal
signal MEM_jump_control:	std_logic;									-- MEM part of the unconditional jump signal

signal EX_mux:				std_logic;									-- ALU mux controller pipelined to EXE stage

signal IF_ID_reset:			std_logic;									-- reset the first register creating therefore a bubble in the pipeline

signal EX_WB:				std_logic;									-- WB signal pipe EXE
signal MEM_WB:				std_logic;									-- WB signal pipe MEM
signal WB_WB:				std_logic;									-- WB signal pipe WB

signal EX_WB_mux:			std_logic;									-- WBmux signal pipe EXE
signal MEM_WB_mux:			std_logic;									-- WBmux signal pipe MEM
signal WB_WB_mux:			std_logic;									-- WBmux signal pipe WB

signal EX_is_PC_used:		std_logic;									-- mux selector for PC in EXE stage
signal ORed_sig:			std_logic;
-- components:

component reg is
  generic (N : integer := 32);
  port (
    CLK  : in  std_logic;
	RST  : in  std_logic;
	EN   : in  std_logic;
    DATA_IN : in std_logic_vector(N-1 downto 0);
	DATA_OUT : out std_logic_vector(N-1 downto 0));
	
end component;

component mux_gen is
  generic (N : integer := 32);
  port (
    selector	: in std_logic;
    In1,In2		: in std_logic_vector(N-1 downto 0);
	DATA_OUT 	: out std_logic_vector(N-1 downto 0));
end component;

component register_file is 

	generic ( 
			data_size 	: integer := 64;
			addr_size	: integer := 5);
	
	port (
	
		clk : in std_logic;
		rst : in std_logic;
		en  : in std_logic;
		wrt : in std_logic;
		rd1 : in std_logic;
		rd2 : in std_logic;
		
		wrt_addr : in std_logic_vector ( addr_size-1 downto 0);
		rd1_addr : in std_logic_vector ( addr_size-1 downto 0);
		rd2_addr : in std_logic_vector ( addr_size-1 downto 0);
		
		data_in  : in std_logic_vector ( data_size-1 downto 0);
		
		data_out1: out std_logic_vector( data_size-1 downto 0);
		data_out2: out std_logic_vector( data_size-1 downto 0)
		);
		
end component;

component ALU is
  port (
    Input1,Input2: in std_logic_vector(63 downto 0);
	sum_sub_sel, and_xor_sel, shift_sel, LUI_sel, SLT_sel : in std_logic;
	Sumn_Sub	: in std_logic;
	andin_xor	: in std_logic;
	IsZero		: out std_logic;
	Output		: out std_logic_vector(63 downto 0));
end component;

component immediate_gen is
  port (
    Input			: in std_logic_vector(31 downto 0);
	-- signal that come from the CU and select in which case of immediate we are
	case_selection	: in std_logic_vector(2 downto 0);
	Output			: out std_logic_vector(63 downto 0));
end component;

component adder64bit is
  port (
    Input1,Input2		: in std_logic_vector(63 downto 0);
	Output				: out std_logic_vector(63 downto 0));
end component;

component adder4 is
  port (
    Input		: in std_logic_vector(63 downto 0);
	Output		: out std_logic_vector(63 downto 0));
end component;

--component andd
--  port(
--    a, b : in  std_logic;
--    y    : out std_logic);
--end component;

component FF is
  port (
    CLK  : in  std_logic;
	RST  : in  std_logic;
	EN   : in  std_logic;
    DATA_IN : in std_logic;
	DATA_OUT : out std_logic);
	
end component;


begin

	--
	rst_i  <= RST;
	ir_i 	  <= IR;
	-- Data memory connections
	DMEM_ADDR <= MEM_ALU_RES(AddressMem-1 downto 0);
	DMEM_OUT  <= MEM_RS_2;
	-- Instuction memory connection
	PC_out    <= CRNT_PC;
	--
	FLUSH <= flsh;
	IR_out<= ID_IR;


	--FLUSH : mux_gen
	--generic map (1)
	--port map ( rst_i,'0',MEM_SRC_PC,flsh);
	flsh <= rst_i;

	Program_Counter : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_0,NXT_PC,CRNT_PC);
	
	
	--Should also be resetted to create a NOP
	-- if branch we should skip two times!
	IF_ID_reset <= flsh or ctrl_branch;
	IF_ID_PC : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_1,CRNT_PC,ID_PC);
	
	ID_EX_PC : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_2,ID_PC,EX_PC);
	
	ADDR_64 : adder64bit
	
	port map(EX_PC,EX_IMM,EX_BRANCH_PC);
	
	EX_MEM_PC : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_3,EX_BRANCH_PC,MEM_BRANCH_PC);
	
	MUX_PC : mux_gen
	generic map(N => Numbit)
	port map(MEM_SRC_PC,CRNT_4_PC,MEM_BRANCH_PC,NXT_PC);
	
	ADDER_4: adder4
	port map(CRNT_PC,CRNT_4_PC);
	
	IF_ID_IR : reg
	generic map(N => inst_size)
	port map(CLK,IF_ID_reset,stage_1,ir_i,ID_IR);
	
	IMM : immediate_gen
	port map(ID_IR,ctrl_imm,ID_IMM);
	
	ID_EX_IMM : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_2,ID_IMM,EX_IMM);
	
	ID_EX_ID_IR : reg
	generic map(N => 5)
	port map(CLK,flsh,stage_2,ID_IR(11 downto 7) ,EX_MEM_RD_IR);
	
	EX_MEM_RD_IR_i : reg
	generic map(N => 5)
	port map(CLK,flsh,stage_3,EX_MEM_RD_IR,MEM_RD_IR);
	
	MEM_WB_RD_IR : reg
	generic map(N => 5)
	port map(CLK,flsh,stage_4,MEM_RD_IR,WB_RD_IR);
	
--	REGISTER_FILE_i : register_file 
--	port map(CLK, RST, '1', WB_WB, reg_file1, reg_file2, WB_RD_IR, ID_IR(19 downto 15), ID_IR(24 downto 20), WB_IR_DATA, ID_RS_1, ID_RS_2);
	REGISTER_FILE_i : register_file 
	port map(CLK, RST, '1', WB_WB, reg_file1, reg_file2, WB_RD_IR, ID_IR(19 downto 15), ID_IR(24 downto 20), WB_IR_DATA, ID_RS_1, ID_RS_2);
	
	ID_EX_RS1 : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_2,ID_RS_1,EX_RS_1);
	
	ID_EX_RS2 : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_2,ID_RS_2,EX_RS_2);
--
	EX_MEM_RS2 : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_2,EX_RS_2,MEM_RS_2);
	
	ID_EX_MUX : FF
	port map(CLK, flsh, stage_2, ALU_src, EX_mux);
	
	ID_EX_ALUCU1 : FF
	port map(CLK,flsh, stage_2,sum_sub_sel,sum_sub_sel_EX);
	ID_EX_ALUCU2 : FF
	port map(CLK,flsh, stage_2,and_xor_sel,and_xor_sel_EX);
	ID_EX_ALUCU3 : FF
	port map(CLK,flsh, stage_2,shift_sel,shift_sel_EX);
	ID_EX_ALUCU4 : FF
	port map(CLK,flsh, stage_2,LUI_sel,LUI_sel_EX);
	ID_EX_ALUCU5 : FF
	port map(CLK,flsh, stage_2,SLT_sel,SLT_sel_EX);
	ID_EX_ALUCU6 : FF
	port map(CLK,flsh, stage_2,Sumn_Sub,Sumn_Sub_EX);
	ID_EX_ALUCU7 : FF
	port map(CLK,flsh, stage_2,andin_xor,andin_xor_EX);
	
	ID_EX_BRANCH_CONTROL : FF
	port map(CLK, flsh, stage_2, ctrl_branch, EX_ctrl_branch);
	
	ID_EX_JUMP_CONTROL : FF
	port map(CLK, flsh, stage_2, jump_control, EX_jump_control);
	
	ID_EX_WB : FF
	port map(CLK, flsh, stage_2, WB, EX_WB);
	
	ID_EX_WB_mux : FF
	port map(CLK, flsh, stage_2, WB_mux, EX_WB_mux);
	
	ID_EX_IS_PC_USED : FF
	port map(CLK, flsh, stage_2, is_PC_used, EX_is_PC_used);
	
	MUX_RS2_PC: mux_gen
	generic map (N => Numbit)
	port map(EX_is_PC_used,EX_RS_1,EX_PC,EX_RS_1_selected);
	
	MUX_IMM_RS2: mux_gen
	generic map (N => Numbit)
	port map(EX_mux,EX_RS_2,EX_IMM,EX_OP2_ALU);
	
	ALU_i : ALU
	port map(EX_RS_1_selected,EX_OP2_ALU,sum_sub_sel_EX, and_xor_sel_EX, shift_sel_EX, LUI_sel_EX, SLT_sel_EX,Sumn_Sub_EX,andin_xor_EX,EX_ALU_ZERO,EX_ALU_RES);
	
	EX_MEM_ZR : FF
	port map(CLK,flsh,stage_3,EX_ALU_ZERO,MEM_ALU_ZERO);
	
	EX_MEM_BRANCH_CONTROL : FF
	port map(CLK, flsh, stage_3, EX_ctrl_branch, MEM_ctrl_branch);
	
	EX_MEM_JUMP_CONTROL : FF
	port map(CLK, flsh, stage_3, EX_jump_control, MEM_jump_control);
	
	ORed_sig <= MEM_ALU_ZERO or MEM_jump_control;	-- ADDED CONTROL TO JUMP IF CASE JAL
	
--	BRANCH_AND : andd
--	port map(MEM_ctrl_branch,ORed_sig,MEM_SRC_PC);
	MEM_SRC_PC <= MEM_ctrl_branch and ORed_sig;
	
	EX_MEM_WB : FF
	port map(CLK, flsh, stage_2, EX_WB, MEM_WB);
	
	EX_MEM_WB_mux : FF
	port map(CLK, flsh, stage_2, EX_WB_mux, MEM_WB_mux);
	
	EX_MEM_ALU_RES : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_3,EX_ALU_RES,MEM_ALU_RES);
	
	MEM_WB_ALU_RES : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_4,MEM_ALU_RES,WB_ALU_RES);
	
	MEM_WB_WB : FF
	port map(CLK, flsh, stage_2, MEM_WB, WB_WB);
	
	MEM_WB_WB_mux : FF
	port map(CLK, flsh, stage_2, MEM_WB_mux, WB_WB_mux);
	
	MUX_WB : mux_gen
	generic map (N => Numbit)
	port map(WB_WB_mux,WB_DMEM_DATA,WB_ALU_RES,WB_IR_DATA);
	
	MEM_WB_DMEM : reg
	generic map(N => Numbit)
	port map(CLK,flsh,stage_4,DMEM_IN,WB_DMEM_DATA);

	
end strc;

	

	



