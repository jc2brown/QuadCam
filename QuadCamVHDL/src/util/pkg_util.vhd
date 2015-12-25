
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library util;

package pkg_util is

	function cycles_f(duration, frequency : real) return integer is
	begin
		return integer(ceil(duration * frequency));
	end cycles_f;
	
	function cycles_p(duration, period : real) return integer is
	begin
		return integer(ceil(duration / period));
	end cycles_p;
	
		
	function frequency(period : real) return real is
	begin
		return 1.0 / period;
	end frequency;
		
	function period(frequency : real) return real is
	begin
		return 1.0 / frequency;
	end period;
	
	

	component cpt_clkout is
--		generic (
--			CLK_DIV2 : natural := 0	
--		);
		port (
			i_enable : in std_logic;
			i_clk_div : in integer;
			i_clk : in std_logic;
			o_clk : out std_logic
		);	
	end component;
	
	component cpt_upcounter is
		generic (
			INIT : integer := -1
		);
		port ( 
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_lowest : in integer;
			i_highest : in integer;
			i_increment : in integer;
			i_clear : in std_logic;
			i_preset : in std_logic;
			o_count : out integer := INIT;
			o_carry : out std_logic
		);		
	end component;
	
	component cpt_clk_gate is
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_div : in integer;
			o_clk_pgate : out std_logic;
			o_clk_ngate : out std_logic
		);	
	end component;	
	
	
	 

end pkg_util;


package body pkg_util is 
end pkg_util;
