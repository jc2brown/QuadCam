
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;



library mctl;
use mctl.pkg_mctl.all;

library cctl;
use cctl.pkg_cctl.all;

library cctl;
use cctl.pkg_ovm.all;

library usb;
use usb.pkg_usb.all;

library vga;
use vga.pkg_vga.all;

library util;
use util.pkg_util.all;


entity test_quadcam is
end entity test_quadcam;


architecture arch of test_quadcam is

	constant C3_HW_TESTING : string := "FALSE";
	constant C3_SIMULATION : string := "TRUE";
	constant C3_CALIB_SOFT_IP : string := "FALSE";
	
	
		-- Duration to stay in reset on startup, in seconds
		-- External RAM requires 200us min.
	constant STARTUP_RESET_DUR : real := 20.0e-6;
		
		-- Master oscillator frequency, in Hz
	constant SYSTEM_CLOCK_FREQ : real := 24.0e6;
	
	
	-- Features to include in simulation
	constant INCLUDE_MCU : string := "TRUE";	
	constant INCLUDE_MCTL : string := "TRUE";
	constant INCLUDE_MCTL_CHIPSCOPE : string := "FALSE";	
	constant INCLUDE_MCTL_TEST : string := "FALSE";
	constant INCLUDE_IOBUS_MPORT : string := "TRUE";	
	constant INCLUDE_SCCB : string := "TRUE";
	constant INCLUDE_CCTL : string := "TRUE";
	constant INCLUDE_USB : string := "TRUE";
	constant INCLUDE_VGA : string := "TRUE";
		 
	constant SMALL_FRAME : string := "FALSE";
		 
		 
		 
	function c3_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
		begin
		if (C3_HW_TESTING = "FALSE") then
		  return val1;
		else
		  return val2;
		end if;
	end function;		



	component sim_ovm is
		generic (
			SMALL_FRAME : string := "FALSE"
		);
		port (			
			i_ovm_sccb_mosi : in typ_ovm_sccb_mosi;
			io_ovm_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm_video_miso : out typ_ovm_video_miso 			
		);
	end component;

	component top_quadcam is
		generic (
		
			STARTUP_RESET_DUR : real := 200.0e-6;
			SYSTEM_CLOCK_FREQ : real := 24.0e6;
				
			INCLUDE_MCU : string;
			INCLUDE_MCTL : string;
			INCLUDE_MCTL_CHIPSCOPE : string;
			INCLUDE_MCTL_TEST : string;
			INCLUDE_IOBUS_MPORT : string;			
			INCLUDE_SCCB : string;	
			INCLUDE_CCTL : string;
			INCLUDE_USB : string;	
			INCLUDE_VGA : string;	

			C3_CALIB_SOFT_IP : string := "FALSE";
			C3_SIMULATION : string := "FALSE"; 											
			C3_HW_TESTING : string := "TRUE"

		);  		
		
		port (
			
			i_clk_24M : in  std_logic;
			
			o_mcu_uart_tx : out std_logic;
			i_mcu_uart_rx : in std_logic;
			
			o_led_addr : out std_logic_vector(2 downto 0);
			i_switch1 : in std_logic;
			i_switch2 : in std_logic;
			
			mcb3_rzq : inout  std_logic;		
			mcb3_cs_n : out std_logic;
			
			mctl_ram_bidir : inout typ_mctl_ram_bidir;
			mctl_ram_mosi : out typ_mctl_ram_mosi;
			
			io_debug_ovm0_video_miso : inout typ_ovm_video_miso;
			io_debug_ovm0_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_debug_ovm0_sccb_mosi : inout typ_ovm_sccb_mosi;
			
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
			io_usb_data : inout std_logic_vector(7 downto 0)
		
		);
	end component;


	component lpddr_model_c3 is
		port (
			Clk : in std_logic;
			Clk_n : in std_logic;
			Cke : in std_logic;
			Cs_n : in std_logic;
			Ras_n : in std_logic;
			Cas_n : in std_logic;
			We_n : in std_logic;
			Dm : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0);
			Ba : in std_logic_vector((C3_MEM_BANKADDR_WIDTH - 1) downto 0);
			Addr : in std_logic_vector((C3_MEM_ADDR_WIDTH  - 1) downto 0);
			Dq : inout std_logic_vector((C3_NUM_DQ_PINS - 1) downto 0);
			Dqs : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0)
		);
	end component;
  
  
   signal clk_24M : std_logic := '0';

  	signal mcb3_cs_n : std_logic;
	
	signal mctl_ram_bidir : typ_mctl_ram_bidir;
	signal mctl_ram_mosi : typ_mctl_ram_mosi;
		
   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
      
   signal mcb3_command : std_logic_vector(2 downto 0);
   signal mcb3_enable1 : std_logic := '0';
   signal mcb3_enable2 : std_logic := '0';
   
   signal  mcb3_rzq : std_logic;
	
	signal usb_clkin : std_logic := '0';
	signal usb_clkout : std_logic;

	signal mcu_uart_tx : std_logic := '0';
	signal mcu_uart_rx : std_logic := '0';
	
	
	signal led_addr : std_logic_vector(2 downto 0);
	signal leds : std_logic_vector(7 downto 1);
	
	signal switch1 : std_logic;
	signal switch2 : std_logic;

	function vector (asi:std_logic) return std_logic_vector is
		variable v : std_logic_vector(0 downto 0) ; 
	begin
		v(0) := asi;
		return(v); 
	end function vector; 

	constant USB_PERIOD : time := 16.667 ns;
	
	
	signal debug_ovm0_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm1_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm2_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm3_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	
	
	signal debug_ovm0_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm1_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm2_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm3_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	
	signal debug_ovm0_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
	signal ovm1_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
	signal ovm2_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
	signal ovm3_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
	
	signal vga_mosi : typ_vga_mosi := init_vga_mosi;
		
	signal usb_ctrl_miso : typ_usb_ctrl_miso := init_usb_ctrl_miso;
	signal usb_ctrl_mosi : typ_usb_ctrl_mosi := init_usb_ctrl_mosi;
	signal usb_data : std_logic_vector(7 downto 0) := x"00";	
		
	
begin


	process
	begin
		usb_clkin <= not usb_clkin;
		wait for (USB_PERIOD) / 2;
	end process;

	
	-- System clock
	process
	begin
		clk_24M <= not clk_24M;
		wait for ( 1 sec * period(SYSTEM_CLOCK_FREQ) / 2.0 );
	end process;


   rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);
	
	mcu_uart_rx <= mcu_uart_tx;
	
	quadcam : top_quadcam 
	generic map ( 
		STARTUP_RESET_DUR => STARTUP_RESET_DUR,		 
		SYSTEM_CLOCK_FREQ => SYSTEM_CLOCK_FREQ,		
		
		INCLUDE_MCU => INCLUDE_MCU,
		INCLUDE_MCTL => INCLUDE_MCTL,
		INCLUDE_MCTL_CHIPSCOPE => INCLUDE_MCTL_CHIPSCOPE,
		INCLUDE_MCTL_TEST => INCLUDE_MCTL_TEST,
		INCLUDE_IOBUS_MPORT => INCLUDE_IOBUS_MPORT,			
		INCLUDE_SCCB => INCLUDE_SCCB,	
		INCLUDE_CCTL => INCLUDE_CCTL,
		INCLUDE_USB => INCLUDE_USB,
		INCLUDE_VGA => INCLUDE_VGA,
		
		C3_HW_TESTING => C3_HW_TESTING,
		C3_SIMULATION => C3_SIMULATION,
		C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP
	) 
	port map ( 
	
		i_clk_24M => clk_24M,  		
		
		o_mcu_uart_tx => mcu_uart_tx,
		i_mcu_uart_rx => mcu_uart_rx,
		
		o_led_addr => led_addr,
		i_switch1 => switch1,
		i_switch2 => switch2,
		
		mctl_ram_bidir => mctl_ram_bidir,
		mctl_ram_mosi => mctl_ram_mosi,

		mcb3_cs_n => mcb3_cs_n,
		mcb3_rzq => mcb3_rzq,
		
		io_debug_ovm0_video_miso => debug_ovm0_video_miso,
		io_debug_ovm0_sccb_bidir => debug_ovm0_sccb_bidir,
		o_debug_ovm0_sccb_mosi => debug_ovm0_sccb_mosi,
				
		i_ovm1_video_miso => ovm1_video_miso,
		io_ovm1_sccb_bidir => ovm1_sccb_bidir,
		o_ovm1_sccb_mosi => ovm1_sccb_mosi,
		
		i_ovm2_video_miso => ovm2_video_miso,
		io_ovm2_sccb_bidir => ovm2_sccb_bidir,
		o_ovm2_sccb_mosi => ovm2_sccb_mosi,
		
		i_ovm3_video_miso => ovm3_video_miso,
		io_ovm3_sccb_bidir => ovm3_sccb_bidir,
		o_ovm3_sccb_mosi => ovm3_sccb_mosi,
		
		o_vga_mosi => vga_mosi,
		
		i_usb_ctrl_miso => usb_ctrl_miso,
		o_usb_ctrl_mosi => usb_ctrl_mosi,	
		io_usb_data => usb_data

	);      


	gen_leds :
	for i in 1 to 7 generate
		leds(i) <= '1' when conv_std_logic_vector(i,3) = led_addr else '0';
	end generate;
	
	switch1 <= '0';
	switch2 <= '0';


-- ========================================================================== --
-- Cameras                                            -- 
-- ========================================================================== --
	
	cam0 : sim_ovm 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => debug_ovm0_sccb_mosi,
		io_ovm_sccb_bidir => debug_ovm0_sccb_bidir, 
		o_ovm_video_miso => debug_ovm0_video_miso
	);
	
	cam1 : sim_ovm 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm1_sccb_mosi,
		io_ovm_sccb_bidir => ovm1_sccb_bidir, 
		o_ovm_video_miso => ovm1_video_miso
	);
	
	cam2 : sim_ovm 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm2_sccb_mosi,
		io_ovm_sccb_bidir => ovm2_sccb_bidir, 
		o_ovm_video_miso => ovm2_video_miso
	);

	cam3 : sim_ovm 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm3_sccb_mosi,
		io_ovm_sccb_bidir => ovm3_sccb_bidir, 
		o_ovm_video_miso => ovm3_video_miso
	);
	
	

-- ========================================================================== --
-- LPDDR                                            -- 
-- ========================================================================== --
	
		
    mcb3_command <= (mctl_ram_mosi.ras_n & mctl_ram_mosi.cas_n & mctl_ram_mosi.we_n);

    process(mctl_ram_mosi.ck)
    begin
      if (rising_edge(mctl_ram_mosi.ck)) then
		  if (mcb3_command = "100") then
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "101") then
          mcb3_enable2 <= '1';
        else
          mcb3_enable2 <= mcb3_enable2;
        end if;
        mcb3_enable1 <= mcb3_enable2;
      end if;
    end process;


    mcb3_dram_dqs_vector(1 downto 0) <= (mctl_ram_bidir.udqs & mctl_ram_bidir.dqs) 
			when (mcb3_enable2 = '0' and mcb3_enable1 = '0') else "ZZ";

    mctl_ram_bidir.dqs <= mcb3_dram_dqs_vector(0) when ( mcb3_enable1 = '1') else 'Z';	 
    mctl_ram_bidir.udqs <= mcb3_dram_dqs_vector(1) when (mcb3_enable1 = '1') else 'Z';


	mcb3_dram_dm_vector <= (mctl_ram_mosi.udm & mctl_ram_mosi.dm);

	lpddr : lpddr_model_c3 
	port map(
		Clk => mctl_ram_mosi.ck,
		Clk_n => mctl_ram_mosi.ck_n,
		Cke => mctl_ram_mosi.cke,
		Cs_n => mcb3_cs_n,
		Ras_n => mctl_ram_mosi.ras_n,
		Cas_n => mctl_ram_mosi.cas_n,
		We_n => mctl_ram_mosi.we_n,
		Dm => mcb3_dram_dm_vector ,
		Ba => mctl_ram_mosi.ba,
		Addr => mctl_ram_mosi.a,
		Dq => mctl_ram_bidir.dq,
		Dqs => mcb3_dram_dqs_vector
	);



end architecture;
