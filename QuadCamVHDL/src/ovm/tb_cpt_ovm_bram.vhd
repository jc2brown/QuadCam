--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:59:04 07/16/2015
-- Design Name:   
-- Module Name:   C:/Xilinx/Projects/bram_buffer/tb_cpt_ovm_bram.vhd
-- Project Name:  bram_buffer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpt_ovm_bram
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
use ieee.numeric_std.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_cpt_ovm_bram IS
END tb_cpt_ovm_bram;
 
ARCHITECTURE behavior OF tb_cpt_ovm_bram IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpt_ovm_bram
    PORT(
			i_pclk : in std_logic;
			i_vsync : in std_logic;
			i_href : in std_logic;
			i_data : in std_logic_vector (7 downto 0);
			i_reset : in std_logic;
			
			o_rd_data : out std_logic_vector(31 downto 0);
			o_frame_number : out integer range 0 to 3;
			o_line_number : out integer range 0 to 2047;
			
			o_words_read: out integer range 0 to 511;
			i_burst_length : std_logic_vector(5 downto 0);
			o_burst_available : out std_logic;
			o_collision : out std_logic;
			
			i_clk : in std_logic;
			i_rd_enable : in std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_pclk : std_logic := '0';
   signal i_vsync : std_logic := '0';
   signal i_href : std_logic := '0';
   signal i_data : std_logic_vector(7 downto 0) := (others => '0');
   signal i_reset : std_logic := '0';
   signal i_burst_length : std_logic_vector(5 downto 0) := (others => '0');
   signal i_clk : std_logic := '0';
   signal i_rd_enable : std_logic := '0';

 	--Outputs
   signal o_rd_data : std_logic_vector(31 downto 0);
   signal o_frame_number : integer range 0 to 3;
   signal o_line_number : integer range 0 to 2047;
   signal o_words_read : integer range 0 to 511;
   signal o_burst_available : std_logic;
	
   signal o_collision : std_logic;

   -- Clock period definitions
   constant i_pclk_period : time := 41.667 ns;
   constant i_clk_period : time := 9.259 ns;
	constant tp : time := 2*i_pclk_period;
	constant tline : time := 780*tp;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpt_ovm_bram PORT MAP (
          i_pclk => i_pclk,
          i_vsync => i_vsync,
          i_href => i_href,
          i_data => i_data,
          i_reset => i_reset,
          o_rd_data => o_rd_data,
          o_frame_number => o_frame_number,
          o_line_number => o_line_number,
          o_words_read => o_words_read,
          i_burst_length => i_burst_length,
          o_burst_available => o_burst_available,
          o_collision => o_collision,
          i_clk => i_clk,
          i_rd_enable => i_rd_enable
        );

   -- Clock process definitions
   i_pclk_process :process
   begin
		i_pclk <= '0';
		wait for i_pclk_period/2;
		i_pclk <= '1';
		wait for i_pclk_period/2;
   end process;
 
   i_clk_process :process
   begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
   end process;
 

	vsync_process : process
	begin
		wait until falling_edge(i_pclk);
		i_vsync <= '1';
		wait for 4*tline;
		i_vsync <= '0';			
		wait for (512-4)*tline;
	end process;
	
	href_process : process
	begin
		i_href <= '0';
		wait for 20*tline;
		wait until falling_edge(i_pclk);
		for i in 0 to 479 loop
			i_href <= '1';
			wait for 640*tp;
			i_href <= '0';
			wait for 140*tp;
		end loop;
		wait for 12*tline;
	end process;
	
	data_process : process
	begin
		wait until rising_edge(i_href);
		--		wait until falling_edge(i_pclk);
		for i in 0 to 1279 loop
			i_data <= std_logic_vector(to_unsigned(i mod 256, i_data'length)); --mod to avoid truncation warnings everywhere
			wait for i_pclk_period;
		end loop;
	end process;


	--i_rd_enable <= o_burst_available;
	
	
	rd_proc: process
   begin		
		
		wait until rising_edge(i_clk);
		if ( o_burst_available = '1' ) then
		
			for i in 0 to 15 loop
			
				wait until rising_edge(i_clk);
				i_rd_enable <= '1';
				
			end loop;
						

			wait until rising_edge(i_clk);
			i_rd_enable <= '0';

		end if;

   end process;
	
	
	
	i_burst_length <= "010000";
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		i_reset <= '1';
		
      wait for 100 ns;	
		i_reset <= '0';
		

      wait for i_pclk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
