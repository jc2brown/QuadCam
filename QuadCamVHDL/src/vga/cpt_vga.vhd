--
-- VGA component
--
-- Splits RGB data vector into separate RGB channels
-- Generates hsync and vsync
-- Keeps track of pixel count, line count, frame count and when new line starts
--

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library vga;
use vga.pkg_vga.all;

library util;
use util.pkg_util.all;


entity cpt_vga is
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
end cpt_vga;

architecture Behavioral of cpt_vga is

	signal clear_count : std_logic := '0';
	signal increment_pixel : std_logic := '0';
	signal pixel_number : integer range -2048 to 2047;
	signal line_number : integer range -1024 to 1023;
	signal h_blank : std_logic := '0';
	signal h_blank_d1 : std_logic := '0';
	signal v_blank : std_logic := '0';
	signal v_blank_d1 : std_logic := '0';
	signal h_sync : std_logic := '0';
	signal h_sync_d1 : std_logic := '0';
	signal v_sync : std_logic := '0';
	signal v_sync_d1 : std_logic := '0';
	signal increment_line : std_logic := '0';
	signal increment_frame : std_logic := '0';

begin

	--
	-- Counters
	--

	-- Count pixels from -408 to 1279
	-- Active pixel starts at 0
	pixel_counter: cpt_upcounter
	port map (
		i_clk => i_clk,
		i_enable => increment_pixel,
		i_lowest => (-H_BP - H_PULSE - H_FP),
		i_highest => PIXELS_PER_LINE-1,
		i_increment => 1,
		i_clear => '0',
		i_preset => clear_count,
		o_count => pixel_number,
		o_carry => open
	);

	-- Count lines from -42 to 1023
	-- Active line starts at 0
	line_counter: cpt_upcounter
	port map (
		i_clk => i_clk,
		i_enable => increment_line,
		i_lowest => (-V_BP - V_PULSE - V_FP),
		i_highest => MAX_LINES-1,
		i_increment => 1,
		i_clear => '0',
		i_preset => clear_count,
		o_count => line_number,
		o_carry => open
	);

	-- Count frames from 0 to 3
	frame_counter: cpt_upcounter
	port map (
		i_clk => i_clk,
		i_enable => increment_frame,
		i_lowest => 0,
		i_highest => 3,
		i_increment => 1,
		i_clear => '0',
		i_preset => clear_count,
		o_count => o_frame_number,
		o_carry => open
	);


	--
	-- Data latches
	--

	-- Sync increment_pixel with clk
	increment_pixel_fd: FD
	port map (
		D => i_enable,
		C => i_clk,
		Q => increment_pixel
	);

--	-- Sync h_blank with clk
--	h_blank_d1_fd: FD
--	port map (
--		D => h_blank,
--		C => i_clk,
--		Q => h_blank_d1
--	);

	-- Sync v_blank with clk
	v_blank_d1_fd: FD
	port map (
		D => v_blank,
		C => i_clk,
		Q => v_blank_d1
	);

	-- Sync hsync with clk
	h_sync_d1_fd: FD
	port map (
		D => h_sync,
		C => i_clk,
		Q => h_sync_d1
	);

	-- Sync vsync with clk
	v_sync_d1_fd: FD
	port map (
		D => v_sync,
		C => i_clk,
		Q => v_sync_d1
	);

	-- Sync line_start with clk
	line_start_fd: FD
	port map (
		D => increment_line,
		C => i_clk,
		Q => o_line_start
	);

	-- Sync hsync with clk
	vga_hsync_fd: FD
	port map (
		D => h_sync_d1,
		C => i_clk,
		Q => o_vga_mosi.hsync
	);

	-- Sync vsync with clk
	vga_vsync_fd: FD
	port map (
		D => v_sync_d1,
		C => i_clk,
		Q => o_vga_mosi.vsync
	);


	clear_count <= not i_enable;	-- Reset all counters when not enabled

	o_pixel_number <= pixel_number;
	o_line_number <= line_number;


--	h_blank <= '1' 
--		when pixel_number < 0 -- Horizontal blanking period
--		else '0';

	process (i_clk)
	begin
		if rising_edge(i_clk) then
			-- Horizontal blanking period
			if ( pixel_number < 0 ) then
				h_blank_d1 <= '1';
			else
				h_blank_d1 <= '0';
			end if;
		end if;
	end process;


	v_blank <= '1' 
		when line_number < 0 -- Vertical blanking period
		else '0';

	h_sync <= '1' 
		when pixel_number < -H_BP and pixel_number >= (-H_BP - H_PULSE) -- Horizontal sync pulse time
		else '0';

	v_sync <= '1' 
		when line_number < -V_BP and line_number >= (-V_BP - V_PULSE) -- Vertical sync pulse time
		else '0';

	increment_line <= '1' 
		when pixel_number = PIXELS_PER_LINE-1 and increment_pixel = '1' -- Reached end of current line
		else '0';

	increment_frame <= '1' 
		when pixel_number = PIXELS_PER_LINE-1 and line_number = MAX_LINES-1 and increment_pixel = '1' -- Reached last line in frame
		else '0';

	-- Mux and split RGB data
	process (i_clk)
	begin
		if rising_edge(i_clk) then
			case ( h_blank_d1 or v_blank_d1 ) is
				when '0' =>
					-- Only use 4 bits of colour channel data, throw away LSb
					-- RGB565 colour format uses 5 bits for red and blue, 6 bits for green
					-- http://www.theimagingsource.com/en_US/support/documentation/icimagingcontrol-class/PixelformatRGB565.htm
					o_vga_mosi.red <= i_linebuf_data(15 downto 12);
					o_vga_mosi.green <= i_linebuf_data(10 downto 7);
					o_vga_mosi.blue <= i_linebuf_data(4 downto 1);
					
				when others =>
					-- If either horizontal or vertical blanking periods active,
					-- there is no colour data output
					o_vga_mosi.red <= (others => '0');
					o_vga_mosi.green <= (others => '0');
					o_vga_mosi.blue <= (others => '0');
					
			end case;
		end if;
	end process;

end Behavioral;
