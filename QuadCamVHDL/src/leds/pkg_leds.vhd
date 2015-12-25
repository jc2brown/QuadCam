
library ieee;
use ieee.std_logic_1164.all;

library leds;

package pkg_leds is
	
	component cpt_leds is
		port (	
			i_clk : in std_logic;		
			i_leds : in std_logic_vector(7 downto 1);		
			i_led_clk_div : in integer;
			i_led_latch_div : in integer;
			o_led_addr : out std_logic_vector(2 downto 0)		
		);
	end component;	


end pkg_leds;


package body pkg_leds is 
end pkg_leds;
