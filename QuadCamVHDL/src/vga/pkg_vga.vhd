--
-- VGA package
--

library ieee;
use ieee.std_logic_1164.all;

library mctl;
use mctl.pkg_mctl.all;

package pkg_vga is

	-- SXGA 1280x1024 @ 60Hz
	-- http://tinyvga.com/vga-timing/1280x1024@60Hz
	constant PIXELS_PER_LINE : integer := 1280;	-- Total number of pixels per line
	constant MAX_LINES : integer := 1024;		-- Total number of lines on screen
	constant H_FP : integer := 48;		-- Horizontal front porch
	constant H_PULSE : integer := 112;	-- Horizontal sync pulse
	constant H_BP : integer := 248;		-- Horizontal back porch
	constant V_FP : integer := 1;		-- Vertical front porch
	constant V_PULSE : integer := 3;	-- Vertical sync pulse
	constant V_BP : integer := 38;		-- Vertical back porch


	type typ_vga_mosi is record
		red : std_logic_vector(3 downto 0);
		green : std_logic_vector(3 downto 0);
		blue : std_logic_vector(3 downto 0);
		hsync : std_logic;
		vsync : std_logic;
	end record;

	constant init_vga_mosi : typ_vga_mosi := (
		red => (others => '0'),
		green => (others => '0'),
		blue => (others => '0'),
		hsync => '0',
		vsync => '0'
	);


	component cpt_vga is
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_linebuf_data : in std_logic_vector(15 downto 0);	-- Input RGB data
			o_line_start : out std_logic;	-- Beginning of line indicator flag
			o_pixel_number : out integer range -2048 to 2047;
			o_line_number : out integer range -1024 to 1023;
			o_frame_number : out integer range 0 to 3;
			o_vga_mosi : out typ_vga_mosi := init_vga_mosi	-- Output RGB data, hsync, vsync
		);
	end component;

	component cpt_linebuf is
		 port ( 
			i_enable : in std_logic;
			i_clk : in std_logic;
			  
			i_frame_addr0 : in std_logic_vector (28 downto 0);
			i_frame_addr1 : in std_logic_vector (28 downto 0);
			i_frame_addr2 : in std_logic_vector (28 downto 0);
			i_frame_addr3 : in std_logic_vector (28 downto 0);
			i_frame_number : in integer := 0;
			  
			i_line_start : in std_logic;
			i_mid_line_offset : in integer range -(2**24) to (2**24)-1 := 0;
			i_line_number : in integer range -1024 to 1023 := 0;
			  
			i_burst_length : in std_logic_vector (5 downto 0);
			i_pixel_number : in integer range -2048 to 2047;
			  
			i_mport_mosi : in typ_mctl_mport_mosi;
			o_mport_miso : out typ_mctl_mport_miso;
			
			o_linebuf_data : out std_logic_vector (15 downto 0)
		);
	end component;


	component cpt_vga_test is
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_vga_test_mode : in std_logic;
			o_vga_mosi : out typ_vga_mosi
		);
	end component;

	component cpt_vga_fixed is
		generic (
			SMALL_FRAME : string := "FALSE"
		);
		port (
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_mport_mosi : in typ_mctl_mport_mosi;
			o_mport_miso : out typ_mctl_mport_miso;
			o_vga_mosi : out typ_vga_mosi
		);
	end component;

end pkg_vga;

package body pkg_vga is

end pkg_vga;
