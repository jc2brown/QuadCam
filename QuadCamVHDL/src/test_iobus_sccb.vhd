
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

library cctl;
use cctl.pkg_ovm.all;

library mcu;
use mcu.pkg_mcu.all;



entity test_iobus_sccb is
end test_iobus_sccb;

architecture Behavioral of test_iobus_sccb is


	component cpt_iobus_sccb is

		generic (
			DEVICE_ID : std_logic_vector(31 downto 0);
			DEVICE_ID_MASK : std_logic_vector(31 downto 0)
		);
		
		port (
	
			i_clk : in std_logic;
			i_enable : in std_logic;
			
			i_iobus_mosi : in typ_mcu_iobus_mosi;
			o_iobus_miso : out typ_mcu_iobus_miso;
			
			i_scl_clk_div : in integer;
			
			io_scl : inout std_logic;
			io_sda : inout std_logic
		
		);

	end component;


	signal iobus_mosi : typ_mcu_iobus_mosi := init_mcu_iobus_mosi;
	signal iobus_miso : typ_mcu_iobus_miso := init_mcu_iobus_miso;
	
	signal read_data : std_logic_vector(7 downto 0);
	

	constant MCU_FREQ : integer := 108_000_000;
	constant I2C_FREQ : integer := 100_000;
	
	constant MCU_HALF_PERIOD : time := 1 ns * 1e9 / real(MCU_FREQ);
	
	signal clk : std_logic;
	signal enable : std_logic;
	
	signal scl_clk_div : integer := MCU_FREQ / (2*8*I2C_FREQ);

	signal scl : std_logic := 'H';
	signal sda : std_logic := 'H';
	
	
	
	
	

begin

	
	
	
	
	scl_pullup : pullup
	port map (
		o => scl
	);
	
	sda_pullup : pullup
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
		iobus_mosi.address <= x"F0000055";
		iobus_mosi.addr_strobe <= '1';
		iobus_mosi.write_data <= x"000000AA";
		iobus_mosi.write_strobe <= '1';
		wait until rising_edge(clk);
		iobus_mosi.address <= x"00000000";
		iobus_mosi.addr_strobe <= '0';
		iobus_mosi.write_data <= x"00000000";
		iobus_mosi.write_strobe <= '0';		
		wait until iobus_miso.ready = '1';
		
		wait until rising_edge(clk);
		iobus_mosi.address <= x"F0000055";
		iobus_mosi.addr_strobe <= '1';
		iobus_mosi.read_strobe <= '1';
		wait until rising_edge(clk);
		iobus_mosi.address <= x"00000000";
		iobus_mosi.addr_strobe <= '0';
		iobus_mosi.read_strobe <= '0';		
		wait until iobus_miso.ready = '1';
		read_data <= iobus_miso.read_data(7 downto 0);
		
		wait;
		
	end process;
		
	
	
	
	iobus_sccb : cpt_iobus_sccb
	generic map (
		DEVICE_ID => x"F0000000",
		DEVICE_ID_MASK => x"FC000000"
	)
	port map (
		i_clk => clk,
		i_enable => '1',
		
		i_iobus_mosi => iobus_mosi,
		o_iobus_miso => iobus_miso,
		
		i_scl_clk_div => scl_clk_div,
		
		io_scl => scl,
		io_sda => sda
	);



end Behavioral;

