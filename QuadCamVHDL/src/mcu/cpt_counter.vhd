

-- Basic Microblaze IO bus counter device


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library mcu;
use mcu.pkg_mcu.all;

library util;
use util.pkg_util.all;


entity cpt_counter is

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
	
end cpt_counter;

architecture Behavioral of cpt_counter is

	signal count : integer := 0;

begin

	o_mcu_iobus_miso.ready <= '1';
	o_mcu_iobus_miso.read_data <= std_logic_vector(to_unsigned(count, 32));

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			count <= count + 1;
		end if;
	end process;

	
	
end Behavioral;

