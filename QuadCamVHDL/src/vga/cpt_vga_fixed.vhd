
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;



library mctl;
use mctl.pkg_mctl.all;

library vga;
use vga.pkg_vga.all;

library util;
use util.pkg_util.all;


entity cpt_vga_fixed is

	generic (
		SMALL_FRAME : string := "FALSE"
	);

		port  (		
			i_clk : in std_logic;
			i_enable : in std_logic;
			i_mport_mosi : in typ_mctl_mport_mosi;
			o_mport_miso : out typ_mctl_mport_miso;
			o_vga_mosi : out typ_vga_mosi
		);		
		
end cpt_vga_fixed;


architecture behavioral of cpt_vga_fixed is

	function f(v1:integer; v2:integer) return integer is
		begin
		if (SMALL_FRAME = "FALSE") then
		  return v1;
		else
		  return v2;
		end if;
   end function;
		

	-- -----------------------------------
	-- Characteristic timing constants
	-- -----------------------------------
	
	constant H_SUBFRAME_WIDTH : integer := 640;
	constant V_SUBFRAME_WIDTH : integer := 480;
	
	constant H_ACTIVE_WIDTH : integer := f(1280, 12);
	constant H_FRONTPORCH_WIDTH : integer := f(48, 2);
	constant H_SYNC_WIDTH : integer := f(112, 1);
	constant H_BACKPORCH_WIDTH : integer := f(248, 2);
		
	constant V_ACTIVE_WIDTH : integer := f(1024, 12);
	constant V_FRONTPORCH_WIDTH : integer := f(1, 1);
	constant V_SYNC_WIDTH : integer := f(3, 1);
	constant V_BACKPORCH_WIDTH : integer := f(38, 2);
	
	
	-- --------------------------------------------------------
	-- Derived timing constants (do not modify without reason)
	-- --------------------------------------------------------
	
	constant H_ACTIVE_FIRST : integer := 0;
	constant H_ACTIVE_LAST : integer := H_ACTIVE_FIRST + H_ACTIVE_WIDTH - 1;
	
	constant H_SUBFRAME_FIRST : integer := 0;
	constant H_SUBFRAME_LAST : integer := H_SUBFRAME_FIRST + H_SUBFRAME_WIDTH - 1;
	
	constant H_FRONTPORCH_FIRST : integer := H_ACTIVE_LAST + 1;
	constant H_FRONTPORCH_LAST : integer := H_FRONTPORCH_FIRST + H_FRONTPORCH_WIDTH - 1;
	
	constant H_SYNC_FIRST : integer := H_FRONTPORCH_LAST + 1;
	constant H_SYNC_LAST : integer := H_SYNC_FIRST + H_SYNC_WIDTH - 1;
	
	constant H_BACKPORCH_FIRST : integer := H_SYNC_LAST + 1;
	constant H_BACKPORCH_LAST : integer := H_BACKPORCH_FIRST + H_BACKPORCH_WIDTH - 1;
	
	constant H_BLANK_FIRST : integer := H_FRONTPORCH_FIRST;
	constant H_BLANK_LAST : integer := H_BACKPORCH_LAST;
	
	constant H_FRAME_FIRST : integer := H_ACTIVE_FIRST;
	constant H_FRAME_LAST : integer := H_BACKPORCH_LAST;
		
	constant V_ACTIVE_FIRST : integer := 0;
	constant V_ACTIVE_LAST : integer := V_ACTIVE_FIRST + V_ACTIVE_WIDTH - 1;
	
	constant V_SUBFRAME_FIRST : integer := 0;
	constant V_SUBFRAME_LAST : integer := V_SUBFRAME_FIRST + V_SUBFRAME_WIDTH - 1;
	
	constant V_FRONTPORCH_FIRST : integer := V_ACTIVE_LAST + 1;
	constant V_FRONTPORCH_LAST : integer := V_FRONTPORCH_FIRST + V_FRONTPORCH_WIDTH - 1;
	
	constant V_SYNC_FIRST : integer := V_FRONTPORCH_LAST + 1;
	constant V_SYNC_LAST : integer := V_SYNC_FIRST + V_SYNC_WIDTH - 1;
	
	constant V_BACKPORCH_FIRST : integer := V_SYNC_LAST + 1;
	constant V_BACKPORCH_LAST : integer := V_BACKPORCH_FIRST + V_BACKPORCH_WIDTH - 1;
	
	constant V_BLANK_FIRST : integer := V_FRONTPORCH_FIRST;
	constant V_BLANK_LAST : integer := V_BACKPORCH_LAST;
	
	constant V_FRAME_FIRST : integer := V_ACTIVE_FIRST;
	constant V_FRAME_LAST : integer := V_BACKPORCH_LAST;
	
	
	-- Video timing generation 
	signal h_count : integer := 0;
	signal h_active : std_logic := '1';		
	signal h_subframe_active : std_logic := '1';		
	signal h_sync : std_logic := '0';	
	
	
	
	
	
	constant LINE_BURST_LENGTH : integer := 8;
	
	
	
	signal h_fetch_count : integer;
	
	
	signal v_counter_enable : std_logic := '1';
	signal v_count : integer := 0;
	signal v_active : std_logic := '1';
	signal v_subframe_active : std_logic := '1';
	signal v_sync : std_logic := '0';	
	
	signal frame_counter_enable : std_logic := '1';
	signal frame_count : integer := 0;
	signal frame_active : std_logic := '1';
	
	signal reset : std_logic := '0';


	signal addr_latch : std_logic_vector(25 downto 0) := (others => '0');
	
	signal cmd_empty_d1 : std_logic;
	

	signal red : integer := 0;
	signal green : integer := 0;
	signal blue : integer := 0;
	
	
	signal red_vector : std_logic_vector(15 downto 0) := (others => '0');
	signal green_vector : std_logic_vector(15 downto 0) := (others => '0');
	signal blue_vector : std_logic_vector(15 downto 0) := (others => '0');

	
	signal frame_vector : std_logic_vector(15 downto 0) := (others => '0');

begin


	reset <= not i_enable;
	

--	red_vector <= std_logic_vector(to_unsigned(4*frame_count - 3*h_count - 5*v_count, 16));
--	green_vector <= std_logic_vector(to_unsigned(5*h_count + 2*v_count + 10*frame_count, 16));
--	blue_vector <= std_logic_vector(to_unsigned(3*v_count - 2*h_count + 6*frame_count, 16));


	frame_vector <= std_logic_vector(to_unsigned(frame_count, 16));

--	red <= to_integer(unsigned(red_vector(12 downto 9)));
--	green <= to_integer(unsigned(green_vector(12 downto 9)));
--	blue <= to_integer(unsigned(blue_vector(12 downto 9)));

	
--	red <= to_integer(unsigned(red_vector(12 downto 9)));
--	green <= to_integer(unsigned(green_vector(12 downto 9)));
--	blue <= to_integer(unsigned(blue_vector(12 downto 9)));

	o_mport_miso.wr.clk <= i_clk;
	o_mport_miso.wr.en <= '0';


	o_mport_miso.cmd.clk <= i_clk;
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			cmd_empty_d1 <= i_mport_mosi.cmd.empty;
		end if;
	end process;
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( frame_counter_enable = '1' ) then 
				addr_latch <= (others => '0');
			elsif ( h_sync = '1' ) then
				h_fetch_count <= 0;
			elsif ( i_mport_mosi.cmd.empty = '1' and cmd_empty_d1 = '1' and h_fetch_count < H_ACTIVE_WIDTH ) then -- and h_active = '1' ) then
			--elsif ( i_mport_mosi.cmd.empty = '1' and cmd_empty_d1 = '1' and  h_fetch_count < H_ACTIVE_WIDTH and to_integer(unsigned(i_mport_mosi.rd.count)) < (2*LINE_BURST_LENGTH) and h_active = '1' ) then
				o_mport_miso.cmd.en <= '1';
				o_mport_miso.cmd.instr <= "011";
				--o_mport_miso.cmd.bl <= "001111";				
				o_mport_miso.cmd.bl <= std_logic_vector(to_unsigned((LINE_BURST_LENGTH-1), 6));
				o_mport_miso.cmd.byte_addr <= "0000" & addr_latch(25 downto 0);
				addr_latch <= std_logic_vector(to_unsigned(LINE_BURST_LENGTH*4+to_integer(unsigned(addr_latch)),26));
				h_fetch_count <= LINE_BURST_LENGTH + h_fetch_count;				
			else			
				o_mport_miso.cmd.en <= '0';
			end if;		
		end if;	
	end process;



	
	o_mport_miso.rd.clk <= i_clk;

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			--if ( h_subframe_active = '1' and v_subframe_active = '1' ) then
			if ( h_active = '1' and v_active = '1' ) then
			
				o_mport_miso.rd.en <= '1';
		
				o_vga_mosi.red <= i_mport_mosi.rd.data(15 downto 12);
				o_vga_mosi.green <= i_mport_mosi.rd.data(10 downto 7);
				o_vga_mosi.blue <= i_mport_mosi.rd.data(4 downto 1);
	
		
--				o_vga_mosi.red <= std_logic_vector(to_unsigned(red,4));
--				o_vga_mosi.green <= std_logic_vector(to_unsigned(green,4));
--				o_vga_mosi.blue <= std_logic_vector(to_unsigned(blue,4));
	
			else 
			
				o_mport_miso.rd.en <= '0';
			
				o_vga_mosi.red <= (others => '0');
				o_vga_mosi.green <= (others => '0');
				o_vga_mosi.blue <= (others => '0');
			end if;
		end if;
	end process;
	
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			o_vga_mosi.hsync <= h_sync;
			o_vga_mosi.vsync <= v_sync;
		end if;
	end process;
		


	h_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => i_clk,
		i_enable => '1',
		i_lowest => H_FRAME_FIRST,
		i_highest => H_FRAME_LAST,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => h_count,
		o_carry => open	
	);
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and h_count >= H_ACTIVE_FIRST and h_count <= H_ACTIVE_LAST ) then
				h_active <= '1';
			else 
				h_active <= '0';
			end if;
		end if;
	end process;
			
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and h_count >= H_SUBFRAME_FIRST and h_count <= H_SUBFRAME_LAST ) then
				h_subframe_active <= '1';
			else 
				h_subframe_active <= '0';
			end if;
		end if;
	end process;
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and h_count >= H_SYNC_FIRST and h_count <= H_SYNC_LAST ) then
				h_sync <= '1';
			else 
				h_sync <= '0';
			end if;
		end if;
	end process;
	
	
	
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( h_count = H_FRAME_LAST ) then
				v_counter_enable <= '1';
			else
				v_counter_enable <= '0';
			end if;
		end if;
	end process;
	
	v_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => i_clk,
		i_enable => v_counter_enable,
		i_lowest => V_FRAME_FIRST,
		i_highest => V_FRAME_LAST,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => v_count,
		o_carry => open
	);	
		
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and v_count >= V_ACTIVE_FIRST and v_count <= V_ACTIVE_LAST ) then
				v_active <= '1';
			else 
				v_active <= '0';
			end if;
		end if;
	end process;	
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and v_count >= V_SUBFRAME_FIRST and v_count <= V_SUBFRAME_LAST ) then
				v_subframe_active <= '1';
			else 
				v_subframe_active <= '0';
			end if;
		end if;
	end process;
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( reset = '0' and v_count >= V_SYNC_FIRST and v_count <= V_SYNC_LAST ) then
				v_sync <= '1';
			else 
				v_sync <= '0';
			end if;
		end if;
	end process;

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( h_count = H_FRAME_LAST and v_count = V_FRAME_LAST ) then
				frame_counter_enable <= '1';
			else 
				frame_counter_enable <= '0';
			end if;
		end if;
	end process;
	
	frame_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => i_clk,
		i_enable => frame_counter_enable,
		i_lowest => 0,
		i_highest => 2**30-1,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => frame_count,
		o_carry => open
	);	

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( v_count >= 0 ) then
				frame_active <= '1';
			else 
				frame_active <= '0';
			end if;
		end if;
	end process;
	

end behavioral;

