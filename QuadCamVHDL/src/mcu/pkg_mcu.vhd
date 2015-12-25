--
-- MCU package
--

library ieee;
use ieee.std_logic_1164.all;


library ovm;
use ovm.pkg_ovm.all;

library mctl;
use mctl.pkg_mctl.all;

library usb;
use usb.pkg_usb.all;

library mcu;

package pkg_mcu is
	-- =================================================== --
	-- GPIO assignments
	-- =================================================== --

	-- These must match the #defines in ..SW/src/iobus.h
	constant N_GPIOS : integer := 16#C0#;

	-- GPIOs between 0x00 and 0x7F are external to cpt_mcu

	constant GPIO_ERROR_LED			: integer := 16#00#;
	constant GPIO_LEDS1				: integer := 16#01#;
	constant GPIO_LEDS2				: integer := 16#02#;
		
	constant GPIO_SWITCH_STATUS		: integer := 16#08#;
	
	constant GPIO_SWITCH_SRC		: integer := 16#0C#;

	constant GPIO_ERROR_LED_SRC		: integer := 16#10#;
	constant GPIO_LEDS_SRC			: integer := 16#11#;
	constant GPIO_LEDCLK_DIV		: integer := 16#12#;
	constant GPIO_LED_LATCH_DIV		: integer := 16#13#;

	constant GPIO_FLASH_CLK_DIV		: integer := 16#18#;
	constant GPIO_FLASH_ON			: integer := 16#19#;
	constant GPIO_FLASH_MAX			: integer := 16#1A#;

	constant GPIO_DEBUG				: integer := 16#20#;
	--constant GPIO_DEBUG				: integer := 16#21#;
	--constant GPIO_DEBUG_SRC			: integer := 16#22#;
	
	
	constant GPIO_MCTL_STATUS			: integer := 16#28#;

	constant GPIO_PROBE_ENABLE		: integer := 16#30#;
	constant GPIO_PROBE_CLEAR		: integer := 16#31#;
	constant GPIO_PROBE_SRC			: integer := 16#32#;
	constant GPIO_PROBE_LATCH_DIV	: integer := 16#33#;
	constant GPIO_PROBE_LOW			: integer := 16#34#;
	constant GPIO_PROBE_HIGH		: integer := 16#35#;
	constant GPIO_PROBE_FALL		: integer := 16#36#;
	constant GPIO_PROBE_RISE		: integer := 16#37#;

	
	constant GPIO_OVM_BRAM_ENABLE		: integer := 16#40#;
	constant GPIO_OVM_MUX_ENABLE		: integer := 16#41#;
		
	constant GPIO_OVM0_LINE_OFFSET	: integer := 16#44#;
	constant GPIO_OVM1_LINE_OFFSET	: integer := 16#45#;
	constant GPIO_OVM2_LINE_OFFSET	: integer := 16#46#;
	constant GPIO_OVM3_LINE_OFFSET	: integer := 16#47#;	
		
	constant GPIO_OVM_FRAME_ADDR0	: integer := 16#48#;
	constant GPIO_OVM_FRAME_ADDR1	: integer := 16#49#;
	constant GPIO_OVM_FRAME_ADDR2	: integer := 16#4A#;
	constant GPIO_OVM_FRAME_ADDR3	: integer := 16#4B#;	
	
	constant GPIO_OVM_PCLK			: integer := 16#4C#;
	constant GPIO_OVM_HREF			: integer := 16#4D#;
	constant GPIO_OVM_VSYNC			: integer := 16#4E#;
	

	constant GPIO_RAM_ERROR_STATUS0	: integer := 16#50#;
	constant GPIO_RAM_ERROR_STATUS1	: integer := 16#51#;
	constant GPIO_RAM_ERROR_STATUS2	: integer := 16#52#;
	constant GPIO_RAM_ERROR_STATUS3	: integer := 16#53#;
	constant GPIO_RAM_STATUS		: integer := 16#54#;

	constant GPIO_VGA_ENABLE		: integer := 16#60#;
	constant GPIO_VGA_SRC			: integer := 16#61#;
	constant GPIO_VGA_TEST_ENABLE	: integer := 16#62#;
	constant GPIO_VGA_TEST_MODE		: integer := 16#63#;
	
	constant GPIO_VGA_FRAME_ADDR0	: integer := 16#64#;
	constant GPIO_VGA_FRAME_ADDR1	: integer := 16#65#;
	constant GPIO_VGA_FRAME_ADDR2	: integer := 16#66#;
	constant GPIO_VGA_FRAME_ADDR3	: integer := 16#67#;
	
	constant GPIO_VGA_MID_LINE_OFFSET	: integer := 16#68#;
	
	constant GPIO_VGA_MAGIC : integer := 16#69#;
	constant GPIO_VGA_MAGIC_KEY : integer := 16#6A#;
	
	
	
	
	constant GPIO_USB_ENABLE	: integer := 16#70#;
	constant GPIO_USB_MODE		: integer := 16#71#;
	
	constant GPIO_USB_FRAME_ADDR0		: integer := 16#74#;
	constant GPIO_USB_FRAME_ADDR1		: integer := 16#75#;
	constant GPIO_USB_FRAME_ADDR2		: integer := 16#76#;
	constant GPIO_USB_FRAME_ADDR3		: integer := 16#77#;
	
	constant GPIO_RESET					: integer := 16#7F#;
	
	
	

	-- GPIOs between 0x80 and 0xFF are internal to cpt_mcu

	constant GPIO_OVM_ENABLE		: integer := 16#80#;
	constant GPIO_OVM_XVCLK_DIV 	: integer := 16#81#;
	constant GPIO_OVM_SCL_CLK_DIV	: integer := 16#82#;
	constant GPIO_OVM_DEV_ADDR		: integer := 16#83#;

	constant GPIO_UART_BAUD_DIV	: integer := 16#90#;
	constant GPIO_UART_RX_SRC		: integer := 16#91#;
	constant GPIO_UART_TX_SRC		: integer := 16#92#;
	constant GPIO_UART_STATUS		: integer := 16#93#;

	constant GPIO_WIFI_BAUD_DIV		: integer := 16#A0#;
	constant GPIO_WIFI_RX_SRC		: integer := 16#A1#;
	constant GPIO_WIFI_TX_SRC		: integer := 16#A2#;
	constant GPIO_WIFI_STATUS		: integer := 16#A3#;

	constant GPIO_WIFI_ENABLE		: integer := 16#A4#;

	constant GPIO_WIFI_RXD			: integer := 16#A5#;
	constant GPIO_WIFI_RXD_OUTPUT_ENABLE	: integer := 16#A6#;

	constant GPIO_WIFI_GPIO			: integer := 16#A7#;
	constant GPIO_WIFI_GPIO_OUTPUT_ENABLE	: integer := 16#A8#;

	constant GPIO_USB_STATUS	: integer := 16#B0#;
	
	constant GPIO_DEBUG_OUTPUT_ENABLE	: integer := 16#B4#;


	-- =================================================== --
	-- Type definitions
	-- =================================================== --

	--subtype typ_mcu_word is std_logic_vector(31 downto 0);
	type typ_mcu_word_array is array (0 to N_GPIOS-1) of std_logic_vector(31 downto 0);

	-- Microblaze IOBus signals (see ds865 pg3)
	-- Master: microblaze
	-- Slaves: custom peripherals
	type typ_mcu_iobus_miso is record
		read_data : std_logic_vector(31 downto 0);
		ready : std_logic;
	end record;

	constant init_mcu_iobus_miso : typ_mcu_iobus_miso := (
		read_data => x"FFFFFFFF",
		ready => '0'
	);

	type typ_mcu_iobus_mosi is record
		addr_strobe : std_logic;
		read_strobe : std_logic;
		write_strobe : std_logic;
		address : std_logic_vector(31 downto 0);
		byte_enable : std_logic_vector(3 downto 0);
		write_data : std_logic_vector(31 downto 0);
	end record;

	constant init_mcu_iobus_mosi : typ_mcu_iobus_mosi := (
		addr_strobe => '0',
		read_strobe => '0',
		write_strobe => '0',
		address => x"FFFFFFFF",
		byte_enable => x"F",
		write_data => x"FFFFFFFF"
	);


	-- =================================================== --
	-- Component definitions
	-- =================================================== --

	-- Soft-core processor
	-- References cpt_microblaze.xco generated core
	component cpt_microblaze
		port (
			Clk : IN STD_LOGIC;
			Reset : IN STD_LOGIC;
			IO_Addr_Strobe : OUT STD_LOGIC;
			IO_Read_Strobe : OUT STD_LOGIC;
			IO_Write_Strobe : OUT STD_LOGIC;
			IO_Address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IO_Byte_Enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			IO_Write_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IO_Read_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			IO_Ready : IN STD_LOGIC;
			UART_Rx : IN STD_LOGIC;
			UART_Tx : OUT STD_LOGIC;
			UART_Interrupt : OUT STD_LOGIC;
			GPO1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPO2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPO3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPO4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPI1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPI1_Interrupt : OUT STD_LOGIC;
			GPI2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPI2_Interrupt : OUT STD_LOGIC;
			GPI3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPI3_Interrupt : OUT STD_LOGIC;
			GPI4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			GPI4_Interrupt : OUT STD_LOGIC;
			INTC_Interrupt : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			INTC_IRQ : OUT STD_LOGIC
		);
	end component;

	-- Data link between the Microblaze IOBus and external RAM via the MCB
	component cpt_iobus_mport
		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		port (
			i_clk : in std_logic;
			i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
			o_mcu_iobus_miso : out typ_mcu_iobus_miso;
			i_mctl_mport_mosi : in typ_mctl_mport_mosi;
			o_mctl_mport_miso : out typ_mctl_mport_miso
		);
	end component;
	
	component cpt_iobus_usb is
		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		port (
			i_clk : in std_logic;
			i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
			o_mcu_iobus_miso : out typ_mcu_iobus_miso;
			i_usb_data : in std_logic_vector(7 downto 0);
			o_usb_data : out std_logic_vector(7 downto 0);
			i_usb_ctrl_miso : in typ_usb_ctrl_miso;
			o_usb_ctrl_mosi : out typ_usb_ctrl_mosi
		);
	end component;

	component cpt_i2c is
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_scl_clk_div : in integer;
			i_addr : in std_logic_vector(6 downto 0);
			o_rd_data : out std_logic_vector(7 downto 0);
			o_rd_data_strobe : out std_logic;
			i_rd_start : in std_logic;
			o_rd_done : out std_logic;
			i_wr_data_available : in std_logic;
			i_wr_data : in std_logic_vector(7 downto 0);
			o_wr_data_strobe : out std_logic;
			i_wr_start : in std_logic;
			o_wr_done : out std_logic;
			io_i2c_scl : inout std_logic;
			io_i2c_sda : inout std_logic
		);
	end component;

	component cpt_iobus_sccb is
		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_iobus_mosi : in typ_mcu_iobus_mosi;
			o_iobus_miso : out typ_mcu_iobus_miso;
			i_dev_addr : in std_logic_vector(6 downto 0);
			i_scl_clk_div : in integer;
			io_scl : inout std_logic;
			io_sda : inout std_logic
		);
	end component;

	-- Microblaze core with custom peripherals
	component cpt_mcu is
		generic (
			INCLUDE_IOBUS_MPORT : string := "TRUE";
			INCLUDE_SCCB : string := "TRUE"
		);
		port (
			i_clk : in std_logic;
			i_reset : in std_logic;
			
			o_debug_output_enable : out std_logic;
			o_debug_src : out integer range 0 to 15;
			
			i_mctl_mport_mosi : in typ_mctl_mport_mosi;
			o_mctl_mport_miso : out typ_mctl_mport_miso;
			
			io_ovm0_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm0_sccb_mosi : out typ_ovm_sccb_mosi;
			io_ovm1_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm1_sccb_mosi : out typ_ovm_sccb_mosi;
			io_ovm2_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm2_sccb_mosi : out typ_ovm_sccb_mosi;
			io_ovm3_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm3_sccb_mosi : out typ_ovm_sccb_mosi;
			
			i_uart_rx : in std_logic := '1';
			o_uart_tx : out std_logic := '1';
			
			o_wifi_txd : inout std_logic;
			io_wifi_rxd : inout std_logic;
			o_wifi_rst : out std_logic;
			io_wifi_gpio0 : inout std_logic;
			io_wifi_gpio2 : inout std_logic;
			o_wifi_ch_pd : out std_logic;
					
			o_usb_data : out std_logic_vector(7 downto 0);
			i_usb_data : in std_logic_vector(7 downto 0);
			i_usb_ctrl_miso : in typ_usb_ctrl_miso;
			o_usb_ctrl_mosi : out typ_usb_ctrl_mosi;
		
--			i_gp1i : in std_logic_vector(31 downto 0);
--			i_gp2i : in std_logic_vector(31 downto 0);
--			i_gp3i : in std_logic_vector(31 downto 0);
--			i_gp4i : in std_logic_vector(31 downto 0);
--			o_gp1o : out std_logic_vector(31 downto 0);
--			o_gp2o : out std_logic_vector(31 downto 0);
--			o_gp3o : out std_logic_vector(31 downto 0);
--			o_gp4o : out std_logic_vector(31 downto 0);
			
			i_gpi : in typ_mcu_word_array;
			o_gpo : out typ_mcu_word_array;
			
			i_intc_interrupt : in std_logic_vector(7 downto 0);
			o_intc_irq : out std_logic_vector(31 downto 0)
		);
	end component;

	component cpt_timer is
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
	end component;	
		
	component cpt_counter is
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
	end component;

	component cpt_gpio is
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
	end component;

	component cpt_sccb_master is
		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_iobus_mosi : in typ_mcu_iobus_mosi;
			o_iobus_miso : out typ_mcu_iobus_miso;
			i_scl_div : in integer;
			io_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_sccb_mosi : out typ_ovm_sccb_mosi
		);
	end component;
end pkg_mcu;

package body pkg_mcu is

end pkg_mcu;
