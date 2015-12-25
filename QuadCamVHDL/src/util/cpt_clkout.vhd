
library ieee;
use ieee.std_logic_1164.all;


library unisim;
use unisim.vcomponents.all;

library util;

-- Generate an oddr2 block for pins carrying output clocks
-- The output clock may be divided by a factor of two
-- If CLK_DIV2 = 0 : f_out = f_in 
-- If CLK_DIV2 > 0 : f_out = f_in / (2*CLK_DIV2)

entity cpt_clkout is
	port (
		i_enable : in std_logic;
		i_clk_div : in integer;
		i_clk : in std_logic;
		o_clk : out std_logic
	);
	
end cpt_clkout;

architecture Behavioral of cpt_clkout is

	signal clk : std_logic := '0';
	signal clk_n : std_logic := '1';
	
	signal clk_div : integer := 0;
	signal div_count : integer := 0;
	signal div_out : std_logic := '1';

	signal reset : std_logic := '1';

begin

	clk <= i_clk;
	clk_n <= not clk;


--	gen_nodiv_clk :
--	if ( CLK_DIV2 = 0 ) generate
--	
--		clk_oddr2 : oddr2
--		generic map(
--			DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
--			INIT => '0', -- Sets initial state of the Q output to '0' or '1'
--			SRTYPE => "SYNC" -- Specifies "SYNC" or "ASYNC" set/reset
--		)
--		port map (
--			Q => o_clk, -- 1-bit output data to pin
--			C0 => clk, -- 1-bit clock input
--			C1 => clk_n, -- 1-bit clock input
--			CE => i_enable, -- 1-bit clock enable input
--			D0 => '0', -- 1-bit data input (associated with C0)
--			D1 => '1', -- 1-bit data input (associated with C1)
--			R => '0', -- 1-bit reset input
--			S => '0' -- 1-bit set input
--		);
--		
--	end generate gen_nodiv_clk;
--	
--	
--	
--	gen_div_clk :
--	if ( CLK_DIV2 /= 0 ) generate


		
		process(i_clk)
		begin	
			--if ( rising_edge(i_clk) and i_enable = '1' ) then
			if ( rising_edge(i_clk) and (reset = '1' or i_enable = '1') ) then
				reset <= '0';
				if ( clk_div /= i_clk_div ) then
					clk_div <= i_clk_div;
					reset <= '1';
				end if;
			end if;
		end process;
	
	
	
	

	
		process(i_clk, i_enable)
		begin
			if ( rising_edge(i_clk) and i_enable = '1' ) then	
				if ( reset = '1' ) then
					div_count <= 1; 
				elsif ( div_count = clk_div ) then
					div_count <= 1;
					div_out <= not div_out;
				else 
					div_count <= div_count + 1;
				end if;
			end if;
		end process;

		clk_oddr2 : oddr2
		generic map(
			DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
			INIT => '0', -- Sets initial state of the Q output to '0' or '1'
			SRTYPE => "SYNC" -- Specifies "SYNC" or "ASYNC" set/reset
		)
		port map (
			Q => o_clk, -- 1-bit output data to pin
			C0 => clk, -- 1-bit clock input
			C1 => clk_n, -- 1-bit clock input
			CE => i_enable, -- 1-bit clock enable input
			D0 => div_out, -- 1-bit data input (associated with C0)
			D1 => div_out, -- 1-bit data input (associated with C1)
			R => '0', -- 1-bit reset input
			S => '0' -- 1-bit set input
		);
--		
--	end generate gen_div_clk;
	
	
	
	


end Behavioral;

