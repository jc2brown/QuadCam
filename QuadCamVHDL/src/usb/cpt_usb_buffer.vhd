
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library mctl;
use mctl.pkg_mctl.all;

library usb;
use usb.pkg_usb.all;

library util;
use util.pkg_util.all;

entity cpt_usb_buffer is
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
end cpt_usb_buffer;

architecture Behavioral of cpt_usb_buffer is

		
	component cpt_usb_fifo
	port(
		rst : in std_logic;
		wr_clk : in std_logic;
		rd_clk : in std_logic;
		din : in std_logic_vector(31 downto 0);
		wr_en : in std_logic;
		rd_en : in std_logic;          
		dout : out std_logic_vector(31 downto 0);
		full : out std_logic;
		empty : out std_logic
	);
	end component;


	signal reset : std_logic;
	
	signal burst_length : integer range 0 to 127;	
	signal word_number : integer range 0 to 511;
	signal line_number : integer range 0 to 2047;
	signal frame_number : integer range 0 to 3;
	
	signal frame_addr : std_logic_vector(28 downto 0);
	signal frame_addrnum : integer range 0 to 2**29-1;
	signal byte_addr : std_logic_vector(28 downto 0);
	signal byte_addrnum : integer range 0 to 2**29-1;
	
	signal increment_word : std_logic;
	signal increment_line : std_logic;
	signal increment_frame : std_logic;
	
	signal fifo_wr_data : std_logic_vector(31 downto 0);
	signal fifo_wr_en : std_logic;
	signal fifo_full : std_logic;

begin

	reset <= not i_enable;
	
	burst_length <= to_integer(unsigned(i_burst_length)) + 1;

	increment_word <= i_enable and not i_mport_mosi.cmd.empty;

	increment_line <= '1' when word_number = 319 and increment_word = '1' else '0';
	
	increment_frame <= '1' when line_number = 2047 and increment_word = '1' else '0';

	o_mport_miso.rd.en <= fifo_wr_en;
	o_mport_miso.rd.clk <= i_clk;
	
	o_mport_miso.wr.en <= '0';
	o_mport_miso.wr.clk <= i_clk;
	o_mport_miso.wr.mask <= "1111";
	o_mport_miso.wr.data <= (others => '0');
	
	o_mport_miso.cmd.en <= increment_word;
	o_mport_miso.cmd.bl <= i_burst_length;
	o_mport_miso.cmd.instr <= "011";
	o_mport_miso.cmd.byte_addr <= std_logic_vector(to_unsigned(byte_addrnum, 30));
	o_mport_miso.cmd.clk <= i_clk;	

	byte_addrnum <= (frame_addrnum + (line_number*2048)) + (word_number*4);
	

	word_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map (
		i_clk => i_clk,
		i_enable => increment_word,
		i_clear => reset,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 319,
		i_increment => burst_length,
		o_count => word_number,
		o_carry => open
	);
	
	
	line_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map (
		i_clk => i_clk,
		i_enable => increment_line,
		i_clear => reset,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 2047,
		i_increment => 1,
		o_count => line_number,
		o_carry => open
	);
	
	
	frame_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map (
		i_clk => i_clk,
		i_enable => increment_frame,
		i_clear => reset,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 3,
		i_increment => 1,
		o_count => frame_number,
		o_carry => open
	);


	with frame_number select frame_addr <= 
		i_frame_addr0 when 0,
		i_frame_addr1 when 1,
		i_frame_addr2 when 2,
		i_frame_addr3 when 3;
		

	process(i_clk)
	begin
		if ( rising_edge(i_clk) and increment_frame = '1' ) then
			frame_addrnum <= to_integer(unsigned(frame_addr));
		end if;
	end process;	

	fifo_wr_data <= i_mport_mosi.rd.data;
	
	fifo_wr_en <= (not fifo_full) and (not i_mport_mosi.rd.empty);
	
	usb_fifo : cpt_usb_fifo 
	port map(
		rst => '0',
		wr_clk => i_clk,
		rd_clk => i_usbclk,
		din => fifo_wr_data,
		wr_en => fifo_wr_en,
		rd_en => i_fifo_rd_en,
		dout(7 downto 0) => o_fifo_data,
		dout(31 downto 8) => open,
		full => fifo_full,
		empty => o_fifo_empty
	);


end Behavioral;

