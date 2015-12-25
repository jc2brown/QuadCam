
library ieee;
use ieee.std_logic_1164.all;


use ieee.numeric_std.all;

library vga;
use vga.pkg_vga.all;

entity test_linebuf is
end test_linebuf;

architecture Behavioral of test_linebuf is
	
	signal clk : std_logic;
	signal enable : std_logic;
	signal linebuf_data : std_logic_vector(15 downto 0);
	signal line_start : std_logic;
	signal pixel_number : integer range -2048 to 2047;
	signal line_number : integer range -1024 to 1023;
	signal frame_number : integer range 0 to 3;
	signal vga_mosi : typ_vga_mosi;



	component cpt_linebuf is
		 port ( 
			signal enable : std_logic;
			signal clk : std_logic;
			  
			signal frame_addr0 : std_logic_vector (25 downto 0);
			signal frame_addr1 : std_logic_vector (25 downto 0);
			signal frame_addr2 : std_logic_vector (25 downto 0);
			signal frame_addr3 : std_logic_vector (25 downto 0);
			signal frame_number : integer := 0;
			  
			signal line_start : std_logic;
			signal mid_line_offset : integer range -(2**24) to ((2**24)-1) := 0;
			signal line_number : integer range -1024 to 1023 := 0;
			  
			signal burst_length : std_logic_vector (5 downto 0);
			signal pixel_number : std_logic_vector (11 downto 0);
			  
			signal mport_mosi : typ_mctl_mport_mosi;
			signal mport_miso : typ_mctl_mport_miso;
				
			signal linebuf_data : std_logic_vector (15 downto 0)
		);
	end component;
	
	
	


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
		o_mport_miso mport_miso,
			
		o_linebuf_data => linebuf_data,
		
		
		
		
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
		wait for 4.63 ns;
		clk <= '1';
		wait for 4.63 ns;
	end process;



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
		o_mport_miso mport_miso,
			
		o_linebuf_data => linebuf_data,
	);

end Behavioral;

