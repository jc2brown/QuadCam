
library ieee;
use ieee.std_logic_1164.all;

library cctl;
use cctl.pkg_ovm.all;

library mcu;
use mcu.pkg_mcu.all;

library util; 
use util.pkg_util.all;


entity cpt_sccb_master is

	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0)
	);
	
	port (
	
		i_clk : in std_logic;
		i_enable : in std_logic;
		
		i_iobus_mosi : in typ_mcu_iobus_mosi;
		o_iobus_miso : out typ_mcu_iobus_miso;
		
		i_scl_div : in integer;
		i_xvclk_div : in integer;
		
		io_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_sccb_mosi : out typ_ovm_sccb_mosi
	
	);

end cpt_sccb_master;

architecture Behavioral of cpt_sccb_master is

	constant SCCB_BUS_ADDR : std_logic_vector(7 downto 0) := x"42";

	constant SCCB_STATE_IDLE : integer := 16#0000#;		
	constant SCCB_STATE_WRITE : integer := 16#0010#;
	constant SCCB_STATE_READ : integer := 16#0020#;

	signal sccb_state : integer := SCCB_STATE_IDLE;

	signal ip_addr : std_logic_vector(7 downto 0);
	signal sub_addr : std_logic_vector(7 downto 0);
	signal read_data : std_logic_vector(7 downto 0);
	signal write_data : std_logic_vector(7 downto 0);
	
	signal sccb_read_data : std_logic_vector(8 downto 0);
	signal sccb_write_data : std_logic_vector(8 downto 0);

	signal sccb_ip_start : std_logic;
	signal sccb_addr_start : std_logic;
	signal sccb_write_start : std_logic;
	signal sccb_read_start : std_logic;


	signal sccb_write_enable : std_logic;	
	signal sccb_read_enable : std_logic;
	
	signal sccb_done : std_logic;
	signal sccb_ip_done : std_logic;
	signal sccb_addr_done : std_logic;
	signal sccb_write_done : std_logic;
	signal sccb_read_done : std_logic;
	
	
	signal scl_pgate : std_logic;
	signal scl_ngate : std_logic;
	
	
	signal sccb_io_state : integer := SCCB_STATE_IDLE;
	
					
	constant SCCB_IO_STATE_IDLE : integer := 16#0000#;
	constant SCCB_IO_STATE_WRITE : integer := 16#0010#;
	constant SCCB_IO_STATE_READ : integer := 16#0020#;
	constant SCCB_IO_STATE_DONE : integer := 16#0020#;
					
					

begin

	o_sccb_mosi.pwdn <= not i_enable;
	
--	o_sccb_mosi.scl <= '1';		
--	io_sccb_bidir.sda <= 'Z';


	cam_xvclk_clkout : cpt_clkout
	generic map (
		CLK_DIV2 => 3
	)
	port map (
		i_enable => i_enable,
		i_clk => i_clk,
		i_clk_div => i_xvclk_div,
		o_clk => o_sccb_mosi.xvclk
	);	
	
	
	
	
	
	


	i2c : cpt_i2c
	port map (	
		i_clk => clk,		
		i_enable => enable,		
		i_clk_div => clk_div,									
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
		io_i2c_scl => o_sccb_mosi.scl,		
		io_i2c_sda => io_sccb_bidir_sda	
	);	




	
	
	
	
	

	--o_clk => o_sccb_mosi.scl
	
	
	
	
--	sccb_scl_gate : cpt_clk_gate
--	port map (
--		i_clk => i_clk,
--		i_enable => i_enable,
--		i_div => i_scl_div,
--		o_clk_pgate => scl_pgate,
--		o_clk_ngate => scl_ngate
--	);	



	
--	
--	sccb_write_counter : cpt_upcounter
----	generic map (
----		INIT => 0
----	);
--	port map ( 
--		i_clk => i_clk,
--		i_enable => scl_pgate,
--		i_lowest => 0,
--		i_highest => 9,
--		i_increment => 1,
--		i_clear => sccb_done,
--		o_count => open,
--		o_carry => sccb_write_done
--	);		
--	
--	
--	
--	
--
--	sccb_read_upcounter : cpt_upcounter
----	generic map (
----		INIT => 0
----	);
--	port map ( 
--		i_clk => i_clk,
--		i_enable => scl_pgate,
--		i_lowest => 0,
--		i_highest => 9,
--		i_increment => 1,
--		i_clear => sccb_done,
--		o_count => open,
--		o_carry => sccb_read_done
--	);		
--
--	
--	
--
----	process(i_clk)
----	begin
----		if ( rising_edge(i_clk) ) then
----			o_mcu_iobus_miso.ready <= i_mcu_iobus_mosi.addr_strobe;
----		end if;
----	end process;
--	
----	sccb_master_io : cpt_sccb_master_io 
----	port map (
----		i_clk <= i_clk,
----		i_start_ip <= sccb_start_ip,
----		i_start_addr <= sccb_start_addr,
----		i_start_write <= sccb_start_write,
----		i_start_read <= sccb_start_read,
----		
----		io_sccb_bidir <= io_sccb_bidir,
----		o_sccb_mosi <= o_sccb_mosi
----	
----	)


--
--
--	process(i_clk)
--	begin
--		if ( rising_edge(i_clk) ) then
--		
--			sccb_ip_start <= '0';		
--			sccb_addr_start <= '0';	
--			sccb_write_start <= '0';	
--			sccb_read_start <= '0';		
--				
--			case sccb_state is 						
--						
--				when SCCB_STATE_IDLE =>
--					if ( i_iobus_mosi.addr_strobe = '1' and (i_iobus_mosi.address and DEVICE_ID_MASK) = DEVICE_ID ) then
--						ip_addr <= SCCB_BUS_ADDR(7 downto 1) & i_iobus_mosi.read_strobe;
--						sub_addr <= i_iobus_mosi.address(9 downto 2);
--						write_data <= i_iobus_mosi.write_data(7 downto 0);
--						if ( i_iobus_mosi.read_strobe = '1' ) then							
--							sccb_state <= SCCB_STATE_READ;
--						elsif ( i_iobus_mosi.write_strobe = '1' ) then											
--							sccb_state <= SCCB_STATE_WRITE;
--						end if;
--					end if;
--					
--										
--				when SCCB_STATE_WRITE+0 =>
--					if ( sccb_done = '1' ) then
--						sccb_ip_start <= '1';
--						sccb_state <= sccb_state + 1;
--					end if;					
--										
--				when SCCB_STATE_WRITE+1 =>
--					if ( sccb_ip_done = '1' ) then
--						sccb_addr_start <= '1';
--						sccb_state <= sccb_state + 1;
--					end if;
--										
--				when SCCB_STATE_WRITE+2 =>
--					if ( sccb_addr_done = '1' ) then
--						sccb_write_start <= '1';
--						sccb_state <= SCCB_STATE_IDLE;
--					end if;
--										
--				when SCCB_STATE_WRITE+3 =>
--					if ( sccb_write_done = '1' ) then
--						sccb_state <= SCCB_STATE_IDLE;
--					end if;
--					
--										
--				when SCCB_STATE_READ+0 =>
--					if ( sccb_done = '1' ) then
--						sccb_ip_start <= '1';
--						sccb_state <= sccb_state + 1;
--					end if;					
--										
--				when SCCB_STATE_READ+1 =>
--					if ( sccb_ip_done = '1' ) then
--						sccb_addr_start <= '1';
--						sccb_state <= sccb_state + 1;
--					end if;
--										
--				when SCCB_STATE_READ+2 =>
--					if ( sccb_addr_done = '1' ) then
--						sccb_read_start <= '1';
--						sccb_state <= sccb_state + 1;
--					end if;
--										
--				when SCCB_STATE_READ+3 =>
--					if ( sccb_read_done = '1' ) then
--						sccb_state <= SCCB_STATE_IDLE;
--					end if;
--									
--				when others =>
--					sccb_state <= SCCB_STATE_IDLE;
--			
--			end case;
--		end if;
--	end process;
--
--	
--	process(i_clk)
--	begin
--		if ( rising_edge(i_clk) ) then
--			
--			o_iobus_miso.read_data <= (others => '0');
--			o_iobus_miso.ready <= '0';
--		
--			case sccb_io_state is 
--			
--				when SCCB_IO_STATE_IDLE+0 =>
--					sccb_done <= '1';
--					sccb_ip_done <= '0';
--					sccb_addr_done <= '0';
--					sccb_write_done <= '0';
--					sccb_read_done <= '0';
--					if ( sccb_ip_start = '1' ) then
--						sccb_done <= '0';
--						sccb_write_data <= ip_addr & 'Z';
--						sccb_io_state <= SCCB_IO_STATE_WRITE;						
--						--sccb_io_state <= SCCB_IO_STATE_IP;
--					end if;
--					if ( sccb_addr_start = '1' ) then
--						sccb_done <= '0';
--						sccb_write_data <= sub_addr & 'Z';
--						sccb_io_state <= SCCB_IO_STATE_WRITE;		
--						--sccb_io_state <= SCCB_IO_STATE_ADDR;
--					end if;
--					if ( sccb_write_start = '1' ) then
--						sccb_done <= '0';
--						sccb_write_data <= write_data & 'Z';
--						sccb_io_state <= SCCB_IO_STATE_WRITE;
--					end if;
--					if ( sccb_read_start = '1' ) then
--						sccb_done <= '0';
--						sccb_io_state <= SCCB_IO_STATE_READ;
--					end if;
--					
--					
--				when SCCB_IO_STATE_WRITE+0 =>
--					sccb_write_enable <= '1';
--					sccb_io_state <= sccb_io_state + 1;
--										
--				when SCCB_IO_STATE_WRITE+1 =>
--					if ( sccb_write_done = '1' ) then 
--						sccb_io_state <= sccb_io_state + 1;
--					else 
--						io_sccb_bidir.sda <= sccb_write_data(0);
--						sccb_write_data <= '0' & sccb_write_data(8 downto 1);
--					end if;
--								
--				when SCCB_IO_STATE_WRITE+2 =>
--					o_iobus_miso.ready <= '1';
--					sccb_io_state <= SCCB_IO_STATE_DONE;
--			
--			
--				when SCCB_IO_STATE_DONE+0 =>				
--					sccb_ip_done <= '1';
--					sccb_addr_done <= '1';
--					sccb_write_done <= '1';
--					sccb_read_done <= '1';
--					sccb_io_state <= SCCB_IO_STATE_IDLE;
--						
--					
--					
--				when others =>
--					null;
--					
--			end case;
--					
--		
--		end if;	
--	end process;
--





















end Behavioral;

