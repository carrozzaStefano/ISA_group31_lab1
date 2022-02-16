LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY testbench IS
END ENTITY testbench;

ARCHITECTURE layout OF testbench IS

--COMPONENTS
component riscv_lite is

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
	
	
end component;

signal CLK_tb, RST_tb: std_logic;

signal instruction_tb: std_logic_vector(32-1 downto 0);
signal memin_tb,memout_tb: std_logic_vector(64-1 downto 0);
signal memaddress_tb: std_logic_vector(6-1 downto 0);
signal pc_tb: std_logic_vector(64-1 downto 0);
signal write_tb,read_tb: std_logic;

--------------------------SIGNALSOLDSYSTEM------------------------------
--TO BE DELETED
--PC signals used for in and out of program counter;
-- in is calculated if branch/jump op else is pc+4
--signal PC_IN, PC_OUT	:	std_logic_vector(63 downto 0);
--possible PC next address value
--signal PC_inorder, PC_branched	:	std_logic_vector(63 downto 0);
-- immediate part just calculated; goes to PC_offset and MUX before ALU
--signal immediate_gen_out : std_logic_vector(63 downto 0);
--PC_offset taken from the immediate part of theinstr. code and goes in the Branch_offset_calc adder
--signal PC_offset : std_logic_vector(63 downto 0);
-- ALU_MUX signal that goes in the second input slot of the ALU
--signal MUX_ALU_OUT : std_logic_vector(63 downto 0);
--control signals (these should be output of the control/decode unit)
--PC_MUX controller signal
--signal PC_selector : std_logic;

-- Memory 

type dram_t  is array ( 0 to 16-1) of std_logic_vector (64-1 downto 0 ) ;
type irmem_t  is array ( 0 to 64-1) of std_logic_vector ( 32-1 downto 0 ) ;

signal DRAM : dram_t:=
( "0000000000000000000000000000000000000000000000000000000000001010",-- 0 x0000 10
"1111111111111111111111111111111111111111111111111111111111010001" ,-- 0 x0004 -47
"0000000000000000000000000000000000000000000000000000000000010110" ,-- 0 x0008 22
"1111111111111111111111111111111111111111111111111111111111111101" ,-- 0x000C -3
"0000000000000000000000000000000000000000000000000000000000001111" ,-- 0 x0010 15
"0000000000000000000000000000000000000000000000000000000000011011" ,-- 0 x0014 27
"1111111111111111111111111111111111111111111111111111111111111100" ,-- 0 x0018 -4
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0x001C
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0020
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0024
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0028
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0x002C
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0030
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0034
"0000000000000000000000000000000000000000000000000000000000000000" ,-- 0 x0038
"0111111111111111111111111111111111111111111111111111111111111111" -- 0x003C
) ;
signal IRMEM : irmem_t:=
("00000000011100000000100000010011" ,-- 0 x0000 ADDI x16, x0 7
"00000000000000000000001000010011" ,-- 0 x0004 ADDI x4, x0 0 (address of v)
"00000001110000000000001010010011" ,-- 0 x0008 ADDI x5, x0 28 (address of m)
"00000011110000000000011000010011" ,-- 0x000C ADDI x12, x0 60 (address of the max value) 
"00000000000000000000000000010011" ,-- 0 x0010 NOP
"00000000000000000000000000010011" ,-- 0 x0014 NOP
"00000000000000000000000000010011" ,-- 0 x0018 NOP
"00000000000001100000011010000011" ,-- 0x001C LW x13 0(x12) (so that we can load the max in x13)
"00000111000000000000110001100011" ,-- 0 x0020 BEQ x0 x16 30 (go to done)(12 instructions)
"00000000000000000000000000010011" ,-- 0 x0024	NOP
"00000000000000100000010000000011" ,-- 0 x0028 LW x8 0(x4) (load v(i) in x8)
"00000000000000000000000000010011" ,-- 0 x002C NOP
"00000000000000000000000000010011" ,-- 0x0030 NOP
"00000000000000000000000000010011" ,-- 0 x0034 NOP
"00000000000000000000000000010011" ,-- 0 x0038 NOP
"00000001111101000101010010010011" ,-- 0 x003C SRAI x9, x8 16
"00000000000000000000000000010011" ,-- 0x0040 NOP
"00000000000000000000000000010011" ,-- 0 x0044 NOP
"00000000000000000000000000010011" ,-- 0 x0048 NOP
"00000000000000000000000000010011" ,-- 0 x004C NOP
"00000000100101000100010100110011" ,-- 0x0050 XOR x10 x8 x9
"00000000000101001111010010010011" ,-- 0 x0054 ANDI x9 x9 0x1
"00000000000000000000000000010011" ,-- 0 x0058 NOP
"00000000000000000000000000010011" ,-- 0 x005C NOP
"00000000000000000000000000010011" ,-- 0x0060 NOP
"00000000000000000000000000010011" ,-- 0 x0064 NOP
"00000000100101010000010100110011" ,-- 0 x0068 ADD x10, x10 x9
"00000000010000100000001000010011" ,-- 0 x006C ADDI x4, x4 0x4
"11111111111110000000100000010011" ,-- 0x0070 ADDI x16 x16 -1
"00000000110101010010010110110011" ,-- 0 x0074 SLT x11 x10 x13 
"00000000000000000000000000010011" ,-- 0 x0078 NOP
"00000000000000000000000000010011" ,-- 0 x007C NOP
"00000000000000000000000000010011" , -- 0x0080 NOP
"00000000000000000000000000010011" , -- 0 x0084 NOP
"11111000000001011000110011100011" , -- 0 x0088 BEQ x0 x11 -26 (9 instr)
"00000000000000000000000000010011" , -- 0x 008C
"00000000000001010000011010110011" , -- 0 x0090 ADD x13, x10 x0
"11111000110111111111000011101111" , -- 0x0094 JAL -29 (11 instr)
"00000000000000000000000000010011" ,
"00000000110100101010000000100011" , -- 0 x0098 SW x13 0(x5)
"00000000000000000000000011101111" , -- 0 x009C JAL 0
"00000000000000000000000000010011" , -- 0 x00A0 NOP
"00000000000000000000000000010011" , -- 0x00A4 NOP
"00000000000000000000000000000000" , -- 0x0 etc...
"00000000000000000000000000000000" , -- 0x00A4
"00000000000000000000000000000000" , -- 0x00A8
"00000000000000000000000000000000" , -- 0x00AC
"00000000000000000000000000000000" , -- 0x00B0
"00000000000000000000000000000000" , -- 0x00B4
"00000000000000000000000000000000" , -- 0x00B8
"00000000000000000000000000000000" , -- 0x00BC
"00000000000000000000000000000000" , -- 0x00C0
"00000000000000000000000000000000" , -- 0x00C4
"00000000000000000000000000000000" , -- 0x00C8
"00000000000000000000000000000000" , -- 0x00CC
"00000000000000000000000000000000" , -- 0x00D0
"00000000000000000000000000000000" , -- 0x00D4
"00000000000000000000000000000000" , -- 0x00D8
"00000000000000000000000000000000" , -- 0x00DC
"00000000000000000000000000000000" , -- 0x00E0
"00000000000000000000000000000000" , -- 0x00E8
"00000000000000000000000000000000" , -- 0x00EC
"00000000000000000000000000000000" , -- 0x00F0
"00000000000000000000000000000000"  -- 0x00FC

) ;

begin 


-- clock process
clock:process
	begin	
	CLK_tb <= '0';
	wait for 10 ns;
	CLK_tb <= '1';
	wait for 10 ns;
end process;

--reset at the beginning
RST_tb <= '1', '0' after 15 ns;

-- instruction register process
pc:process(pc_tb)
	variable address_int : integer;
	begin
	address_int := to_integer(unsigned(pc_tb)); -- only the relevant part
	instruction_tb <= IRMEM((address_int/4));
end process;

-- data memory process
write_read: process(write_tb, read_tb, memaddress_tb, memout_tb)
	variable address_int : integer;
	begin
	address_int := to_integer(unsigned(memaddress_tb));
	--read
	if read_tb = '1' then
		memin_tb <= DRAM(address_int/4);
	end if;
	
	--write
	if write_tb = '1' then
		DRAM(address_int/4) <= memout_tb;
	end if;
end process;
	
	

DUT: riscv_lite port map(CLK_tb, RST_tb, instruction_tb,memin_tb,pc_tb,memout_tb,memaddress_tb, write_tb, read_tb);
	
--OLD SYSTEM (TO BE DELETED)
--------------------------FETCH----------------------------------
--PC 64 bits register and updated by 4 when in order
-- Inorder is calculated here while the branch/jump is calculated in the execution stage
--!MAYBE A STALL STATE SHOULD BE ADDED TO ADD NOP IN THE PIPELINE WHEN YOU NEED TO STALL LIKE IN BRANCHES...
	--Next_Address_Inorder : adder4 port map(PC_OUT, PC_inorder);
	--PC_MUX : mux_gen generic(64) port map(PC_selector, PC_inorder, PC_branched);
	--PC : reg generic(64) port map(CLK, PC_IN, PC_OUT);
--INSTR MEMORY structured in 4 bytes operations (32 bits)
-------------------------DECODE--------------------------------
--INSTR DECODE/ CONTROL UNIT gives different control signal to everything following the received instruction
-- immediate part generation from 32 to 64 bits
-- in comes from the instruction code and output is the immediate part
--REGISTER FILE 32*64 bits; all registers have specific roles => see in slides
--------------------------EXECUTE--------------------------------------
--EXECUTION/ALU should be able to calculate different things depending on the control signals
-- able to manipulate data and address
-- ALU is used to manipulate every data and should be able to sum, subtract, shift, overwrite, case of LUI
-- have a zero flag(probably should pass in CU), bitwise andi xor,
-- also be able to write the sign of the result in the whole destination register (SLT)
-- In should be reg1; the mux of reg2 and immediate part of the code; ALU control for + or - or shift
	-- signals to be added
	-- MAYBE ADD ANOTHER WAY TO TAKE THE PC VALUE IN THE FIRST SOURCE REGISTER VALUE... AUIPC CASE
	--MUX_ALU : mux_gen generic(64) port map(selector, reg1, reg2, MUX_ALU_OUT);
	--ALU_DUT : ALU port map(--TO BE ADDED)
-- Branched address calculation;
-- Adder 64 bits with PC and immediate part of the instruction
	--Branch_offset_calc : adder64bit port map(PC_OUT, PC_offset, PC_branched);
	--PC_offset should be taken in the immediate part of the instruction
-------------------------------MEMORY SAVE--------------------------------
--DATA MEMORY
-----------------------------------WB-----------------------------------
--write back (probably just a simple MUX)
--END OLD SYSTEM


END layout;
