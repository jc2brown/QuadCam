----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:18:05 07/16/2015 
-- Design Name: 
-- Module Name:    cpt_ovm_mux - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


library mctl;
use mctl.pkg_mctl.all;

library util;
use util.pkg_util.all;


-- Work library for testing
--library work;
--use work.pkg_testing.all;


entity cpt_ovm_mux is
	port (
		i_clk : in std_logic;
		i_reset : in std_logic;
	
		i0_frame_count : in integer range 0 to 3;
		i1_frame_count : in integer range 0 to 3;
		i2_frame_count : in integer range 0 to 3;
		i3_frame_count : in integer range 0 to 3;
		
		i_frame_addr0 : in std_logic_vector(28 downto 0);
		i_frame_addr1 : in std_logic_vector(28 downto 0);
		i_frame_addr2 : in std_logic_vector(28 downto 0);
		i_frame_addr3 : in std_logic_vector(28 downto 0);
	
		i0_line_offset : in integer range 0 to 2**13-1;
		i1_line_offset : in integer range 0 to 2**13-1;
		i2_line_offset : in integer range 0 to 2**13-1;
		i3_line_offset : in integer range 0 to 2**13-1;
		
		i0_words_read : in integer range 0 to 2**9-1;
		i1_words_read : in integer range 0 to 2**9-1;
		i2_words_read : in integer range 0 to 2**9-1;
		i3_words_read : in integer range 0 to 2**9-1;
		
		i0_line_count : in integer range 0 to 2**9-1;
		i1_line_count : in integer range 0 to 2**9-1;
		i2_line_count : in integer range 0 to 2**9-1;
		i3_line_count : in integer range 0 to 2**9-1;
		
		i0_rd_data : in std_logic_vector(31 downto 0);
		i1_rd_data : in std_logic_vector(31 downto 0);
		i2_rd_data : in std_logic_vector(31 downto 0);
		i3_rd_data : in std_logic_vector(31 downto 0);
				
		i0_burst_available : in std_logic;
		i1_burst_available : in std_logic;
		i2_burst_available : in std_logic;
		i3_burst_available : in std_logic;
		
		o0_rd_enable : out std_logic;
		o1_rd_enable : out std_logic;
		o2_rd_enable : out std_logic;
		o3_rd_enable : out std_logic;
		
		i_burst_length : in std_logic_vector(5 downto 0);
		
		o_mport_miso : out typ_mctl_mport_miso;
		i_mport_mosi : in typ_mctl_mport_mosi
		);
end cpt_ovm_mux;

architecture Behavioral of cpt_ovm_mux is
	
	signal burst_length : integer range 0 to 2**6-1;
	signal burst_count : integer range 0 to 2**6-1;
	signal burst_enable : std_logic := '0';
	signal burst_enable_d1 : std_logic := '0';
	signal last_burst_word : std_logic;
	signal burst_end : std_logic := '0';
	signal burst_done : std_logic;
	signal burst_count_enable : std_logic;
	signal burst_count_enable_d1 : std_logic;
	signal burst_clear : std_logic := '0';
	signal burst_available : std_logic;
	
	signal next_camera : std_logic;
	signal camera_count_enable : std_logic;
	signal camera_count_enable_d1 : std_logic;
	signal camera_count_enable_d2 : std_logic;
	signal camera_count : integer range 0 to 3;	
	
	signal frame_count : integer range 0 to 3;
	signal frame_addr : std_logic_vector(28 downto 0);
	signal frame_addrnum : integer range 0 to 2**29-1;
	
	signal line_offset : integer range 0 to 2**13-1;
	
	signal words_read : integer range 0 to 2**9-1;
	signal line_count : integer range 0 to 2**9-1;
	signal word_addr : integer range 0 to 2**27-1;
	
	signal word_addr_frame_addrnum : integer range 0 to 2**29-1;
	signal word_addr_line_offset : integer range 0 to 2**29-1;
	signal word_addr_words_read : integer range 0 to 2**29-1;
	signal word_addr_line_count : integer range 0 to 2**29-1;
		
		
		
begin
	
	burst_length <= to_integer(unsigned(i_burst_length));
	
	burst_count_enable <= 
		(burst_enable) and 
		(not burst_done) and 
		(not i_mport_mosi.cmd.full) and 
		(not i_mport_mosi.wr.full);
			
	burst_count_enable_d1_fd : fd
	port map (
		q => burst_count_enable_d1,
		d => burst_count_enable,
		c => i_clk
	);
	
	burst_clear <= not burst_enable;
	
	burst_counter : cpt_upcounter
	generic map (INIT => 63)
	port map (
		i_clk => i_clk,
		i_enable => burst_count_enable,
		i_clear => burst_clear,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 63,
		i_increment => 1,
		o_count => burst_count,
		o_carry => open		
	);
	
	last_burst_word <= '1' when burst_count = burst_length else '0';
	burst_done <= '1' when burst_count > burst_length else '0';
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			if ( last_burst_word = '1' and burst_count_enable = '1' ) then
				burst_end <= '1';
			else			
				burst_end <= '0';
			end if;
		end if;
	end process;

	o0_rd_enable <= burst_count_enable when camera_count = 0 else '0';
	o1_rd_enable <= burst_count_enable when camera_count = 1 else '0';
	o2_rd_enable <= burst_count_enable when camera_count = 2 else '0';
	o3_rd_enable <= burst_count_enable when camera_count = 3 else '0';
	
	frame_count_mux:
	with camera_count select frame_count <= 
		i0_frame_count when 0,
		i1_frame_count when 1,
		i2_frame_count when 2,
		i3_frame_count when 3;
	
 
	frame_addr_mux:
	with frame_count select frame_addr <=
		i_frame_addr0 when 0,
		i_frame_addr1 when 1,
		i_frame_addr2 when 2,
		i_frame_addr3 when 3;
		
	frame_addrnum <= to_integer(unsigned(frame_addr));
				
	line_offset_mux:
	with camera_count select line_offset <= 
		 i0_line_offset when 0,
		 i1_line_offset when 1,
		 i2_line_offset when 2,
		 i3_line_offset when 3;
	
	words_read_mux:
	with camera_count select words_read <= 
		i0_words_read when 0, 
		i1_words_read when 1,
		i2_words_read when 2,
		i3_words_read when 3;
	
	line_count_mux:
	with camera_count select line_count <= 
		i0_line_count when 0, 
		i1_line_count when 1,
		i2_line_count when 2,
		i3_line_count when 3;
		

	word_addr_frame_addrnum <= (frame_addrnum/4);
	word_addr_line_offset <= (512*line_offset);
	word_addr_words_read <= (words_read);
	word_addr_line_count <= (512*line_count);
	
	word_addr <= ( 
		word_addr_frame_addrnum + 
		word_addr_line_offset + 
		word_addr_words_read + 
		word_addr_line_count
	);
	
	process(i_clk)
	begin		
--		if ( rising_edge(i_clk) and burst_count = 0 ) then
		if ( rising_edge(i_clk) and camera_count_enable_d1 = '1' ) then
			o_mport_miso.cmd.byte_addr <= std_logic_vector(to_unsigned(word_addr, o_mport_miso.cmd.byte_addr'length-2)) & "00"; 
		end if;	
	end process;
	
	o_mport_miso.cmd.en <= burst_end;
	o_mport_miso.cmd.instr <= "010" when burst_end = '1' else "000"; -- write with precharge
	o_mport_miso.cmd.clk <= i_clk;
	o_mport_miso.cmd.bl <= i_burst_length;
	
	o_mport_miso.rd.clk <= i_clk;
	o_mport_miso.rd.en <= '0';
	
	o_mport_miso.wr.clk <= i_clk;
	o_mport_miso.wr.en <= burst_count_enable_d1;
	--o_mport_miso.wr.en <= burst_count_enable_d1;
	o_mport_miso.wr.mask <= "0000";
	
	with camera_count select o_mport_miso.wr.data <=
		i0_rd_data when 0,
		i1_rd_data when 1,
		i2_rd_data when 2,
		i3_rd_data when 3;
		
	burst_available_mux:
	with camera_count select burst_available <=
		i0_burst_available when 0,
		i1_burst_available when 1,
		i2_burst_available when 2,
		i3_burst_available when 3;
		
	next_camera <= burst_done when burst_enable = '1' else '1'; 
		
	--camera_count_enable <= (burst_done and burst_available) or (not burst_available) or (not burst_enable);
	--camera_count_enable <= (burst_done) or ((not camera_count_enable_d1) and (not burst_available));-- or (not burst_enable);	
	camera_count_enable <= (not camera_count_enable_d1) and (not camera_count_enable_d2) and (next_camera);--  (burst_done) or ((not camera_count_enable_d1) and (not burst_available));-- or (not burst_enable);	
	
		
	camera_count_enable_d1_fd : fd
	port map (
		d => camera_count_enable,
		q => camera_count_enable_d1,
		c => i_clk
	);
	
	camera_count_enable_d2_fd : fd
	port map (
		d => camera_count_enable_d1,
		q => camera_count_enable_d2,
		c => i_clk
	);
		
	process(i_clk, burst_done)
	begin		
		if ( burst_done = '1' or i_reset = '1' ) then
			burst_enable <= '0';
		elsif ( rising_edge(i_clk) and camera_count_enable_d1 = '1' ) then
			burst_enable <= burst_available;
		end if;	
	end process;
		
--	burst_enable_d1_fd : fd
--	port map (
--		d => burst_enable,
--		q => burst_enable_d1,
--		c => i_clk
--	);
	
	camera_counter : cpt_upcounter
	generic map (INIT => 0)
	port map (
		i_clk => i_clk,
		i_enable => camera_count_enable,
		i_clear => i_reset,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 3,
		i_increment => 1,
		o_count => camera_count,
		o_carry => open		
	);
	

end Behavioral;

