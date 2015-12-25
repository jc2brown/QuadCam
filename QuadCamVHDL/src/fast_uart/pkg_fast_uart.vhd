
library ieee;
use ieee.std_logic_1164.all;

library mcu;
use mcu.pkg_mcu.all;


library fast_uart;

package pkg_fast_uart is

	component cpt_fast_uart_tx is

		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		
		
		port (

			clk : in std_logic;
			reset : in std_logic;
			enable : in std_logic;
			
			baud_div : in integer range 0 to 2**16-1;

			
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;	
			
			empty : out std_logic;
			full : out std_logic;
			
			txd : out std_logic
		);
		
	end component;







	component cpt_fast_uart_rx is

		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);

		port (

			 clk : in std_logic;
			 reset : in std_logic;
			 enable : in std_logic;
			
			 baud_div : in integer range 0 to  2**16-1;
			 
			 		 
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;	
			 
			full : out std_logic;
			empty : out std_logic;
			
			 rxd : in std_logic
		);
		
	end component;




end pkg_fast_uart;
