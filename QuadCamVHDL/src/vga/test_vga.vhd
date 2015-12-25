
library ieee;
use ieee.std_logic_1164.all;


use ieee.numeric_std.all;

library vga;
use vga.pkg_vga.all;

entity test_vga is
end test_vga;

architecture Behavioral of test_vga is
	
	signal clk : std_logic;
	signal enable : std_logic;
	signal linebuf_data : std_logic_vector(15 downto 0);
	signal line_start : std_logic;
	signal pixel_number : integer range -2048 to 2047;
	signal line_number : integer range -1024 to 1023;
	signal frame_number : integer range 0 to 3;
	signal vga_mosi : typ_vga_mosi;

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


	process(clk)
	begin
		if rising_edge(clk) then
			linebuf_data(15 downto 12) <= std_logic_vector(to_unsigned((pixel_number/256) mod 16, 4));
			linebuf_data(10 downto 7) <= std_logic_vector(to_unsigned((pixel_number/16) mod 16, 4));
			linebuf_data(4 downto 1) <= std_logic_vector(to_unsigned(pixel_number mod 16, 4));
		end if;
	end process;
	

	linebuf_data(11) <= '0';
	linebuf_data(6) <= '0';
	linebuf_data(5) <= '0';
	linebuf_data(0) <= '0';

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

