

-- Basic Microblaze IO bus timer device

-- This timer is implemented with a software-writable 32-bit register and a hardware counter.
-- When a value is written to the timer register, the counter resets to zero and begins counting up. 
-- The IO bus Ready line is held low until the counter value is equal to the register value.
-- Program execution is halted until Ready is set high. 

-- TODO: Are interrupts blocked while waiting for Ready? (probably...)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


library mcu;
use mcu.pkg_mcu.all;

library util;
use util.pkg_util.all;


entity cpt_timer is

	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0);
		MCU_FREQUENCY : integer
	);

	port (
		i_clk : in std_logic;	
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso
	);
	
end cpt_timer;

architecture Behavioral of cpt_timer is

	signal clk_pgate : std_logic := '0';
	signal ready : std_logic := '1';
	signal max_count : integer := 1;
	signal enable : std_logic := '0';
	signal enable_n : std_logic := '0';

begin

	o_mcu_iobus_miso.ready <= ready;


	-- Timer register	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) and i_mcu_iobus_mosi.write_strobe = '1' ) then
			if ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then
				max_count <= conv_integer(i_mcu_iobus_mosi.write_data);		
			end if;	
		end if;
	end process;
	
	-- Counter controller
	-- Counter is enabled on writes to the timer register,
	-- and disabled when Ready is asserted on timer expiry
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( i_mcu_iobus_mosi.write_strobe = '1' ) then
				if ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then		
					enable <= '1';
				else
					enable <= '0';
				end if;					
			elsif ( ready = '1' ) then
				enable <= '0';
			end if;	
		end if;
	end process;
	
	
	enable_n <= not enable;

	-- Counter clock enable generator
	-- Produces a positive single-cycle pulse once per microsecond
	timer_clk_gate : cpt_clk_gate
	port map (
		i_clk => i_clk,
		i_enable => enable,
		i_div => MCU_FREQUENCY/2000000, -- 1 us per cycle (n.b. cpt_clk_gate divides by 2 internally)
		o_clk_pgate => clk_pgate,
		o_clk_ngate => open
	);

	-- Timer counter 
	cycle_counter : cpt_upcounter
	generic map (
		INIT => 1
	)
	port map (
		i_clk => i_clk, 
		i_enable => clk_pgate,
		i_lowest => 0,
		i_highest => max_count,
		i_increment => 1,
		i_clear => enable_n,
		i_preset => '0',
		o_count => open,
		o_carry => ready
	);
	
	
end Behavioral;

