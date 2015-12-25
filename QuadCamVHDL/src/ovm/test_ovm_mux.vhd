--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:42:07 07/17/2015
-- Design Name:   
-- Module Name:   C:/Users/Chris/Dropbox/Capstone/QuadCam/QuadCamVHDL/src/cam/test_ovm_mux.vhd
-- Project Name:  QuadCamVHDL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpt_ovm_mux
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 

-- Work library for testing
library work;
use work.pkg_testing.all;
 
ENTITY test_ovm_mux IS
END test_ovm_mux;
 
ARCHITECTURE behavior OF test_ovm_mux IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpt_ovm_mux
    PORT(
         i_clk : IN  std_logic;
         i_reset : IN  std_logic;
         i0_frame_count : IN  integer range 0 to 3;
         i1_frame_count : IN  integer range 0 to 3;
         i2_frame_count : IN  integer range 0 to 3;
         i3_frame_count : IN  integer range 0 to 3;
         i_frame_addr0 : IN  std_logic_vector(25 downto 0);
         i_frame_addr1 : IN  std_logic_vector(25 downto 0);
         i_frame_addr2 : IN  std_logic_vector(25 downto 0);
         i_frame_addr3 : IN  std_logic_vector(25 downto 0);
         i0_line_offset : IN  integer range 0 to 8191;
         i1_line_offset : IN  integer range 0 to 8191;
         i2_line_offset : IN  integer range 0 to 8191;
         i3_line_offset : IN  integer range 0 to 8191;
         i0_words_read : IN  integer range 0 to 511;
         i1_words_read : IN  integer range 0 to 511;
         i2_words_read : IN  integer range 0 to 511;
         i3_words_read : IN  integer range 0 to 511;
         i0_line_count : IN  integer range 0 to 511;
         i1_line_count : IN  integer range 0 to 511;
         i2_line_count : IN  integer range 0 to 511;
         i3_line_count : IN  integer range 0 to 511;
         i0_rd_data : IN  std_logic_vector(31 downto 0);
         i1_rd_data : IN  std_logic_vector(31 downto 0);
         i2_rd_data : IN  std_logic_vector(31 downto 0);
         i3_rd_data : IN  std_logic_vector(31 downto 0);
         i0_burst_available : IN  std_logic;
         i1_burst_available : IN  std_logic;
         i2_burst_available : IN  std_logic;
         i3_burst_available : IN  std_logic;
         o0_rd_enable : OUT  std_logic;
         o1_rd_enable : OUT  std_logic;
         o2_rd_enable : OUT  std_logic;
         o3_rd_enable : OUT  std_logic;
         i_burst_length : IN  std_logic_vector(5 downto 0);
         o_mport_miso : OUT  typ_mctl_mport_miso;
         i_mport_mosi : IN  typ_mctl_mport_mosi
        );
    END COMPONENT;
    

   --Inputs
   signal i_clk : std_logic := '0';
   signal i_reset : std_logic := '0';
   signal i0_frame_count : integer range 0 to 3 := 0;
   signal i1_frame_count : integer range 0 to 3 := 0;
   signal i2_frame_count : integer range 0 to 3 := 0;
   signal i3_frame_count : integer range 0 to 3 := 0;
   signal i_frame_addr0 : std_logic_vector(25 downto 0) := "00" & x"000000";
   signal i_frame_addr1 : std_logic_vector(25 downto 0) := "00" & x"100000";
   signal i_frame_addr2 : std_logic_vector(25 downto 0) := "00" & x"200000";
   signal i_frame_addr3 : std_logic_vector(25 downto 0) := "00" & x"300000";
   signal i0_line_offset : integer range 0 to 8191 := 0;
   signal i1_line_offset : integer range 0 to 8191 := 1024;
   signal i2_line_offset : integer range 0 to 8191 := 1024;
   signal i3_line_offset : integer range 0 to 8191 := 0;
   signal i0_words_read : integer range 0 to 511 := 0;
   signal i1_words_read : integer range 0 to 511 := 0;
   signal i2_words_read : integer range 0 to 511 := 0;
   signal i3_words_read : integer range 0 to 511 := 0;
   signal i0_line_count : integer range 0 to 511 := 0;
   signal i1_line_count : integer range 0 to 511 := 0;
   signal i2_line_count : integer range 0 to 511 := 0;
   signal i3_line_count : integer range 0 to 511 := 0;
   signal i0_rd_data : std_logic_vector(31 downto 0) := x"00000000";
   signal i1_rd_data : std_logic_vector(31 downto 0) := x"11111111";
   signal i2_rd_data : std_logic_vector(31 downto 0) := x"22222222";
   signal i3_rd_data : std_logic_vector(31 downto 0) := x"33333333";
   signal i0_burst_available : std_logic := '1';
   signal i1_burst_available : std_logic := '1';
   signal i2_burst_available : std_logic := '1';
   signal i3_burst_available : std_logic := '1';
   signal i_burst_length : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(15, 6)); -- Actual burst length = 16, but RAM adds 1 automatically
	
   signal i_mport_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;

 	--Outputs
   signal o0_rd_enable : std_logic;
   signal o1_rd_enable : std_logic;
   signal o2_rd_enable : std_logic;
   signal o3_rd_enable : std_logic;
	
   signal o_mport_miso : typ_mctl_mport_miso := init_mctl_mport_miso;

	-- Clock period definitions
   constant i_clk_period : time := 9.259 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpt_ovm_mux PORT MAP (
          i_clk => i_clk,
          i_reset => i_reset,
          i0_frame_count => i0_frame_count,
          i1_frame_count => i1_frame_count,
          i2_frame_count => i2_frame_count,
          i3_frame_count => i3_frame_count,
          i_frame_addr0 => i_frame_addr0,
          i_frame_addr1 => i_frame_addr1,
          i_frame_addr2 => i_frame_addr2,
          i_frame_addr3 => i_frame_addr3,
          i0_line_offset => i0_line_offset,
          i1_line_offset => i1_line_offset,
          i2_line_offset => i2_line_offset,
          i3_line_offset => i3_line_offset,
          i0_words_read => i0_words_read,
          i1_words_read => i1_words_read,
          i2_words_read => i2_words_read,
          i3_words_read => i3_words_read,
          i0_line_count => i0_line_count,
          i1_line_count => i1_line_count,
          i2_line_count => i2_line_count,
          i3_line_count => i3_line_count,
          i0_rd_data => i0_rd_data,
          i1_rd_data => i1_rd_data,
          i2_rd_data => i2_rd_data,
          i3_rd_data => i3_rd_data,
          i0_burst_available => i0_burst_available,
          i1_burst_available => i1_burst_available,
          i2_burst_available => i2_burst_available,
          i3_burst_available => i3_burst_available,
          o0_rd_enable => o0_rd_enable,
          o1_rd_enable => o1_rd_enable,
          o2_rd_enable => o2_rd_enable,
          o3_rd_enable => o3_rd_enable,
          i_burst_length => i_burst_length,
          o_mport_miso => o_mport_miso,
          i_mport_mosi => i_mport_mosi
        );

   -- Clock process definitions
   i_clk_process :process
   begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
   end process;
 
 
   -- Clock process definitions
   rd_full_process :process
   begin
		wait until rising_edge(i_clk);
		i_mport_mosi.rd.full <= '0';
		wait for i_clk_period * 10;
		wait until rising_edge(i_clk);
		i_mport_mosi.rd.full <= '1';
		wait for i_clk_period * 10;
   end process;
	
	
	-- Clock process definitions
   cmd_full_process :process
   begin
		wait until rising_edge(i_clk);
		i_mport_mosi.cmd.full <= '0';
		wait for i_clk_period * 100;
		wait until rising_edge(i_clk);
		i_mport_mosi.cmd.full <= '1';
		wait for i_clk_period * 100;
   end process;
	
	

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		i_reset <= '1';
      wait for 100 ns;	
		i_reset <= '0';

      wait for i_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
