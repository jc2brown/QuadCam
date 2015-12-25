
-- util/cpt_upcounter.vhd

-- Produces an integer o_count 
-- that increases from i_lowest to i_highest 
-- in steps of i_increment
-- when i_enable is high 
-- during a rising edge of i_clk


library ieee;
use ieee.std_logic_1164.all;

--library util;
--use util.pkg_util.ALL;


entity cpt_upcounter_testing is
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
end cpt_upcounter_testing;


architecture Behavioral of cpt_upcounter_testing is

signal count : integer := INIT;
signal lowest : integer := 0;
signal highest : integer := 0;
signal increment : integer := 1;
signal reset : std_logic := '1';
signal carry : std_logic := '0';

begin
	
	o_count <= count;
	o_carry <= carry;	
	
	
	process(i_clk)
	begin	
		--if ( rising_edge(i_clk) and i_enable = '1' ) then
		if ( rising_edge(i_clk) and (reset = '1' or i_enable = '1') ) then
			reset <= '0';
			if ( lowest /= i_lowest ) then
				lowest <= i_lowest;
				reset <= '1';
			end if;
			if ( highest /= i_highest ) then
				highest <= i_highest;
				reset <= '1';
			end if;
			if ( increment /= i_increment ) then
				increment <= i_increment;
				reset <= '1';
			end if;
		end if;
	end process;
	
	
	process(i_clk, i_clear, i_preset)
	begin	
		if ( i_clear = '1' ) then
			count <= lowest;
			carry <= '0';	
		elsif ( i_preset = '1' ) then
			count <= highest;
			--carry <= '1';		-- omitted for now
		elsif ( rising_edge(i_clk) and i_enable = '1' ) then
			if ( reset = '1' ) then
				count <= lowest; 
				carry <= '0';
			elsif ( count >= highest ) then
				count <= lowest; 
				carry <= not carry;
			else 
				count <= count + increment;
			end if;				
		end if;
	end process;	

end Behavioral;


