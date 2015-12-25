
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.ALL;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library mctl;
use mctl.pkg_mctl.all;

library ovm;
use ovm.pkg_ovm.all;

--library wifi;
--use wifi.pkg_wifi.all;

library mcu;
use mcu.pkg_mcu.all;

library fast_uart;
use fast_uart.pkg_fast_uart.all;

library usb;
use usb.pkg_usb.all;

library util;
use util.pkg_util.all;


entity cpt_mcu is
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
	
		i_gpi : in typ_mcu_word_array;
		o_gpo : out typ_mcu_word_array;
		
		i_intc_interrupt : in std_logic_vector(7 downto 0);
		o_intc_irq : out std_logic_vector(31 downto 0)
	);
end cpt_mcu;

architecture Behavioral of cpt_mcu is

	signal gpi : typ_mcu_word_array;
	signal gpo : typ_mcu_word_array;

	signal iobus_device_id : std_logic_vector(31 downto 0) := x"00000000";
	
	signal iobus_mosi : typ_mcu_iobus_mosi;
	signal iobus_miso : typ_mcu_iobus_miso;

	constant IOBUS_DEVICE_ID_MASK : std_logic_vector(31 downto 0) := x"FC000000";
	
	-- These set the base addresses for IO bus devices
	constant NULL_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"00000000";
	constant MPORT_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"C0000000";
	constant TIMER_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"D0000000";
	constant COUNTER_DEVICE_ID : std_logic_vector(31 downto 0) := x"D4000000";
	constant GPIO_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"D8000000";
	constant USB_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"DC000000";
	constant OVM0_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"E0000000";
	constant OVM1_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"E4000000";
	constant OVM2_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"E8000000";
	constant OVM3_DEVICE_ID 	: std_logic_vector(31 downto 0) := x"EC000000";
	constant UART_TX_DEVICE_ID	: std_logic_vector(31 downto 0) := x"F0000000";
	constant UART_RX_DEVICE_ID	: std_logic_vector(31 downto 0) := x"F4000000";
	constant WIFI_TX_DEVICE_ID	: std_logic_vector(31 downto 0) := x"F8000000";
	constant WIFI_RX_DEVICE_ID	: std_logic_vector(31 downto 0) := x"FC000000";

	signal mport_iobus_miso : typ_mcu_iobus_miso;
	signal timer_iobus_miso : typ_mcu_iobus_miso;
	signal counter_iobus_miso : typ_mcu_iobus_miso;
	signal gpio_iobus_miso : typ_mcu_iobus_miso;
	signal usb_iobus_miso : typ_mcu_iobus_miso;
	signal ovm0_iobus_miso : typ_mcu_iobus_miso;
	signal ovm1_iobus_miso : typ_mcu_iobus_miso;
	signal ovm2_iobus_miso : typ_mcu_iobus_miso;
	signal ovm3_iobus_miso : typ_mcu_iobus_miso;
	signal uart_tx_iobus_miso : typ_mcu_iobus_miso;
	signal uart_rx_iobus_miso : typ_mcu_iobus_miso;
	signal wifi_tx_iobus_miso : typ_mcu_iobus_miso;
	signal wifi_rx_iobus_miso : typ_mcu_iobus_miso;
	
	
	signal wifi_rxd_oe_n : std_logic;
	signal wifi_rxd_o : std_logic;
	signal wifi_rxd_i : std_logic;
	
	signal wifi_gpio_oe_n : std_logic_vector(2 downto 0);
	signal wifi_gpo : std_logic_vector(2 downto 0);
	signal wifi_gpi : std_logic_vector(2 downto 0);
	
	signal debug_output_enable : std_logic;
	signal debug_src : integer range 0 to 15;
	
	signal debug_ovm0_enable : std_logic;
	signal ovm0_enable : std_logic;
	signal ovm1_enable : std_logic;
	signal ovm2_enable : std_logic;
	signal ovm3_enable : std_logic;
	
	signal ovm_scl_clk_div : integer;
	signal ovm_xvclk_div : integer;
	signal ovm_dev_addr : std_logic_vector(6 downto 0);
	
			
	signal uart_txd : std_logic;
	signal uart_rxd : std_logic;
		
	signal uart_tx_full : std_logic;
	signal uart_tx_empty : std_logic;
	signal uart_rx_full : std_logic;
	signal uart_rx_empty : std_logic;
	signal uart_rx_empty_n : std_logic;
	
	signal uart_rx_src : std_logic;
	signal uart_tx_src : std_logic;
	
	signal uart_baud_div : integer;
	
	
	signal wifi_txd : std_logic;
	signal wifi_rxd : std_logic;
		
	signal wifi_tx_full : std_logic;
	signal wifi_tx_empty : std_logic;
	signal wifi_rx_full : std_logic;
	signal wifi_rx_empty : std_logic;
	signal wifi_rx_empty_n : std_logic;
	
	signal wifi_rx_src : std_logic;
	signal wifi_tx_src : std_logic;
	
		
	signal wifi_enable : std_logic_vector(1 downto 0);
	signal wifi_baud_div : integer;
	
	signal usb_rx_empty_n : std_logic;
	
	constant MCU_FREQUENCY : integer := 108000000; -- 108 MHz
	
	
begin


	microblaze : cpt_microblaze
	port map (
		Clk => i_clk,
		Reset => i_reset,
		IO_Addr_Strobe => iobus_mosi.addr_strobe,
		IO_Read_Strobe => iobus_mosi.read_strobe,
		IO_Write_Strobe => iobus_mosi.write_strobe,
		IO_Address => iobus_mosi.address,
		IO_Byte_Enable => iobus_mosi.byte_enable,
		IO_Write_Data => iobus_mosi.write_data,
		IO_Read_Data => iobus_miso.read_data,
		IO_Ready => iobus_miso.ready,
		UART_Rx => '1',
		UART_Tx => open,
		UART_Interrupt => open,
		GPO1 => open,
		GPO2 => open,
		GPO3 => open,
		GPO4 => open,
		GPI1 => (others => '0'),
		GPI1_Interrupt => open,
		GPI2 => (others => '0'),
		GPI2_Interrupt => open,
		GPI3 => (others => '0'),
		GPI3_Interrupt => open,
		GPI4 => (others => '0'),
		GPI4_Interrupt => open,
		INTC_Interrupt(0) => i_intc_interrupt(0),
		INTC_Interrupt(1) => uart_rx_empty_n,
		INTC_Interrupt(2) => wifi_rx_empty_n,
		INTC_Interrupt(3) => usb_rx_empty_n,
		INTC_Interrupt(7 downto 4) => i_intc_interrupt(7 downto 4),
		INTC_IRQ => open
	);
		
	usb_rx_empty_n <= not i_usb_ctrl_miso.rxf_n;
	
	
	process(i_clk)
	begin	
		if ( rising_edge(i_clk) ) then 
			if ( iobus_mosi.addr_strobe = '1' and iobus_mosi.address(31 downto 30) = "11" ) then				
				iobus_device_id <= iobus_mosi.address and IOBUS_DEVICE_ID_MASK;
			elsif ( iobus_miso.ready = '1' ) then				
				iobus_device_id <= NULL_DEVICE_ID and IOBUS_DEVICE_ID_MASK;
			end if;
		end if;
	end process;




	with iobus_device_id select 
		iobus_miso <= 	mport_iobus_miso when MPORT_DEVICE_ID,
							timer_iobus_miso when TIMER_DEVICE_ID,
							counter_iobus_miso when COUNTER_DEVICE_ID,
							gpio_iobus_miso when GPIO_DEVICE_ID,
							usb_iobus_miso when USB_DEVICE_ID,
							ovm0_iobus_miso when OVM0_DEVICE_ID,
							ovm1_iobus_miso when OVM1_DEVICE_ID,
							ovm2_iobus_miso when OVM2_DEVICE_ID,
							ovm3_iobus_miso when OVM3_DEVICE_ID,
							uart_tx_iobus_miso when UART_TX_DEVICE_ID,
							uart_rx_iobus_miso when UART_RX_DEVICE_ID,
							wifi_tx_iobus_miso when WIFI_TX_DEVICE_ID,
							wifi_rx_iobus_miso when WIFI_RX_DEVICE_ID,
							init_mcu_iobus_miso when others;
		
				
		
		
		
		
		
	incl_iobus_mport :
	if ( INCLUDE_IOBUS_MPORT = "TRUE" ) generate
	
		iobus_mport : cpt_iobus_mport
		generic map (
			DEVICE_ID => MPORT_DEVICE_ID,
			DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
		)	
		port map (
			i_clk => i_clk,				
			i_mcu_iobus_mosi => iobus_mosi,
			o_mcu_iobus_miso => mport_iobus_miso,
			i_mctl_mport_mosi => i_mctl_mport_mosi,
			o_mctl_mport_miso =>  o_mctl_mport_miso
		);
	
	end generate incl_iobus_mport;
	
	
	
	
	timer : cpt_timer
	generic map (
		DEVICE_ID => TIMER_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK,
		MCU_FREQUENCY => MCU_FREQUENCY
	)
	port map (
		i_clk => i_clk,				
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => timer_iobus_miso
	);
	

	counter : cpt_counter
	generic map (
		DEVICE_ID => COUNTER_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK,
		MCU_FREQUENCY => MCU_FREQUENCY
	)
	port map (
		i_clk => i_clk,				
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => counter_iobus_miso
	);
	
	
	--gpi <= gpo;
	
	gpi(0 to 16#80#-1) <= i_gpi(0 to 16#80#-1);
	o_gpo(0 to 16#80#-1) <= gpo(0 to 16#80#-1);
	
	
	gpio : cpt_gpio
	generic map (
		DEVICE_ID => GPIO_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK,
		N_GPIOS => N_GPIOS
	)
	port map (
		i_clk => i_clk,	
		i_reset => i_reset,
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => gpio_iobus_miso,
		i_gpi => gpi,
		o_gpo => gpo
	);

	
	uart_baud_div <= conv_integer(gpo(GPIO_UART_BAUD_DIV));
		
		
	gpi(GPIO_UART_STATUS) <= ( 
		0 => uart_rx_empty, 
		1 => uart_rx_full, 
		2 => i_uart_rx,
		4 => uart_tx_empty,
		5 => uart_tx_full,  
		others => '0' 
	);
		
	
	fast_uart_tx : cpt_fast_uart_tx
	generic map (
		DEVICE_ID => UART_TX_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
	)
	port map (
		clk => i_clk,
		reset => i_reset,
		enable => '1',
		baud_div => uart_baud_div,	
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => uart_tx_iobus_miso,
		empty => uart_tx_empty,
		full => uart_tx_full,
		txd => uart_txd
	);
	
	
	
	
	
	uart_tx_src <= gpo(GPIO_UART_TX_SRC)(0);
	
	with uart_tx_src select o_uart_tx <= 
		uart_txd when '0',
		wifi_rxd_i when '1';
		
		
	wifi_tx_src <= gpo(GPIO_WIFI_TX_SRC)(0);	
	
	with wifi_tx_src select o_wifi_txd <= 
		wifi_txd when '0',
		i_uart_rx when '1';
		
		
		
	
	uart_rx_src <= gpo(GPIO_UART_RX_SRC)(0);
	
	with uart_rx_src select uart_rxd <= 
		i_uart_rx when '0',
		uart_txd when '1'; --loopback
	
	
	uart_rx_empty_n <= not uart_rx_empty;
	
	fast_uart_rx : cpt_fast_uart_rx
	generic map (
		DEVICE_ID => UART_RX_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
	)
	port map (
		clk => i_clk,
		reset => i_reset,
		enable => '1',
		baud_div => uart_baud_div,	
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => uart_rx_iobus_miso,
		full => uart_rx_full,
		empty => uart_rx_empty,
		rxd => uart_rxd
	);		
	
	
	
	wifi_baud_div <= conv_integer(gpo(GPIO_WIFI_BAUD_DIV));
		
		
	gpi(GPIO_WIFI_STATUS) <= ( 
		0 => wifi_rx_empty, 
		1 => wifi_rx_full, 
		2 => wifi_rxd_i,
		4 => wifi_tx_empty,
		5 => wifi_tx_full, 
		others => '0' 
	);
		
	
	wifi_tx : cpt_fast_uart_tx
	generic map (
		DEVICE_ID => WIFI_TX_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
	)
	port map (
		clk => i_clk,
		reset => i_reset,
		enable => '1',
		baud_div => wifi_baud_div,	
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => wifi_tx_iobus_miso,
		empty => wifi_tx_empty,
		full => wifi_tx_full,
		txd => wifi_txd
	);
	
	
	wifi_enable <= gpo(GPIO_WIFI_ENABLE)(1 downto 0);
	
	--o_wifi_txd <= wifi_txd;
	o_wifi_rst <= wifi_enable(0);
	o_wifi_ch_pd <= wifi_enable(1);
	
	
	
	
	wifi_rxd_oe_n <= not gpo(GPIO_WIFI_RXD_OUTPUT_ENABLE)(0);
	wifi_rxd_o <= gpo(GPIO_WIFI_RXD)(0);
	gpi(GPIO_WIFI_RXD)(0) <= wifi_rxd_i;
	
	wifi_rxd_iobuf : iobuf
	port map (
		io => io_wifi_rxd,
		i => wifi_rxd_o,
		o => wifi_rxd_i,
		t => wifi_rxd_oe_n
	);
	
	
	wifi_gpio_oe_n <= not gpo(GPIO_WIFI_GPIO_OUTPUT_ENABLE)(2 downto 0);
	wifi_gpo <= gpo(GPIO_WIFI_GPIO)(2 downto 0);
	gpi(GPIO_WIFI_GPIO)(2 downto 0) <= wifi_gpi;
	
	
	wifi_gpio0_iobuf : iobuf
	port map (
		io => io_wifi_gpio0,
		i => wifi_gpo(0),
		o => wifi_gpi(0),
		t => wifi_gpio_oe_n(0)
	);
	
	wifi_gpio2_iobuf : iobuf
	port map (
		io => io_wifi_gpio2,
		i => wifi_gpo(2),
		o => wifi_gpi(2),
		t => wifi_gpio_oe_n(2)
	);
	
	
	wifi_rx_src <= gpo(GPIO_WIFI_RX_SRC)(0);
	
	with wifi_rx_src select wifi_rxd <= 
		wifi_rxd_i when '0',
		wifi_txd when '1';	-- loopback
	
	
	wifi_rx_empty_n <= not wifi_rx_empty;
	
	wifi_rx : cpt_fast_uart_rx
	generic map (
		DEVICE_ID => wifi_RX_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
	)
	port map (
		clk => i_clk,
		reset => i_reset,
		enable => '1',
		baud_div => wifi_baud_div,	
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => wifi_rx_iobus_miso,
		full => wifi_rx_full,
		empty => wifi_rx_empty,
		rxd => wifi_rxd
	);		
	
	
	
	
	
	debug_output_enable <= gpo(GPIO_DEBUG_OUTPUT_ENABLE)(0);
	o_debug_output_enable <= debug_output_enable;
	
--	debug_src <= conv_integer(gpo(GPIO_DEBUG_SRC));
--	o_debug_src <= debug_src;
	
	
	ovm0_enable <= gpo(GPIO_OVM_ENABLE)(0);
	debug_ovm0_enable <= '0' when debug_output_enable = '1' else ovm0_enable;	
	
	ovm1_enable <= gpo(GPIO_OVM_ENABLE)(1);
	ovm2_enable <= gpo(GPIO_OVM_ENABLE)(2);
	ovm3_enable <= gpo(GPIO_OVM_ENABLE)(3);
		
	gpi(GPIO_OVM_ENABLE) <= gpo(GPIO_OVM_ENABLE);
		
	ovm_dev_addr <= gpo(GPIO_OVM_DEV_ADDR)(6 downto 0);
	
	ovm_xvclk_div <= conv_integer(gpo(GPIO_OVM_XVCLK_DIV));	
	
	ovm_scl_clk_div <= conv_integer(gpo(GPIO_OVM_SCL_CLK_DIV));	
	
	
	incl_sccb :
	if ( INCLUDE_SCCB = "TRUE" ) generate		
			
			
		o_ovm0_sccb_mosi.pwdn <= not debug_ovm0_enable;
	
		ovm0_xvclk_clkout : cpt_clkout
		port map (
			i_enable => debug_ovm0_enable,
			i_clk => i_clk,
			i_clk_div => ovm_xvclk_div,
			o_clk => o_ovm0_sccb_mosi.xvclk
		);		
			
		ovm0_iobus_sccb : cpt_iobus_sccb
		generic map (
			DEVICE_ID => OVM0_DEVICE_ID,
			DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
		)
		port map (
			i_clk => i_clk,
			i_enable => debug_ovm0_enable,			
			i_iobus_mosi => iobus_mosi,
			o_iobus_miso => ovm0_iobus_miso,			
			i_dev_addr => ovm_dev_addr,	
			i_scl_clk_div => ovm_scl_clk_div,			
			io_scl => io_ovm0_sccb_bidir.scl,
			io_sda => io_ovm0_sccb_bidir.sda
		);
			
			
			
			
		o_ovm1_sccb_mosi.pwdn <= not ovm1_enable;
	
		ovm1_xvclk_clkout : cpt_clkout
		port map (
			i_enable => ovm1_enable,
			i_clk => i_clk,
			i_clk_div => ovm_xvclk_div,
			o_clk => o_ovm1_sccb_mosi.xvclk
		);		
				
		ovm1_iobus_sccb : cpt_iobus_sccb
		generic map (
			DEVICE_ID => OVM1_DEVICE_ID,
			DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
		)
		port map (
			i_clk => i_clk,
			i_enable => ovm1_enable,			
			i_iobus_mosi => iobus_mosi,
			o_iobus_miso => ovm1_iobus_miso,			
			i_dev_addr => ovm_dev_addr,	
			i_scl_clk_div => ovm_scl_clk_div,			
			io_scl => io_ovm1_sccb_bidir.scl,
			io_sda => io_ovm1_sccb_bidir.sda
		);
			
		
		o_ovm2_sccb_mosi.pwdn <= not ovm2_enable;
	
		ovm2_xvclk_clkout : cpt_clkout
		port map (
			i_enable => ovm2_enable,
			i_clk => i_clk,
			i_clk_div => ovm_xvclk_div,
			o_clk => o_ovm2_sccb_mosi.xvclk
		);		
		
		ovm2_iobus_sccb : cpt_iobus_sccb
		generic map (
			DEVICE_ID => OVM2_DEVICE_ID,
			DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
		)
		port map (
			i_clk => i_clk,
			i_enable => ovm2_enable,			
			i_iobus_mosi => iobus_mosi,
			o_iobus_miso => ovm2_iobus_miso,			
			i_dev_addr => ovm_dev_addr,	
			i_scl_clk_div => ovm_scl_clk_div,			
			io_scl => io_ovm2_sccb_bidir.scl,
			io_sda => io_ovm2_sccb_bidir.sda
		);
		
		
		o_ovm3_sccb_mosi.pwdn <= not ovm3_enable;
	
		ovm3_xvclk_clkout : cpt_clkout
		port map (
			i_enable => ovm3_enable,
			i_clk => i_clk,
			i_clk_div => ovm_xvclk_div,
			o_clk => o_ovm3_sccb_mosi.xvclk
		);		
		
		ovm3_iobus_sccb : cpt_iobus_sccb
		generic map (
			DEVICE_ID => OVM3_DEVICE_ID,
			DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
		)
		port map (
			i_clk => i_clk,
			i_enable => ovm3_enable,			
			i_iobus_mosi => iobus_mosi,
			o_iobus_miso => ovm3_iobus_miso,			
			i_dev_addr => ovm_dev_addr,
			i_scl_clk_div => ovm_scl_clk_div,			
			io_scl => io_ovm3_sccb_bidir.scl,
			io_sda => io_ovm3_sccb_bidir.sda
		);
	
		
	end generate incl_sccb;
	
	
	
	gpi(GPIO_USB_STATUS)(0) <= i_usb_ctrl_miso.rxf_n;
	gpi(GPIO_USB_STATUS)(1) <= i_usb_ctrl_miso.txe_n;	
	
	
	iobus_usb : cpt_iobus_usb
	generic map (
		DEVICE_ID => USB_DEVICE_ID,
		DEVICE_ID_MASK => IOBUS_DEVICE_ID_MASK
	)	
	port map (
		i_clk => i_clk,				
		i_mcu_iobus_mosi => iobus_mosi,
		o_mcu_iobus_miso => usb_iobus_miso,		
		i_usb_data => i_usb_data,		
		o_usb_data => o_usb_data,		
		i_usb_ctrl_miso => i_usb_ctrl_miso,
		o_usb_ctrl_mosi =>  o_usb_ctrl_mosi
	);
	

end Behavioral;

