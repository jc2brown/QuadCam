
library ieee;
use ieee.std_logic_1164.all;


library mctl;
use mctl.pkg_mctl.all;

package pkg_usb is

	type typ_usb_ctrl_miso is record
		clk : std_logic;
		rxf_n : std_logic;
		txe_n : std_logic;
	end record;
	
	constant init_usb_ctrl_miso : typ_usb_ctrl_miso := (
		clk => '1',
		rxf_n => '1',
		txe_n => '1'
	);
	
	
	type typ_usb_ctrl_mosi is record
		rd_n : std_logic;
		wr_n : std_logic;
		oe_n : std_logic;
		siwu_n : std_logic;
	end record;
	
	constant init_usb_ctrl_mosi : typ_usb_ctrl_mosi := (
		rd_n => '1',
		wr_n => '1',
		oe_n => '1',
		siwu_n => '1'
	);

	
		
	component cpt_usb is
		port (
			i_usb_ctrl_miso : in typ_usb_ctrl_miso;
			o_usb_ctrl_mosi : out typ_usb_ctrl_mosi;
			io_usb_data : inout std_logic_vector(7 downto 0);			
			i_mcu_usb_data : in std_logic_vector(7 downto 0);
			o_mcu_usb_data : out std_logic_vector(7 downto 0);
			o_mcu_usb_ctrl_miso : out typ_usb_ctrl_miso;
			i_mcu_usb_ctrl_mosi : in typ_usb_ctrl_mosi;
			i_usb_mode : in std_logic;			
			o_usbclk : out std_logic;
			i_fifo_data : in std_logic_vector(7 downto 0);
			o_fifo_rd_en : out std_logic;
			i_fifo_empty : in std_logic
		);
	end component;
		
	component cpt_usb_buffer is
		port (
			-- System clock domain
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_burst_length : in std_logic_vector(5 downto 0);
			i_frame_addr0 : in std_logic_vector(28 downto 0);
			i_frame_addr1 : in std_logic_vector(28 downto 0);
			i_frame_addr2 : in std_logic_vector(28 downto 0);
			i_frame_addr3 : in std_logic_vector(28 downto 0);
			i_mport_mosi : in typ_mctl_mport_mosi;
			o_mport_miso : out typ_mctl_mport_miso;
			-- USB clock domain
			i_usbclk : in std_logic;
			i_fifo_rd_en : in std_logic;
			o_fifo_empty : out std_logic;
			o_fifo_data : out std_logic_vector(7 downto 0)
		);
	end component;

		
		
end pkg_usb;

package body pkg_usb is

 
end pkg_usb;
