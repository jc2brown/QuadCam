
library ieee;
use ieee.std_logic_1164.all;


use ieee.numeric_std.all;

library mctl;
use mctl.pkg_mctl.all;

library vga;
use vga.pkg_vga.all;

entity test_linebuf_to_vga is
end test_linebuf_to_vga;


architecture Behavioral of test_linebuf_to_vga is
	
	signal enable : std_logic;
	signal clk : std_logic;
	  
	  
	  
	-- mport-linebuf common signals 	
	signal mport_mosi : typ_mctl_mport_mosi;
	signal mport_miso : typ_mctl_mport_miso;
	
	
	
	-- linebuf-VGA common signals 
	signal line_start : std_logic := '0';
	signal linebuf_data : std_logic_vector(15 downto 0);
	signal pixel_number : integer range -2048 to 2047 := 0;
	signal line_number : integer range -1024 to 1023 := 0;
	signal frame_number : integer range 0 to 3 := 0;
	  
	  
	-- VGA signals
	signal vga_mosi : typ_vga_mosi;


	-- Linebuf signals
	signal frame_addr0 : std_logic_vector (28 downto 0) := x"0000000" & "0";
	signal frame_addr1 : std_logic_vector (28 downto 0) := x"0010000" & "0";
	signal frame_addr2 : std_logic_vector (28 downto 0) := x"0020000" & "0";
	signal frame_addr3 : std_logic_vector (28 downto 0) := x"0030000" & "0";
	signal mid_line_offset : integer range -(2**24) to ((2**24)-1) := 0;	  
	signal burst_length : std_logic_vector (5 downto 0) := "001111";
	  
	  
   constant clk_period : time := 9.259 ns;
	
	  		
begin

	process
	begin
		enable <= '1';
		wait for 1 us;
		enable <= '0';
		wait for 1 us;
		enable <= '1';
		wait;
	end process;
			
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	
	mport_mosi.cmd.empty <= '1';
	mport_mosi.cmd.full <= '0';
	
	mport_mosi.rd.empty <= '1';
	mport_mosi.rd.full <= '0';
	mport_mosi.rd.count <= (others => '0');
	mport_mosi.rd.overflow <= '0';
	mport_mosi.rd.error <= '0';
	mport_mosi.rd.data <= (others => '0');
	
	mport_mosi.wr.empty <= '1';
	mport_mosi.wr.full <= '0';
	mport_mosi.wr.count <=  (others => '0');
	mport_mosi.wr.underrun <= '0';
	mport_mosi.wr.error <= '0';


	linebuf : cpt_linebuf
	 port map( 
		i_enable => enable,
		i_clk => clk,
		  
		i_frame_addr0 => frame_addr0,
		i_frame_addr1 => frame_addr1,
		i_frame_addr2 => frame_addr2,
		i_frame_addr3 => frame_addr3,
		i_frame_number => frame_number,
		  
		i_line_start => line_start,
		i_mid_line_offset => mid_line_offset,
		i_line_number => line_number,
		  
		i_burst_length => burst_length,
		i_pixel_number => pixel_number,
		  
		i_mport_mosi => mport_mosi,
		o_mport_miso => mport_miso,
			
		o_linebuf_data => linebuf_data
	);

	vga : cpt_vga
	port map (
		i_clk => clk,
		i_enable => enable,
		i_linebuf_data => linebuf_data,	-- Input RGB data
		o_line_start => line_start,	-- Beginning of line indicator flag
		o_pixel_number => pixel_number,
		o_line_number => line_number,
		o_frame_number => frame_number,
		o_vga_mosi =>	vga_mosi -- Output RGB data, hsync, vsync
	);
	
end Behavioral;

