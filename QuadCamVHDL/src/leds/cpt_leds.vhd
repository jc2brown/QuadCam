
-- LED multiplexer/driver
-- 
-- There are 7 user LEDs on-board. 
-- These LEDs are driven one at a time using three LED address lines from the FPGA through a 3-to-8 line demultiplexer IC.
-- LED N (1<=N<=7) is enabled when the 3-bit LED address from the FPGA is equal to N. 
-- When the LED address is 0, no LED is illuminated.
-- The LED switching frequency is equal to the frequency of i_clk divided by i_led_clk_div.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library util;
use util.pkg_util.all;

library leds;
use leds.pkg_leds.all;


entity cpt_leds is

	port (	
		i_clk : in std_logic;		
		i_leds : in std_logic_vector(7 downto 1);		
		i_led_clk_div : in integer;
		i_led_latch_div : in integer;
		o_led_addr : out std_logic_vector(2 downto 0)		
	);

end cpt_leds;


architecture Behavioral of cpt_leds is

	signal leds : std_logic_vector(7 downto 1);
	signal led_count : integer range 0 to 7 := 1;	
	signal clk_pgate : std_logic := '0';
	signal latch_pgate : std_logic := '0';

begin


	led_clk_gate : cpt_clk_gate
	port map (
		i_clk => i_clk,
		i_enable => '1',
		i_div => i_led_clk_div,
		o_clk_pgate => clk_pgate,
		o_clk_ngate => open
	);
	
	led_latch_gate : cpt_clk_gate
	port map (
		i_clk => i_clk,
		i_enable => '1',
		i_div => i_led_latch_div,
		o_clk_pgate => latch_pgate,
		o_clk_ngate => open
	);
	
	process(i_clk) 
	begin
		if ( rising_edge(i_clk) and latch_pgate = '1' ) then
			leds <= i_leds;
		end if;
	end process;
	

	o_led_addr <= conv_std_logic_vector(led_count, 3) when leds(led_count) = '1' else "000";

	led_counter : cpt_upcounter
	generic map (
		INIT => 1
	)
	port map (
		i_clk => i_clk,
		i_enable => clk_pgate,
		i_clear => '0',
		i_preset => '0',
		i_increment => 1,
		i_lowest => 1,
		i_highest => 7,
		o_count => led_count,
		o_carry => open
	);


end Behavioral;

