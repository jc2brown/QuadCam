
-- cpt_clk_gate.vhd
--
-- Clock gate generator
-- Produces a periodic pulse that is high for one i_clk cycle
-- with a frequency equal to i_clk divided by 2*i_div

library ieee;
use ieee.std_logic_1164.all;

library util;
use util.pkg_util.all;


entity cpt_clk_gate is
	port (
		i_clk : in std_logic;
		i_enable : in std_logic;
		i_div : in integer;
		o_clk_pgate : out std_logic;
		o_clk_ngate : out std_logic
	);	
end cpt_clk_gate;

architecture Behavioral of cpt_clk_gate is

	signal count : integer := 0;	
	signal carry : std_logic := '0';
	signal enable_n : std_logic := '1';

begin

	o_clk_pgate <= '1' when count = i_div and carry = '1' else '0';
	o_clk_ngate <= '1' when count = i_div and carry = '0' else '0';
	
	enable_n <= not i_enable;

	cycle_counter : cpt_upcounter
	generic map (
		INIT => 1
	)
	port map (
		i_clk => i_clk, 
		i_enable => i_enable,
		i_lowest => 1,
		i_highest => i_div,
		i_increment => 1,
		i_clear => enable_n,
		i_preset => '0',
		o_count => count,
		o_carry => carry
	);
	
	
end Behavioral;

