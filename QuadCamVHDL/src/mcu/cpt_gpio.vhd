
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library mcu;
use mcu.pkg_mcu.all;

entity cpt_gpio is

	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0);
		N_GPIOS : integer
	);

	port (
		i_clk : in std_logic;	
		i_reset : in std_logic;	
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;				
		i_gpi : in typ_mcu_word_array;
		o_gpo : out typ_mcu_word_array
	);
	
end cpt_gpio;


architecture Behavioral of cpt_gpio is

begin
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			o_mcu_iobus_miso.ready <= i_mcu_iobus_mosi.addr_strobe;
		end if;
	end process;	
	
	
	process(i_clk)
	begin			
				
		if ( rising_edge(i_clk) ) then		
		
		
			--if ( i_reset = '1' ) then
				--for i in 0 to N_GPIOS-1 loop	
				--	o_gpo(i) <= (others => '0');
				--end loop;
				
			--elsif ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then
			if ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then
			
				for  i in 0 to N_GPIOS-1 loop
				
					if ( i_mcu_iobus_mosi.read_strobe = '1' and i_mcu_iobus_mosi.address(25 downto 2) = conv_std_logic_vector(i, 24) ) then				
						o_mcu_iobus_miso.read_data <= i_gpi(i);
					end if;
				
					if ( i_mcu_iobus_mosi.write_strobe = '1' and i_mcu_iobus_mosi.address(25 downto 2) = conv_std_logic_vector(i, 24) ) then				
						o_gpo(i) <= i_mcu_iobus_mosi.write_data;
					end if;
					
				end loop;
				
			end if;
		end if;
	end process;


end Behavioral;

