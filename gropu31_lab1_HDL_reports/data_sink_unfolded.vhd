library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

--we take three results at the same time (k0, k1, k2)
entity data_sink_unfolded is
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    VIN   : in std_logic;
    DINK0   : in std_logic_vector(10 downto 0);
	DINK1   : in std_logic_vector(10 downto 0);
	DINK2   : in std_logic_vector(10 downto 0)
);
end data_sink_unfolded;

architecture beh of data_sink_unfolded is

begin  -- beh

  process (CLK, RST_n)
    file res_fp : text open WRITE_MODE is "./results.txt";
    variable line_out : line;    
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      null;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (VIN = '1') then

--write for 3 times...
-- must see if correct to write like this...
        write(line_out, conv_integer(signed(DINK0)));
        writeline(res_fp, line_out);
		
		write(line_out, conv_integer(signed(DINK1)));
        writeline(res_fp, line_out);

		write(line_out, conv_integer(signed(DINK2)));
        writeline(res_fp, line_out);
      end if;
    end if;
  end process;

end beh;
