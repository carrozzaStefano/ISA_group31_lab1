library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;



entity register_file is 

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
		
end entity;

ARCHITECTURE behavioral of register_file is
	
		subtype reg_addr is natural range 0 to (2**addr_size)-1;  --natural type
			type register_array is array(reg_addr) of std_logic_vector ( data_size-1 downto 0);
			signal registers : register_array;   --32 64-bit cells 
			
			signal rd1_addr_s : integer range 0 to (2**addr_size)-1;
			signal rd2_addr_s : integer range 0 to (2**addr_size)-1;
			signal wrt_addr_s : integer range 0 to (2**addr_size)-1;

begin

	rd1_addr_s <= to_integer (unsigned(rd1_addr));
	rd2_addr_s <= to_integer (unsigned(rd2_addr));
	wrt_addr_s <= to_integer (unsigned(wrt_addr));
	
	rd_proc :
	process(en, rd1, rd2, rd1_addr_s, rd2_addr_s, data_in) --read process
	begin
	--default values
		data_out1 <= (others => '0');
		data_out2 <= (others => '0');
					if rd1 = '1' then		-- read 1
						data_out1 <= registers(rd1_addr_s);
					end if;
					if rd2 = '1' then		-- read 2
						data_out2 <= registers(rd2_addr_s);
					end if;
	end process;

	wr_proc :
	process(clk)
	begin
		if clk'event and clk = '1' then	    -- clock pos edge
			if rst = '0' then
				registers <= registers;	--default
				if wrt = '1' then		-- write
						if wrt_addr_s = 0 then
							--NOP
							registers(wrt_addr_s) <= (others => '0');
						else
							registers(wrt_addr_s) <= data_in;
						end if;
				end if;
			else --reset
				for i in 0 to (2**addr_size)-1 loop	-- RF cells wiped
					registers(i) <= (others => '0');
				end loop;
			end if;
		end if;
	end process;
			
	--rf_proc :
	--process(clk)
    --combinatorial to respect timing
	--process(rst, en, wrt, rd1, rd2, wrt_addr_s, rd1_addr_s, rd2_addr_s, data_in)
	--begin
			--default values
		--	data_out1 <= (others => '0');
		--	data_out2 <= (others => '0');
			
		--if clk'event and clk = '1' then	    -- clock pos edge
			--if rst = '0' then			    -- reset inactive
				--if en = '1' then		    -- enable active
					--if rd1 = '1' then		-- read 1
						--data_out1 <= registers(rd1_addr_s);
					--end if;
					--if rd2 = '1' then		-- read 2
						--data_out2 <= registers(rd2_addr_s);
					--end if;
					--if wrt = '1' then		-- write
						--if wrt_addr_s = 0 then
							--NOP
							--registers(wrt_addr_s) <= (others => '0');
						--else
							--registers(wrt_addr_s) <= data_in;
						--end if;
					--end if;
				--end if;
			--else							-- reset active
				--data_out1 <= (others => '0');	-- output 1 is reseted
				--data_out2 <= (others => '0');	-- output 2 is reseted
				--for i in 0 to (2**addr_size)-1 loop	-- RF cells wiped
					--registers(i) <= (others => '0');
				--end loop;
			--end if;
		--end if;
	--end process;
end behavioral;
