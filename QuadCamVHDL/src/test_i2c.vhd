
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

entity test_i2c is
end test_i2c;

architecture Behavioral of test_i2c is


	component cpt_i2c is

		port (
		
			i_clk : in std_logic;
			i_enable : in std_logic;
				
			i_scl_clk_div : in integer;
									
			i_addr : in std_logic_vector(6 downto 0);
					
			o_rd_data : out std_logic_vector(7 downto 0);
			o_rd_data_strobe : out std_logic;
			i_rd_start : in std_logic;
			o_rd_done : out std_logic;
			
			i_wr_data_available : in std_logic;
			i_wr_data : in std_logic_vector(7 downto 0);
			o_wr_data_strobe : out std_logic;
			i_wr_start : in std_logic;
			o_wr_done : out std_logic;		
		
			io_i2c_scl : inout std_logic;
			io_i2c_sda : inout std_logic
		
		);	

	end component;


	constant MCU_FREQ : integer := 108_000_000;
	constant I2C_FREQ : integer := 100_000;
	
	constant MCU_HALF_PERIOD : time := 1 ns * 1e9 / real(MCU_FREQ);
	
	signal clk : std_logic;
	signal enable : std_logic;
	
	signal scl_clk_div : integer := MCU_FREQ / (2*8*I2C_FREQ);

	signal scl : std_logic := 'H';
	signal sda : std_logic := 'H';

	signal addr : std_logic_vector(6 downto 0) := "1001001";	
	signal rd_data : std_logic_vector(7 downto 0);
	signal rd_data_strobe : std_logic;
	signal rd_start : std_logic := '0';
	signal rd_done : std_logic;
	
	signal wr_data_available : std_logic := '0';
	signal wr_data : std_logic_vector(7 downto 0) := x"55";
	signal wr_data_strobe : std_logic;
	signal wr_start : std_logic := '0';
	signal wr_done : std_logic;


begin

	
	scl_pullup : pullup
	port map (
		o => scl
	);
	
	sda_pullup : pulldown
	port map (
		o => sda
	);

	process
	begin
		enable <= '0';
		wait for 15 us;
		enable <= '1';
		wait;
	end process;


	process
	begin
		wait for 10 us;
		loop
			clk <= '1';
			wait for MCU_HALF_PERIOD;
			clk <= '0';
			wait for MCU_HALF_PERIOD;
		end loop;
	end process;


	

	process
	begin
	
		wait for 100 us;
		wait until rising_edge(clk);
		wr_start <= '1';
		wait until wr_done = '0';
		wr_start <= '0';		
		wr_data_available <= '1';
		wait until wr_data_strobe = '1';
		wait until wr_data_strobe = '0';
		wr_data_available <= '0';
		wait until wr_done = '1';
		
		wait for 100 us;
		wait until rising_edge(clk);
		wr_start <= '1';
		wait until wr_done = '0';
		wr_start <= '0';		
		wr_data_available <= '1';
		wr_data <= x"55";
		wait until wr_data_strobe = '1';
		wait until wr_data_strobe = '0';
		wr_data_available <= '1';
		wr_data <= x"81";
		wait until wr_data_strobe = '1';
		wait until wr_data_strobe = '0';
		wr_data_available <= '0';
		wait until wr_done = '1';
		
		
		wait for 100 us;
		wait until rising_edge(clk);
		rd_start <= '1';
		wait until rd_done = '0';
		rd_start <= '0';		
		wait until wr_data_strobe = '1';
		wait until wr_data_strobe = '0';
		wait until rd_done = '1';
		
		
		
		wait;
	end process;


	i2c : cpt_i2c
	port map (	
		i_clk => clk,		
		i_enable => enable,		
		i_scl_clk_div => scl_clk_div,									
		i_addr => addr,				
		o_rd_data => rd_data,		
		o_rd_data_strobe => rd_data_strobe,		
		i_rd_start => rd_start,		
		o_rd_done => rd_done,		
		i_wr_data_available => wr_data_available,		
		i_wr_data => wr_data,		
		o_wr_data_strobe => wr_data_strobe,		
		i_wr_start => wr_start,		
		o_wr_done => wr_done,				
		io_i2c_scl => scl,		
		io_i2c_sda => sda	
	);	





	



end Behavioral;

