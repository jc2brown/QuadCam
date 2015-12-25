
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


library mcu;
use mcu.pkg_mcu.all;

library mctl;
use mctl.pkg_mctl.all;

library mctl_test;
use mctl_test.pkg_mctl_test.all;

library ovm;
use ovm.pkg_ovm.all;

library usb;
use usb.pkg_usb.all;

library vga;
use vga.pkg_vga.all;

library leds;
use leds.pkg_leds.all;

library util;
use util.pkg_util.all;


entity top_quadcam is
	generic (
		-- Flag to indicate simulation or hardware
		-- Set true in testbenches only, and false everywhere else
		C3_SIMULATION : string := "FALSE"; 
		
		
		--------------------------------------------------- 
		-- Design parameters for hardware implementation 
		---------------------------------------------------
		
		-- Duration to stay in reset on startup, in seconds
		-- External RAM requires 200us min.
		STARTUP_RESET_DUR : real := 200.0e-6;
		
		-- Master oscillator frequency, in Hz
		SYSTEM_CLOCK_FREQ : real := 24.0e6;
		
		
		--------------------------------------------------- 
		-- Features to include in hardware implementation 
		---------------------------------------------------
		
		

		-- Microcontroller
		INCLUDE_MCU : string := "TRUE";
		
		-- RAM controller
		INCLUDE_MCTL : string := "TRUE";
		
		-- RAM<-->MCU link
		INCLUDE_IOBUS_MPORT : string := "TRUE";
		
		-- Camera control bus
		INCLUDE_SCCB : string := "TRUE";
		
		-- Camera controller
		INCLUDE_CCTL : string := "TRUE";
		
		-- FTDI USB
		INCLUDE_USB : string := "TRUE";
		
		-- Video output 
		INCLUDE_VGA : string := "TRUE";
		
		-- Video test patterns 
		INCLUDE_VGA_TEST : string := "TRUE"
		
	);
	port (
		--o_ram_error : out std_logic;
		o_mcu_uart_tx : out std_logic;
		i_mcu_uart_rx : in std_logic;
		--o_calib_done : out std_logic;
		--o_error : out std_logic;
		i_clk_24m : in std_logic;
		
		o_error_led_n : out std_logic;
		--i_reset : in  std_logic;
		
		o_led_addr : out std_logic_vector(2 downto 0);
		
		
		i_switch1 : in std_logic;
		i_switch2 : in std_logic;
		
		mcb3_rzq : inout std_logic;
		mcb3_cs_n : out std_logic;
		
		mctl_ram_bidir : inout typ_mctl_ram_bidir;
		mctl_ram_mosi : out typ_mctl_ram_mosi;
		
		i_ovm0_video_miso : in typ_ovm_video_miso;
		io_ovm0_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_ovm0_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm1_video_miso : in typ_ovm_video_miso;
		io_ovm1_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_ovm1_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm2_video_miso : in typ_ovm_video_miso;
		io_ovm2_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_ovm2_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm3_video_miso : in typ_ovm_video_miso;
		io_ovm3_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_ovm3_sccb_mosi : out typ_ovm_sccb_mosi;
		
		o_vga_mosi : out typ_vga_mosi := init_vga_mosi;
		
		i_usb_ctrl_miso : in typ_usb_ctrl_miso;
		o_usb_ctrl_mosi : out typ_usb_ctrl_mosi;
		io_usb_data : inout std_logic_vector(7 downto 0);
		
		o_wifi_txd : out std_logic;
		io_wifi_rxd : inout std_logic;
		o_wifi_rst : out std_logic;
		io_wifi_gpio0 : inout std_logic;
		io_wifi_gpio2 : inout std_logic;
		o_wifi_ch_pd : out std_logic
		
--		o_dummy_bank0_topright : out std_logic;
--		o_dummy_bank0_topleft : out std_logic;
--		o_dummy_bank1_righttop : out std_logic;
--		o_dummy_bank1_rightbottom : out std_logic;
--		o_dummy_bank2_bottomleft : out std_logic;
--		o_dummy_bank2_bottomright : out std_logic;
--		o_dummy_bank3_lefttop : out std_logic;
--		o_dummy_bank3_leftbottom : out std_logic
	);
end top_quadcam;

architecture arch of top_quadcam is




	 
	 
	 
	 
-- ========================================================================== --
-- Signal Declarations                                                        --
-- ========================================================================== --

	signal clk_24m : std_logic := '0';

	--signal ovm0_video_miso : typ_ovm_video_miso;
	--signal ovm0_sccb_bidir : typ_ovm_sccb_bidir;
	--signal ovm0_sccb_mosi : typ_ovm_sccb_mosi;
	
	
	
--	signal debug_data : std_logic_vector(7 downto 0);
--	signal debug_href : std_logic;
--	signal debug_vsync : std_logic;
--	signal debug_scl : std_logic;
--	--signal debug_sda : std_logic;
--	signal debug_pclk : std_logic;
--	
--	signal debug0_data : std_logic_vector(7 downto 0);
--	signal debug1_data : std_logic_vector(7 downto 0);
--	signal debug2_data : std_logic_vector(7 downto 0);
--	signal debug3_data : std_logic_vector(7 downto 0);
--	signal debug4_data : std_logic_vector(7 downto 0);
--	signal debug5_data : std_logic_vector(7 downto 0);
--	signal debug6_data : std_logic_vector(7 downto 0);
--	signal debug7_data : std_logic_vector(7 downto 0);
--	signal debug8_data : std_logic_vector(7 downto 0);
--	signal debug9_data : std_logic_vector(7 downto 0);
--	signal debugA_data : std_logic_vector(7 downto 0);
--	signal debugB_data : std_logic_vector(7 downto 0);
--	signal debugC_data : std_logic_vector(7 downto 0);
--	signal debugD_data : std_logic_vector(7 downto 0);
--	signal debugE_data : std_logic_vector(7 downto 0);
--	signal debugF_data : std_logic_vector(7 downto 0);
--	signal debug_hrefs : std_logic_vector(15 downto 0);
--	signal debug_vsyncs : std_logic_vector(15 downto 0);
--	signal debug_scls : std_logic_vector(15 downto 0);
--	--signal debug_sda : std_logic;
--	signal debug_pclks : std_logic_vector(15 downto 0);
--	
--	signal debug_output_enable : std_logic;
--	signal debug_output_enable_n : std_logic;
--
--	signal debug_src : integer range 0 to 15;
--
--	signal debug : std_logic_vector(31 downto 0);
--	
--	signal probe_src : integer range 0 to 15;
--	signal probe_latch_div : integer;
--	signal probe_latch_pgate : std_logic;
--	
--	signal probe_value : std_logic;
--	--signal probe_value_n : std_logic;
--	
--	signal probe_value_gated_n : std_logic;
--	signal probe_value_gated_p : std_logic;	
--	
--	signal probe_enable : std_logic;
--	signal probe_enable_n : std_logic;
--	
--	signal probe_clear : std_logic;	
--	
--	signal probe_low_count : integer;
--	signal probe_high_count : integer;
	
	signal ovm0_vsync_d1 : std_logic;
	signal ovm0_vsync_d2 : std_logic;
	
	signal ovm1_vsync_d1 : std_logic;
	signal ovm1_vsync_d2 : std_logic;
	
	signal ovm2_vsync_d1 : std_logic;
	signal ovm2_vsync_d2 : std_logic;
	
	signal ovm3_vsync_d1 : std_logic;
	signal ovm3_vsync_d2 : std_logic;



	signal ovm0_video_miso : typ_ovm_video_miso;
--	signal ovm1_sccb_bidir : typ_ovm_sccb_bidir;
	signal ovm0_sccb_mosi : typ_ovm_sccb_mosi;

	signal ovm1_video_miso : typ_ovm_video_miso;
--	signal ovm1_sccb_bidir : typ_ovm_sccb_bidir;
	signal ovm1_sccb_mosi : typ_ovm_sccb_mosi;
		
	signal ovm2_video_miso : typ_ovm_video_miso;
--	signal ovm2_sccb_bidir : typ_ovm_sccb_bidir;
	signal ovm2_sccb_mosi : typ_ovm_sccb_mosi;
		
	signal ovm3_video_miso : typ_ovm_video_miso;
--	signal ovm3_sccb_bidir : typ_ovm_sccb_bidir;
	signal ovm3_sccb_mosi : typ_ovm_sccb_mosi;
		
   signal burst_length : std_logic_vector(5 downto 0) := conv_std_logic_vector(15,6);
		
	signal ovm_frame_addr0 : std_logic_vector(28 downto 0) := x"0000000" & "0";
   signal ovm_frame_addr1 : std_logic_vector(28 downto 0) := x"1000000" & "0";
   signal ovm_frame_addr2 : std_logic_vector(28 downto 0) := x"2000000" & "0";
   signal ovm_frame_addr3 : std_logic_vector(28 downto 0) := x"3000000" & "0";
			
	signal vga_frame_addr0 : std_logic_vector(28 downto 0) := x"0000000" & "0";
   signal vga_frame_addr1 : std_logic_vector(28 downto 0) := x"1000000" & "0";
   signal vga_frame_addr2 : std_logic_vector(28 downto 0) := x"2000000" & "0";
   signal vga_frame_addr3 : std_logic_vector(28 downto 0) := x"3000000" & "0";
	
   signal ovm0_line_offset : integer range 0 to 8191 := 0;
   signal ovm1_line_offset : integer range 0 to 8191 := 1024;
   signal ovm2_line_offset : integer range 0 to 8191 := 1024;
   signal ovm3_line_offset : integer range 0 to 8191 := 640;
		

			
	signal usb_frame_addr0 : std_logic_vector(28 downto 0) := x"0000000" & "0";
   signal usb_frame_addr1 : std_logic_vector(28 downto 0) := x"1000000" & "0";
   signal usb_frame_addr2 : std_logic_vector(28 downto 0) := x"2000000" & "0";
   signal usb_frame_addr3 : std_logic_vector(28 downto 0) := x"3000000" & "0";



	signal ovm_mux_enable : std_logic;
	signal ovm_mux_reset : std_logic;	
	signal ovm_bram_enable : std_logic_vector(3 downto 0);	
	
	signal ovm0_bram_reset : std_logic;
   signal ovm0_bram_rd_enable : std_logic := '0';
   signal ovm0_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm0_bram_frame_number : integer range 0 to 3;
   signal ovm0_bram_line_number : integer range 0 to 2047;
   signal ovm0_bram_words_read : integer range 0 to 511;
   signal ovm0_bram_burst_available : std_logic;
	
	signal ovm1_bram_reset : std_logic;
   signal ovm1_bram_rd_enable : std_logic := '0';
   signal ovm1_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm1_bram_frame_number : integer range 0 to 3;
   signal ovm1_bram_line_number : integer range 0 to 2047;
   signal ovm1_bram_words_read : integer range 0 to 511;
   signal ovm1_bram_burst_available : std_logic;
		
	signal ovm2_bram_reset : std_logic;
   signal ovm2_bram_rd_enable : std_logic := '0';
   signal ovm2_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm2_bram_frame_number : integer range 0 to 3;
   signal ovm2_bram_line_number : integer range 0 to 2047;
   signal ovm2_bram_words_read : integer range 0 to 511;
   signal ovm2_bram_burst_available : std_logic;
		
	signal ovm3_bram_reset : std_logic;
   signal ovm3_bram_rd_enable : std_logic := '0';
   signal ovm3_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm3_bram_frame_number : integer range 0 to 3;
   signal ovm3_bram_line_number : integer range 0 to 2047;
   signal ovm3_bram_words_read : integer range 0 to 511;
   signal ovm3_bram_burst_available : std_logic;

   signal o0_collision : std_logic;
   signal o1_collision : std_logic;
   signal o2_collision : std_logic;
   signal o3_collision : std_logic;
		
		
		
	--signal vga_mosi : typ_vga_mosi;
		
		

	signal mcu_gpi : typ_mcu_word_array := (others => (others => '0'));
	signal mcu_gpo : typ_mcu_word_array;
	
	
	
	signal mcu_intc_interrupt : std_logic_vector(7 downto 0);
	signal mcu_intc_irq : std_logic_vector(31 downto 0);

	signal user_reset : std_logic;

	signal ram_status : std_logic_vector(1 downto 0);

	signal  c3_error  : std_logic := '0';
	signal  c3_calib_done : std_logic := '0';
	signal  c3_error_status : std_logic_vector(127 downto 0) := (others => '0'); 

	signal  clk_108m : std_logic := '0';
	signal  clk_108_n : std_logic := '1';

	signal  c3_clk0 : std_logic := '0';
	signal  c3_cmp_error : std_logic := '0'; 
	signal  c3_vio_modify_enable : std_logic := '0';
	signal  c3_vio_data_mode_value : std_logic_vector(2 downto 0) := (others => '0');
	signal  c3_vio_addr_mode_value : std_logic_vector(2 downto 0) := (others => '0');

	
	signal  mctl_test_mport0_enabled : std_logic := '1';
	signal  mctl_test_mport1_enabled : std_logic := '1';
	signal  mctl_test_mport2_enabled : std_logic := '1';
	signal  mctl_test_mport3_enabled : std_logic := '0';
	
	
	signal mctl_test_mport3_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
	signal mctl_test_mport3_miso : typ_mctl_mport_miso := init_mctl_mport_miso;
	
	

	signal  c3_selfrefresh_enter                     : std_logic := '0';
	signal  c3_selfrefresh_mode                      : std_logic := '0';




	-- Memory controller signals
	signal mctl_mport0_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
	signal mctl_mport0_miso : typ_mctl_mport_miso := init_mctl_mport_miso;
	
	signal mctl_mport1_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
	signal mctl_mport1_miso : typ_mctl_mport_miso := init_mctl_mport_miso;
	
	signal mctl_mport2_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
	signal mctl_mport2_miso : typ_mctl_mport_miso := init_mctl_mport_miso;
	
	signal mctl_mport3_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
	signal mctl_mport3_miso : typ_mctl_mport_miso := init_mctl_mport_miso;


	-- UART signals
	signal uart_txd : std_logic;
	signal uart_rxd : std_logic;


	-- WiFi signals
	signal wifi_txd : std_logic;
	--signal wifi_rxd : std_logic;
	signal wifi_rst : std_logic;
	signal wifi_gpio0 : std_logic;
	signal wifi_gpio2 : std_logic;
	signal wifi_ch_pd : std_logic;


	-- LED signals
	signal error_led : std_logic;
	
	signal error_led0 : std_logic;
	signal error_led1 : std_logic;
	signal error_led2 : std_logic;
	signal error_led3 : std_logic;
	
	signal error_led_src : integer range 0 to 3;--std_logic_vector(31 downto 0);
	
	signal leds : std_logic_vector(7 downto 1);
	
	signal leds0 : std_logic_vector(7 downto 1);
	signal leds1 : std_logic_vector(7 downto 1);
	signal leds2 : std_logic_vector(7 downto 1);
	signal leds3 : std_logic_vector(7 downto 1);
	signal leds4 : std_logic_vector(7 downto 1);
	signal leds5 : std_logic_vector(7 downto 1);
	signal leds6 : std_logic_vector(7 downto 1);
	signal leds7 : std_logic_vector(7 downto 1);
	signal leds8 : std_logic_vector(7 downto 1);
	signal leds9 : std_logic_vector(7 downto 1);
	signal ledsA : std_logic_vector(7 downto 1);
	signal ledsB : std_logic_vector(7 downto 1);
	signal ledsC : std_logic_vector(7 downto 1);
	signal ledsD : std_logic_vector(7 downto 1);
	signal ledsE : std_logic_vector(7 downto 1);
	signal ledsF : std_logic_vector(7 downto 1);
	
	signal leds_src : std_logic_vector(31 downto 0);
	
	signal ledclk_div : integer;
	signal led_latch_div : integer;


	-- Flash signals
	signal flash_clk_div : integer;
	signal flash_on : integer;
	signal flash_max : integer;
	signal flash_count : integer;
	signal flash_value : std_logic;
	signal flash_clk_pgate : std_logic;


	-- USB signals

	signal mcu_usb_data_in : std_logic_vector(7 downto 0);	
	signal mcu_usb_data_out : std_logic_vector(7 downto 0);
	signal mcu_usb_ctrl_miso : typ_usb_ctrl_miso;
	signal mcu_usb_ctrl_mosi : typ_usb_ctrl_mosi;
		
	signal usb_enable : std_logic;
	signal usb_mode : std_logic;
	signal usb_burst_length : std_logic_vector(5 downto 0) := "001111";
		
	signal usbclk : std_logic;
	signal usb_fifo_data : std_logic_vector(7 downto 0);
	signal usb_fifo_rd_en : std_logic;
	signal usb_fifo_empty : std_logic;
	
	

	-- VGA signals
	signal vga_mosi_fixed : typ_vga_mosi;
	signal vga_mosi_test : typ_vga_mosi;
	
	signal vga_mport_mosi : typ_mctl_mport_mosi;
	signal vga_mport_miso : typ_mctl_mport_miso;
	
	signal vga_src : integer;

	signal vga_mosi : typ_vga_mosi;
	signal vga_magic : std_logic;
	signal vga_magic_key : std_logic_vector(11 downto 0);
	signal vga_magic_key_match : std_logic;
	
	
	
	signal vga_enable : std_logic;
	
	signal vga_test_mode : std_logic;
	signal vga_test_enable : std_logic;
	
	-- vga
	signal line_start : std_logic;
	signal pixel_number : integer range -2048 to 2047;
	signal line_number : integer range -1024 to 1023;
	signal frame_number : integer range 0 to 3;
	signal linebuf_data : std_logic_vector(15 downto 0);
	signal vga_mid_line_offset : integer range -(2**24) to (2**24)-1 := 0;


	function vector (asi:std_logic) return std_logic_vector is
		variable v : std_logic_vector(0 downto 0);
	begin
		v(0) := asi;
	return(v);
	end function vector;


	function or_slv (v:std_logic_vector) return std_logic is
		variable o : std_logic;
	begin
		o := '0';
		for i in v'range loop
			o := o or v(i);
		end loop;
	return o;
	end function; 


	-- Reset signals
--	signal mcu_reset_d : std_logic_vector(7 downto 0) := (others => '0');
	signal reset : std_logic := '1';
	signal reset_n : std_logic := '0';
	signal reset_long : std_logic := '1';
	signal reset_long_n : std_logic := '0';
	
	signal switch1 : std_logic;
	signal sys_switch1 : std_logic;
	signal mcu_switch1 : std_logic;
	signal switch1_src : std_logic;
	
	signal switch2 : std_logic;
	signal sys_switch2 : std_logic;
	signal mcu_switch2 : std_logic;
	signal switch2_src : std_logic;
	
	
begin

	i_clk_24m_ibufg : ibufg
	port map (
		I  => i_clk_24m,
		O  => clk_24m
	);

	mcb3_cs_n <= '0';
	user_reset <= sys_switch2;	-- Physical SW2 on board

	
--	process(c3_clk0)
--	begin
--		if ( rising_edge(c3_clk0) ) then
--			mcu_reset_d <= mcu_reset_d(6 downto 0) & mcu_gpo(GPIO_RESET)(0);
--		end if;
--	end process;
	
	process(clk_24m)
	begin
		if ( rising_edge(clk_24m) ) then
			--if ( user_reset = '1' or mcu_reset_d /= x"00" ) then
			if ( user_reset = '1' ) then
				reset <= '1';
			else 
				reset <= '0';
			end if;
		end if;
	end process;

	-- Reset counter
	-- Holds reset high for the duration specified by STARTUP_RESET_DUR
	reset_counter : cpt_upcounter
	generic map (
		INIT => 1
	)
	port map (
		i_clk => clk_24m, 
		i_enable => reset_long,	-- Self-disable. reset must be initialized to '1'
		i_lowest => 1,
		i_highest => cycles_f(STARTUP_RESET_DUR, SYSTEM_CLOCK_FREQ),
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => open,
		o_carry => reset_long_n
	);


--	reset_long <= '1' when (reset_long_n = '0') or mcu_reset_d /= x"00" else '0';
	reset_long <= '1' when (reset_long_n = '0') else '0';



	-- TODO: create ram_status vector, use here and as LED src
	mcu_gpi(GPIO_RAM_STATUS)(1 downto 0) <= ram_status;



--	debug0_data <= mcu_gpo(GPIO_DEBUG0)(7 downto 0);
--	mcu_gpi(GPIO_DEBUG0)(7 downto 0) <= debug0_data;

--	debug_pclks(0) <= mcu_gpo(GPIO_DEBUG0)(8);
--	mcu_gpi(GPIO_DEBUG0)(8) <= debug_pclks(0);

--	debug_hrefs(0) <= mcu_gpo(GPIO_DEBUG0)(9);
--	mcu_gpi(GPIO_DEBUG0)(9) <= debug_hrefs(0);

--	debug_vsyncs(0) <= mcu_gpo(GPIO_DEBUG0)(10);
--	mcu_gpi(GPIO_DEBUG0)(10) <= debug_vsyncs(0);


	--debug4_data(0) <= wifi_txd;
	--debug4_data(1) <= wifi_rxd;
	--debug4_data(2) <= wifi_ch_pd;
	--debug4_data(3) <= wifi_rst;
	--debug4_data(4) <= io_wifi_gpio0;
	--debug4_data(5) <= io_wifi_gpio2;

	--debug4_data(6) <= uart_txd;
	--debug4_data(7) <= uart_rxd;


--	debug7_data(3 downto 0) <= vga_mosi.red;
--	debug7_data(7 downto 4) <= vga_mosi.green;
--	debug_hrefs(7) <= vga_mosi.hsync;
--	debug_vsyncs(7) <= vga_mosi.vsync;
--	
--	debug8_data(3 downto 0) <= vga_mosi.green;
--	debug8_data(7 downto 4) <= vga_mosi.blue;
--	debug_hrefs(8) <= vga_mosi.hsync;
--	debug_vsyncs(8) <= vga_mosi.vsync;
--	
--	debug9_data(3 downto 0) <= vga_mosi.red;
--	debug9_data(7 downto 4) <= vga_mosi.blue;
--	debug_hrefs(9) <= vga_mosi.hsync;
--	debug_vsyncs(9) <= vga_mosi.vsync;
	--debug_scls(9) <= vga_mosi.blue(1);
	--debug_sda(9) <= vga_mosi.blue(0);


--	debugA_data <= ovm0_video_miso.data;
--	debug_pclks(16#A#) <= ovm0_video_miso.pclk;
--	debug_hrefs(16#A#) <= ovm0_video_miso.href;
--	debug_vsyncs(16#A#) <= ovm0_video_miso.vsync;
--	
--	debugB_data <= i_ovm1_video_miso.data;
--	debug_pclks(16#B#) <= i_ovm1_video_miso.pclk;
--	debug_hrefs(16#B#) <= i_ovm1_video_miso.href;
--	debug_vsyncs(16#B#) <= i_ovm1_video_miso.vsync;
--	
--	debugC_data <= i_ovm2_video_miso.data;
--	debug_pclks(16#C#) <= i_ovm2_video_miso.pclk;
--	debug_hrefs(16#C#) <= i_ovm2_video_miso.href;
--	debug_vsyncs(16#C#) <= i_ovm2_video_miso.vsync;
--	
--	debugD_data <= i_ovm3_video_miso.data;
--	debug_pclks(16#D#) <= i_ovm3_video_miso.pclk;
--	debug_hrefs(16#D#) <= i_ovm3_video_miso.href;
--	debug_vsyncs(16#D#) <= i_ovm3_video_miso.vsync;


--	with debug_src select debug_data <= 
--		debug0_data when 16#0#,
--		debug1_data when 16#1#,
--		debug2_data when 16#2#,
--		debug3_data when 16#3#,
--		debug4_data when 16#4#,
--		debug5_data when 16#5#,
--		debug6_data when 16#6#,
--		debug7_data when 16#7#,
--		debug8_data when 16#8#,
--		debug9_data when 16#9#,
--		debugA_data when 16#A#,
--		debugB_data when 16#B#,
--		debugC_data when 16#C#,
--		debugD_data when 16#D#,
--		debugE_data when 16#E#,
--		debugF_data when 16#F#,
--		(others => '1') when others;
--
--
--	debug_pclk <= debug_pclks(debug_src);
--	debug_href <= debug_hrefs(debug_src);
--	debug_vsync <= debug_vsyncs(debug_src);

	-- The MCU can read the debug port via the 
	-- DEBUG register (whether output enabled or not) 
--	debug(7 downto 0) <= debug_data;
--	debug(8) <= debug_pclk;
--	debug(9) <= debug_href;
--	debug(10) <= debug_vsync;
--
--	mcu_gpi(GPIO_DEBUG) <= debug;



--	probe_enable <= mcu_gpo(GPIO_PROBE_ENABLE)(0);
--	mcu_gpi(GPIO_PROBE_ENABLE)(0) <= probe_enable;
--
--	probe_clear <= mcu_gpo(GPIO_PROBE_CLEAR)(0);
--	mcu_gpi(GPIO_PROBE_CLEAR)(0) <= probe_clear;
--
--
--	probe_src <= conv_integer(mcu_gpo(GPIO_PROBE_SRC));
--	mcu_gpi(GPIO_PROBE_SRC) <= conv_std_logic_vector(probe_src, 32);
--
--	probe_latch_div <= conv_integer(mcu_gpo(GPIO_PROBE_LATCH_DIV));
--	mcu_gpi(GPIO_PROBE_SRC) <= conv_std_logic_vector(probe_src, 32);
--
--
--	probe_latch_gate : cpt_clk_gate
--	port map (
--		i_clk => c3_clk0,
--		i_enable => '1',
--		i_div => probe_latch_div,
--		o_clk_pgate => probe_latch_pgate,
--		o_clk_ngate => open
--	);


--	process(c3_clk0)
--	begin
--		if ( rising_edge(c3_clk0) and probe_latch_pgate = '1' ) then
--			probe_value <= debug(probe_src);
--		end if;
--	end process;

--	probe_value <= debug(probe_src);
--
--	probe_value_gated_p <= probe_value and probe_latch_pgate;
--	probe_value_gated_n <= not probe_value and probe_latch_pgate;
--
--
--	probe_low_counter : cpt_upcounter
--	generic map (
--		INIT => 0
--	)
--	port map (
--		i_clk => c3_clk0, 
--		i_enable => probe_value_gated_n,
--		i_lowest => 0,
--		i_highest => 2**30-1,
--		i_increment => 1,
--		i_clear => probe_clear,
--		i_preset => '0',
--		o_count => probe_low_count,
--		o_carry => open
--	);
--
--	process(c3_clk0)
--	begin
--		if ( rising_edge(c3_clk0) ) then
--			mcu_gpi(GPIO_PROBE_LOW) <= conv_std_logic_vector(probe_low_count, 32);
--		end if;
--	end process;
--
--
--	probe_high_counter : cpt_upcounter
--	generic map (
--		INIT => 0
--	)
--	port map (
--		i_clk => c3_clk0, 
--		i_enable => probe_value_gated_p,
--		i_lowest => 0,
--		i_highest => 2**30-1,
--		i_increment => 1,
--		i_clear => probe_clear,
--		i_preset => '0',
--		o_count => probe_high_count,
--		o_carry => open
--	);
--
--
--	process(c3_clk0)
--	begin
--		if ( rising_edge(c3_clk0) ) then
--			mcu_gpi(GPIO_PROBE_HIGH) <= conv_std_logic_vector(probe_high_count, 32);
--		end if;
--	end process;


--	o_debug_ovm0_sccb_mosi.pwdn <= ovm0_sccb_mosi.pwdn;
--	o_debug_ovm0_sccb_mosi.xvclk <= ovm0_sccb_mosi.xvclk; 


	-- TODO: add logic to handle SCL and SDA debug output plus normal I/O
	--o_debug_ovm0_sccb_mosi.scl <= ovm0_sccb_mosi.scl;
	--io_debug_ovm0_sccb_mosi.sda <= debug_sda when debug_output_enable = '1' else ovm0_sccb_bidir.sda;
	--ovm0_sccb_bidir.sda <= io_debug_ovm0_sccb_mosi.sda;


--	debug_output_enable_n <= not debug_output_enable;
--
--
--	gen_debug_data_iobuf :
--	for i in 0 to 7 generate
--	begin
--		debug_data_iobuf : iobuf
--		generic map (
--			drive => 2,
--			iostandard => "lvcmos18",
--			slew => "slow")
--		port map (
--			o => ovm0_video_miso.data(i),
--			io => io_debug_ovm0_video_miso.data(i),
--			i => debug_data(i),
--			t => debug_output_enable_n
--		);
--	end generate;
--
--
--	debug_pclk_iobuf : iobuf
--	generic map (
--		drive => 2,
--		iostandard => "lvcmos18",
--		slew => "slow")
--	port map (
--		o => ovm0_video_miso.pclk,
--		io => io_debug_ovm0_video_miso.pclk,
--		i => debug_pclk,
--		t => debug_output_enable_n
--	);
--
--	debug_href_iobuf : iobuf
--	generic map (
--		drive => 2,
--		iostandard => "lvcmos18",
--		slew => "slow")
--	port map (
--		o => ovm0_video_miso.href,
--		io => io_debug_ovm0_video_miso.href,
--		i => debug_href,
--		t => debug_output_enable_n
--	);
--
--	debug_vsync_iobuf : iobuf
--	generic map (
--		drive => 2,
--		iostandard => "lvcmos18",
--		slew => "slow")
--	port map (
--		o => ovm0_video_miso.vsync,
--		io => io_debug_ovm0_video_miso.vsync,
--		i => debug_vsync,
--		t => debug_output_enable_n
--	);


	ovm0_video_miso <= i_ovm0_video_miso;
	ovm1_video_miso <= i_ovm1_video_miso;
	ovm2_video_miso <= i_ovm2_video_miso;
	ovm3_video_miso <= i_ovm3_video_miso;
	
	-- Using clk_24m because clk_108m stops in reset
	process(clk_24m)
	begin
		if ( rising_edge(clk_24m) ) then
			switch1 <= i_switch1;
			switch2 <= i_switch2;
		end if;
	end process;
	

	
	mcu_gpi(GPIO_SWITCH_STATUS)(0) <= switch1;
	mcu_gpi(GPIO_SWITCH_STATUS)(1) <= switch2;
	
	switch1_src <= mcu_gpo(GPIO_SWITCH_SRC)(0);
	switch2_src <= mcu_gpo(GPIO_SWITCH_SRC)(1);
	
	sys_switch1 <= switch1 when switch1_src = '0' else '0';	
	mcu_switch1 <= switch1 when switch1_src = '1' else '0';	
	
	sys_switch2 <= switch2 when switch2_src = '0' else '0';	
	mcu_switch2 <= switch2 when switch2_src = '1' else '0';
	
	mcu_intc_interrupt(0) <= mcu_switch1 or mcu_switch2;
	mcu_intc_interrupt(1) <= '0';
	mcu_intc_interrupt(2) <= '0';
	mcu_intc_interrupt(3) <= '0';
	
	
	
	process(clk_108m)
	begin
		if ( rising_edge(clk_108m) ) then
			ovm0_vsync_d1 <= i_ovm0_video_miso.vsync;
			ovm0_vsync_d2 <= ovm0_vsync_d1;
		end if;		
	end process;
	
	process(clk_108m)
	begin
		if ( rising_edge(clk_108m) ) then
			ovm1_vsync_d1 <= i_ovm1_video_miso.vsync;
			ovm1_vsync_d2 <= ovm1_vsync_d1;
		end if;		
	end process;	
	
	process(clk_108m)
	begin
		if ( rising_edge(clk_108m) ) then
			ovm2_vsync_d1 <= i_ovm2_video_miso.vsync;
			ovm2_vsync_d2 <= ovm2_vsync_d1;
		end if;		
	end process;	
	
	process(clk_108m)
	begin
		if ( rising_edge(clk_108m) ) then
			ovm3_vsync_d1 <= i_ovm3_video_miso.vsync;
			ovm3_vsync_d2 <= ovm3_vsync_d1;
		end if;		
	end process;
	
	
	mcu_intc_interrupt(4) <= ovm0_vsync_d1 xor ovm0_vsync_d2;
	mcu_intc_interrupt(5) <= ovm1_vsync_d1 xor ovm1_vsync_d2;
	mcu_intc_interrupt(6) <= ovm2_vsync_d1 xor ovm2_vsync_d2;
	mcu_intc_interrupt(7) <= ovm3_vsync_d1 xor ovm3_vsync_d2;


	-- ========================================================================== --
	-- Error LEDs
	-- ========================================================================== --

	o_error_led_n <= not error_led;

	error_led0 <= mcu_gpo(GPIO_ERROR_LED)(0);
	mcu_gpi(GPIO_ERROR_LED) <= mcu_gpo(GPIO_ERROR_LED);

	error_led1 <= flash_value;
	error_led2 <= 
		(not mctl_mport0_mosi.wr.empty) or 
		(not mctl_mport0_mosi.cmd.empty) or 
		(not mctl_mport2_mosi.rd.empty) or
		(not mctl_mport2_mosi.cmd.empty);
	error_led3 <=
			(mctl_mport0_mosi.wr.full) or 
			(mctl_mport0_mosi.cmd.full) or 
			(mctl_mport2_mosi.rd.full) or
			(mctl_mport2_mosi.cmd.full);

	error_led_src <= conv_integer(mcu_gpo(GPIO_ERROR_LED_SRC));
	mcu_gpi(GPIO_ERROR_LED_SRC) <= conv_std_logic_vector(error_led_src, 32);

	with error_led_src select error_led <= 
			error_led0 when 0,
			error_led1 when 1,
			error_led2 when 2,
			error_led3 when 3;


	leds_src <= mcu_gpo(GPIO_LEDS_SRC);
	mcu_gpi(GPIO_LEDS_SRC) <= mcu_gpo(GPIO_LEDS_SRC);

	gen_led_mux :
	for i in 1 to 7 generate
	begin
		with leds_src(4*i+3 downto 4*i) select leds(i) <= 
			leds0(i) when x"0",
			leds1(i) when x"1",
			leds2(i) when x"2",
			leds3(i) when x"3",
			leds4(i) when x"4",
			leds5(i) when x"5",
			leds6(i) when x"6",
			leds7(i) when x"7",
			leds8(i) when x"8",
			leds9(i) when x"9",
			ledsA(i) when x"A",
			ledsB(i) when x"B",
			ledsC(i) when x"C",
			ledsD(i) when x"D",
			ledsE(i) when x"E",
			ledsF(i) when x"F",
			error_led when others;
	end generate;


	leds0 <= (others => '0');

	leds1 <= mcu_gpo(GPIO_LEDS1)(7 downto 1);
	mcu_gpi(GPIO_LEDS1) <= mcu_gpo(GPIO_LEDS1);

	leds2 <= mcu_gpo(GPIO_LEDS2)(7 downto 1);
	mcu_gpi(GPIO_LEDS2) <= mcu_gpo(GPIO_LEDS2);

	leds3(2 downto 1) <= ram_status;

--	leds4(7 downto 1) <= mctl_mport0_mosi.rd.data(7 downto 1);
--	leds5(7 downto 1) <= mctl_mport1_mosi.rd.data(7 downto 1);
--	leds6(7 downto 1) <= mctl_mport2_mosi.rd.data(7 downto 1);
--	leds7(7 downto 1) <= mctl_mport3_mosi.rd.data(7 downto 1);

	leds9 <= (others => flash_value);

--	ledsA(7 downto 1) <= ovm0_video_miso.data(7 downto 1);
--	ledsB(7 downto 1) <= i_ovm1_video_miso.data(7 downto 1);
--	ledsC(7 downto 1) <= i_ovm2_video_miso.data(7 downto 1);
--	ledsD(7 downto 1) <= i_ovm3_video_miso.data(7 downto 1);

	ledsE <= (others => error_led);
	ledsF <= (others => '1');



	flash_clk_div <= conv_integer(mcu_gpo(GPIO_FLASH_CLK_DIV));
	mcu_gpi(GPIO_FLASH_CLK_DIV) <= conv_std_logic_vector(flash_clk_div, 32);

	flash_on <= conv_integer(mcu_gpo(GPIO_FLASH_ON));
	mcu_gpi(GPIO_FLASH_ON) <= conv_std_logic_vector(flash_on, 32);

	flash_max <= conv_integer(mcu_gpo(GPIO_FLASH_MAX));
	mcu_gpi(GPIO_FLASH_MAX) <= conv_std_logic_vector(flash_max, 32);


	flash_clk_gate : cpt_clk_gate
	port map (
		i_clk => c3_clk0,
		i_enable => '1',
		i_div => flash_clk_div,
		o_clk_pgate => flash_clk_pgate,
		o_clk_ngate => open
	);

	-- Generates a periodic pulse with a 32-bit programmable duty cycle
	flash_counter : cpt_upcounter
	generic map (
		INIT => 1
	)
	port map (
		i_clk => c3_clk0,
		i_enable => flash_clk_pgate,
		i_lowest => 0,
		i_highest => flash_max,
		i_increment => 1,
		i_clear => '0',
		i_preset => '0',
		o_count => flash_count,
		o_carry => open
	);

	process(c3_clk0)
	begin
		if ( rising_edge(c3_clk0) ) then
			if ( flash_count <= flash_on ) then
				flash_value <= '1';
			else
				flash_value <= '0';
			end if;
		end if;
	end process;



	o_ovm0_sccb_mosi <= ovm0_sccb_mosi;
	o_ovm1_sccb_mosi <= ovm1_sccb_mosi;
	o_ovm2_sccb_mosi <= ovm2_sccb_mosi;
	o_ovm3_sccb_mosi <= ovm3_sccb_mosi;



	uart_rxd <= i_mcu_uart_rx;
	o_mcu_uart_tx <= uart_txd;


	o_wifi_txd <= wifi_txd;
--	wifi_rxd <= io_wifi_rxd;
--	signal wifi_gpio0 : std_logic;
--	signal wifi_gpio2 : std_logic;
	o_wifi_ch_pd <= wifi_ch_pd;
	o_wifi_rst <= wifi_rst;


	mcu_gpi(GPIO_MCTL_STATUS) <= (
		 0 =>  mctl_mport0_mosi.rd.error,
		 1 =>  mctl_mport0_mosi.rd.overflow,
		 2 =>  mctl_mport0_mosi.wr.error,
		 3 =>  mctl_mport0_mosi.wr.underrun,
		 4 =>  mctl_mport1_mosi.rd.error,
		 5 =>  mctl_mport1_mosi.rd.overflow,
		 6 =>  mctl_mport1_mosi.wr.error,
		 7 =>  mctl_mport1_mosi.wr.underrun,
		 8 =>  mctl_mport2_mosi.rd.error,
		 9 =>  mctl_mport2_mosi.rd.overflow,
		 10 => mctl_mport2_mosi.wr.error,
		 11 => mctl_mport2_mosi.wr.underrun,
		 12 => mctl_mport3_mosi.rd.error,
		 13 => mctl_mport3_mosi.rd.overflow,
		 14 => mctl_mport3_mosi.wr.error,
		 15 => mctl_mport3_mosi.wr.underrun,
		 others => '0'
	);
	
	incl_mcu:
	if ( INCLUDE_MCU = "TRUE" ) generate
	
		mcu : cpt_mcu
		generic map (
			INCLUDE_IOBUS_MPORT => INCLUDE_IOBUS_MPORT,
			INCLUDE_SCCB => INCLUDE_SCCB
		)
		port map (
			i_clk => c3_clk0,
			--i_clk => clk_108m,
			i_reset => reset_long,
			--o_debug_output_enable => debug_output_enable,
			--o_debug_src => debug_src,
			o_debug_output_enable => open,
			o_debug_src => open,
			-- mctl
			i_mctl_mport_mosi => mctl_mport3_mosi,			
			o_mctl_mport_miso => mctl_mport3_miso,
			-- sccb
			io_ovm0_sccb_bidir => io_ovm0_sccb_bidir,
			o_ovm0_sccb_mosi => ovm0_sccb_mosi,
			io_ovm1_sccb_bidir => io_ovm1_sccb_bidir,
			o_ovm1_sccb_mosi => ovm1_sccb_mosi,
			io_ovm2_sccb_bidir => io_ovm2_sccb_bidir,
			o_ovm2_sccb_mosi => ovm2_sccb_mosi,
			io_ovm3_sccb_bidir => io_ovm3_sccb_bidir,
			o_ovm3_sccb_mosi => ovm3_sccb_mosi,
			-- uart
			i_uart_rx => uart_rxd, 
			o_uart_tx => uart_txd,
			-- wifi	
			o_wifi_txd => wifi_txd, 
			io_wifi_rxd => io_wifi_rxd,
			o_wifi_rst => wifi_rst,
			io_wifi_gpio0 => io_wifi_gpio0,
			io_wifi_gpio2 => io_wifi_gpio2,
			o_wifi_ch_pd => wifi_ch_pd,
			-- usb
			o_usb_data => mcu_usb_data_out,
			i_usb_data => mcu_usb_data_in,
			i_usb_ctrl_miso => mcu_usb_ctrl_miso,
			o_usb_ctrl_mosi => mcu_usb_ctrl_mosi,
			-- external gpio
			i_gpi => mcu_gpi,
			o_gpo => mcu_gpo,			
			-- interrupts
			i_intc_interrupt => mcu_intc_interrupt,
			o_intc_irq => mcu_intc_irq
		);
		
	end generate;
	


	ram_status(0) <= c3_error;
	ram_status(1) <= c3_calib_done;	
	
	--c3_clk0 <= clk_108m;
	clk_108m <= c3_clk0;

	incl_mctl:
	if ( INCLUDE_MCTL = "TRUE" ) generate
	
		mctl_wrapper : cpt_mctl_wrapper
		generic map (
			C3_SIMULATION => C3_SIMULATION
		) 
		port map ( 
			c3_sys_clk => clk_24m,
			c3_sys_rst_i => reset,  			
			ram_bidir => mctl_ram_bidir,
			ram_mosi => mctl_ram_mosi,
			c3_clk0 => c3_clk0,	
			--c3_clk0 => open,					
			c3_rst0 => open,
			c3_calib_done => c3_calib_done,
			mcb3_rzq => mcb3_rzq,
			--clk_108m   => clk_108m,
			--clk_108_n => clk_108_n,
			clk_108   => open,
			clk_108_n => open,
			mport0_miso => mctl_mport0_miso,
			mport0_mosi => mctl_mport0_mosi,			
			mport1_miso => mctl_mport1_miso,
			mport1_mosi => mctl_mport1_mosi,		
			mport2_miso => mctl_mport2_miso,
			mport2_mosi => mctl_mport2_mosi,			
			mport3_miso => mctl_mport3_miso,
			mport3_mosi => mctl_mport3_mosi
		);      
	end generate incl_mctl;
	

	mcu_gpi(GPIO_OVM_HREF)(0) <= i_ovm0_video_miso.href;
	mcu_gpi(GPIO_OVM_HREF)(1) <= i_ovm1_video_miso.href;
	mcu_gpi(GPIO_OVM_HREF)(2) <= i_ovm2_video_miso.href;
	mcu_gpi(GPIO_OVM_HREF)(3) <= i_ovm3_video_miso.href;

	mcu_gpi(GPIO_OVM_VSYNC)(0) <= i_ovm0_video_miso.vsync;
	mcu_gpi(GPIO_OVM_VSYNC)(1) <= i_ovm1_video_miso.vsync;
	mcu_gpi(GPIO_OVM_VSYNC)(2) <= i_ovm2_video_miso.vsync;
	mcu_gpi(GPIO_OVM_VSYNC)(3) <= i_ovm3_video_miso.vsync;


	ovm_mux_enable <= mcu_gpo(GPIO_OVM_MUX_ENABLE)(0);
	
	ovm_mux_reset <= not ovm_mux_enable;		

	incl_cctl:
	if ( INCLUDE_CCTL = "TRUE" ) generate
		
		ovm_mux: cpt_ovm_mux PORT MAP (
			 i_clk => c3_clk0,
			 i_reset => ovm_mux_reset,
			 i0_frame_count => ovm0_bram_frame_number,
			 i1_frame_count => ovm1_bram_frame_number,
			 i2_frame_count => ovm2_bram_frame_number,
			 i3_frame_count => ovm3_bram_frame_number,
			 i_frame_addr0 => ovm_frame_addr0,
			 i_frame_addr1 => ovm_frame_addr1,
			 i_frame_addr2 => ovm_frame_addr2,
			 i_frame_addr3 => ovm_frame_addr3,
			 i0_line_offset => ovm0_line_offset,
			 i1_line_offset => ovm1_line_offset,
			 i2_line_offset => ovm2_line_offset,
			 i3_line_offset => ovm3_line_offset,
			 i0_words_read => ovm0_bram_words_read,
			 i1_words_read => ovm1_bram_words_read,
			 i2_words_read => ovm2_bram_words_read,
			 i3_words_read => ovm3_bram_words_read,
			 i0_line_count => ovm0_bram_line_number,
			 i1_line_count => ovm1_bram_line_number,
			 i2_line_count => ovm2_bram_line_number,
			 i3_line_count => ovm3_bram_line_number,
			 i0_rd_data => ovm0_bram_rd_data,
			 i1_rd_data => ovm1_bram_rd_data,
			 i2_rd_data => ovm2_bram_rd_data,
			 i3_rd_data => ovm3_bram_rd_data,
			 i0_burst_available => ovm0_bram_burst_available,
			 i1_burst_available => ovm1_bram_burst_available,
			 i2_burst_available => ovm2_bram_burst_available,
			 i3_burst_available => ovm3_bram_burst_available,
			 o0_rd_enable => ovm0_bram_rd_enable,
			 o1_rd_enable => ovm1_bram_rd_enable,
			 o2_rd_enable => ovm2_bram_rd_enable,
			 o3_rd_enable => ovm3_bram_rd_enable,
			 i_burst_length => burst_length,
			 o_mport_miso => mctl_mport0_miso,
			 i_mport_mosi => mctl_mport0_mosi
		);



		ovm_bram_enable <= mcu_gpo(GPIO_OVM_BRAM_ENABLE)(3 downto 0);

		ovm0_bram_reset <= not ovm_bram_enable(0);
		ovm1_bram_reset <= not ovm_bram_enable(1);
		ovm2_bram_reset <= not ovm_bram_enable(2);
		ovm3_bram_reset <= not ovm_bram_enable(3);
	

		ovm0_bram : cpt_ovm_bram PORT MAP (
			i_pclk => ovm0_video_miso.pclk,
			i_vsync => ovm0_video_miso.vsync,
			i_href => ovm0_video_miso.href,
			i_data => ovm0_video_miso.data,
			i_reset => ovm0_bram_reset,
			o_rd_data => ovm0_bram_rd_data,
			o_frame_number => ovm0_bram_frame_number,
			o_line_number => ovm0_bram_line_number,
			o_words_read => ovm0_bram_words_read,
			i_burst_length => burst_length,
			o_burst_available => ovm0_bram_burst_available,
			o_collision => o0_collision,
			i_clk => c3_clk0,
			i_rd_enable => ovm0_bram_rd_enable
		);

		ovm1_bram : cpt_ovm_bram PORT MAP (
			i_pclk => ovm1_video_miso.pclk,
			i_vsync => ovm1_video_miso.vsync,
			i_href => ovm1_video_miso.href,
			i_data => ovm1_video_miso.data,
			i_reset => ovm1_bram_reset,
			o_rd_data => ovm1_bram_rd_data,
			o_frame_number => ovm1_bram_frame_number,
			o_line_number => ovm1_bram_line_number,
			o_words_read => ovm1_bram_words_read,
			i_burst_length => burst_length,
			o_burst_available => ovm1_bram_burst_available,
			o_collision => o1_collision,
			i_clk => c3_clk0,
			i_rd_enable => ovm1_bram_rd_enable
		);
		
		ovm2_bram : cpt_ovm_bram PORT MAP (
			i_pclk => ovm2_video_miso.pclk,
			i_vsync => ovm2_video_miso.vsync,
			i_href => ovm2_video_miso.href,
			i_data => ovm2_video_miso.data,
			i_reset => ovm2_bram_reset,
			o_rd_data => ovm2_bram_rd_data,
			o_frame_number => ovm2_bram_frame_number,
			o_line_number => ovm2_bram_line_number,
			o_words_read => ovm2_bram_words_read,
			i_burst_length => burst_length,
			o_burst_available => ovm2_bram_burst_available,
			o_collision => o2_collision,
			i_clk => c3_clk0,
			i_rd_enable => ovm2_bram_rd_enable
		);
		
		ovm3_bram: cpt_ovm_bram PORT MAP (
			i_pclk => ovm3_video_miso.pclk,
			i_vsync => ovm3_video_miso.vsync,
			i_href => ovm3_video_miso.href,
			i_data => ovm3_video_miso.data,
			i_reset => ovm3_bram_reset,
			o_rd_data => ovm3_bram_rd_data,
			o_frame_number => ovm3_bram_frame_number,
			o_line_number => ovm3_bram_line_number,
			o_words_read => ovm3_bram_words_read,
			i_burst_length => burst_length,
			o_burst_available => ovm3_bram_burst_available,
			o_collision => o3_collision,
			i_clk => c3_clk0,
			i_rd_enable => ovm3_bram_rd_enable
		);

	end generate incl_cctl;

	

	-- ========================================================================== --
	-- USB
	-- ========================================================================== --

	usb_enable <= mcu_gpo(GPIO_USB_ENABLE)(0);
	usb_mode <= mcu_gpo(GPIO_USB_MODE)(0);
	
	usb_frame_addr0 <= mcu_gpo(GPIO_USB_FRAME_ADDR0)(28 downto 0);
	usb_frame_addr1 <= mcu_gpo(GPIO_USB_FRAME_ADDR1)(28 downto 0);
	usb_frame_addr2 <= mcu_gpo(GPIO_USB_FRAME_ADDR2)(28 downto 0);
	usb_frame_addr3 <= mcu_gpo(GPIO_USB_FRAME_ADDR3)(28 downto 0);

	incl_usb:
	if ( INCLUDE_USB = "TRUE" ) generate
		
		usb_buffer : cpt_usb_buffer
		port map (
			i_clk => c3_clk0,
			i_enable => usb_enable,
			i_mport_mosi => mctl_mport1_mosi,
			o_mport_miso => mctl_mport1_miso,
			i_burst_length => usb_burst_length,
			i_frame_addr0 => usb_frame_addr0,
			i_frame_addr1 => usb_frame_addr1,
			i_frame_addr2 => usb_frame_addr2,
			i_frame_addr3 => usb_frame_addr3,
			--
			i_usbclk => usbclk,
			o_fifo_data => usb_fifo_data,
			i_fifo_rd_en => usb_fifo_rd_en,
			o_fifo_empty => usb_fifo_empty
		);
		
		
		usb : cpt_usb
		port map (		
			i_usb_mode => usb_mode,
			i_mcu_usb_data => mcu_usb_data_out,
			o_mcu_usb_data => mcu_usb_data_in,
			i_mcu_usb_ctrl_mosi => mcu_usb_ctrl_mosi,
			o_mcu_usb_ctrl_miso => mcu_usb_ctrl_miso,
			--
			o_usbclk => usbclk,
			i_fifo_data => usb_fifo_data,
			o_fifo_rd_en => usb_fifo_rd_en,
			i_fifo_empty => usb_fifo_empty,
			--
			i_usb_ctrl_miso => i_usb_ctrl_miso,
			o_usb_ctrl_mosi => o_usb_ctrl_mosi,
			io_usb_data => io_usb_data
		);
				
	end generate incl_usb;




	-- ========================================================================== --
	-- VGA
	-- ========================================================================== --

	-- Select main output VGA source based on Microblaze flags
	vga_src <= conv_integer(mcu_gpo(GPIO_VGA_SRC));
	
	vga_magic <= mcu_gpo(GPIO_VGA_MAGIC)(0);	
	vga_magic_key <= mcu_gpo(GPIO_VGA_MAGIC_KEY)(15 downto 12) & mcu_gpo(GPIO_VGA_MAGIC_KEY)(10 downto 7) & mcu_gpo(GPIO_VGA_MAGIC_KEY)(4 downto 1);
	
	vga_magic_key_match <= vga_magic when vga_magic_key = vga_mosi_fixed.red & vga_mosi_fixed.green & vga_mosi_fixed.blue else '0';

	vga_mosi.red <= vga_mosi_test.red when vga_magic_key_match = '1' else vga_mosi_fixed.red;
	vga_mosi.green <= vga_mosi_test.green when vga_magic_key_match = '1' else vga_mosi_fixed.green;
	vga_mosi.blue <= vga_mosi_test.blue when vga_magic_key_match = '1' else vga_mosi_fixed.blue;
	
	vga_mosi.vsync <= vga_mosi_fixed.vsync;
	vga_mosi.hsync <= vga_mosi_fixed.hsync;
		

	with vga_src select o_vga_mosi <= 
		vga_mosi_test when 0,		-- If Microblaze flag VGA_SRC = 0
		vga_mosi when others;	-- If Microblaze flag VGA_SRC = 1


	------------------------
	-- vga_fixed testcase --
	------------------------
	vga_enable <= mcu_gpo(GPIO_VGA_ENABLE)(0);

	mctl_mport2_miso <= vga_mport_miso;
	vga_mport_mosi <= mctl_mport2_mosi;


	-----------------------
	-- vga_test testcase --
	-----------------------
	vga_test_enable <= mcu_gpo(GPIO_VGA_TEST_ENABLE)(0);
	vga_test_mode <= mcu_gpo(GPIO_VGA_TEST_MODE)(0);

	incl_vga_test:
	if ( INCLUDE_VGA_TEST = "TRUE" ) generate
		
		vga_test : cpt_vga_test
		port map (
			i_clk => clk_108m,
			i_enable => vga_test_enable,
			i_vga_test_mode => vga_test_mode,
			o_vga_mosi => vga_mosi_test
		);
		
	end generate incl_vga_test;


	------------------------
	-- VGA				 --
	------------------------

	ovm_frame_addr0 <= mcu_gpo(GPIO_OVM_FRAME_ADDR0)(28 downto 0);
	ovm_frame_addr1 <= mcu_gpo(GPIO_OVM_FRAME_ADDR1)(28 downto 0);
	ovm_frame_addr2 <= mcu_gpo(GPIO_OVM_FRAME_ADDR2)(28 downto 0);
	ovm_frame_addr3 <= mcu_gpo(GPIO_OVM_FRAME_ADDR3)(28 downto 0);
	
	
	ovm0_line_offset <= conv_integer(mcu_gpo(GPIO_OVM0_LINE_OFFSET)(24 downto 0));
	ovm1_line_offset <= conv_integer(mcu_gpo(GPIO_OVM1_LINE_OFFSET)(24 downto 0));
	ovm2_line_offset <= conv_integer(mcu_gpo(GPIO_OVM2_LINE_OFFSET)(24 downto 0));
	ovm3_line_offset <= conv_integer(mcu_gpo(GPIO_OVM3_LINE_OFFSET)(24 downto 0));
	
	
	
	vga_frame_addr0 <= mcu_gpo(GPIO_VGA_FRAME_ADDR0)(28 downto 0);
	vga_frame_addr1 <= mcu_gpo(GPIO_VGA_FRAME_ADDR1)(28 downto 0);
	vga_frame_addr2 <= mcu_gpo(GPIO_VGA_FRAME_ADDR2)(28 downto 0);
	vga_frame_addr3 <= mcu_gpo(GPIO_VGA_FRAME_ADDR3)(28 downto 0);
	
	
	
	vga_mid_line_offset <= conv_integer(mcu_gpo(GPIO_VGA_MID_LINE_OFFSET)(25 downto 0));
	
	
	incl_vga:
	if ( INCLUDE_VGA = "TRUE" ) generate
		
		linebuf : cpt_linebuf
		port map (
			i_clk => clk_108m,
			i_enable => vga_enable,			
			i_frame_addr0 => vga_frame_addr0,
			i_frame_addr1 => vga_frame_addr1,
			i_frame_addr2 => vga_frame_addr2,
			i_frame_addr3 => vga_frame_addr3,
			i_frame_number => frame_number,			
			i_line_start => line_start,
			i_mid_line_offset => vga_mid_line_offset,
			i_line_number => line_number,			
			i_burst_length => conv_std_logic_vector(15,6),	-- Max 6 bits
			i_pixel_number => pixel_number,			
			i_mport_mosi => vga_mport_mosi,
			o_mport_miso => vga_mport_miso,			
			o_linebuf_data => linebuf_data
		);
		
		vga : cpt_vga
		port map (
			i_clk => clk_108m,
			i_enable => vga_enable,			
			i_linebuf_data => linebuf_data,
			o_line_start => line_start,			
			o_pixel_number => pixel_number,
			o_line_number => line_number,
			o_frame_number => frame_number,			
			o_vga_mosi => vga_mosi_fixed
		);
		
	end generate incl_vga;


	-- ========================================================================== --
	-- LED Demux
	-- ========================================================================== --

	ledclk_div <= conv_integer(mcu_gpo(GPIO_LEDCLK_DIV));
	mcu_gpi(GPIO_LEDCLK_DIV) <= mcu_gpo(GPIO_LEDCLK_DIV);

	led_latch_div <= conv_integer(mcu_gpo(GPIO_LED_LATCH_DIV));
	mcu_gpi(GPIO_LED_LATCH_DIV) <= mcu_gpo(GPIO_LED_LATCH_DIV);

	leds_inst : cpt_leds
	port map (
		i_clk => c3_clk0,
		i_leds => leds,
		i_led_clk_div => ledclk_div,
		i_led_latch_div => led_latch_div,
		o_led_addr => o_led_addr
	);

end architecture;
