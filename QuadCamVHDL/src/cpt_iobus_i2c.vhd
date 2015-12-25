
library ieee;
use ieee.std_logic_1164.all;

library cctl;
use cctl.pkg_ovm.all;

library mcu;
use mcu.pkg_mcu.all;

library util; 
use util.pkg_util.all;


entity cpt_iobus_i2c is

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

end cpt_iobus_i2c;

architecture Behavioral of cpt_iobus_i2c is



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
	



	
	constant STATE_IDLE : integer := 16#00#;
	constant STATE_WRITE : integer := 16#10#;
	constant STATE_READ : integer := 16#20#;
	constant STATE_READY : integer := 16#30#;
	
	signal state : integer := STATE_IDLE;
	
					
	signal dev_addr : std_logic_vector(6 downto 0);
	signal reg_addr : std_logic_vector(7 downto 0);
	signal reg_data : std_logic_vector(7 downto 0);
	
	signal read_data : std_logic_vector(7 downto 0);
	signal read_data_strobe : std_logic;
	signal read_start : std_logic := '0';
	signal read_done : std_logic;
	
	signal write_data_available : std_logic := '0';
	signal write_data : std_logic_vector(7 downto 0) := x"55";
	signal write_data_strobe : std_logic;
	signal write_start : std_logic := '0';
	signal write_done : std_logic;
	
					

begin


	


	i2c : cpt_i2c
	port map (	
		i_clk => i_clk,		
		i_enable => i_enable,		
		i_scl_clk_div => i_scl_clk_div,									
		i_addr => dev_addr,				
		o_rd_data => read_data,		
		o_rd_data_strobe => read_data_strobe,		
		i_rd_start => read_start,		
		o_rd_done => read_done,		
		i_wr_data_available => write_data_available,		
		i_wr_data => write_data,		
		o_wr_data_strobe => write_data_strobe,		
		i_wr_start => write_start,		
		o_wr_done => write_done,				
		io_i2c_scl => io_scl,	
		io_i2c_sda => io_sda
	);	


	process(i_clk)
	begin
		if ( rising_edge(i_clk) and read_data_strobe = '1' ) then
			o_iobus_miso.read_data <= x"000000" & read_data;
		end if;
	end process;




	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			case state is 
			
				when STATE_IDLE+0 =>
					if ( i_iobus_mosi.addr_strobe = '1' ) then
						dev_addr <= "1000011"; -- OVM camera device ID
						reg_addr <= i_iobus_mosi.address(7 downto 0);
					end if;
					if ( i_iobus_mosi.write_strobe = '1' ) then
						reg_data <= i_iobus_mosi.write_data(7 downto 0);
						state <= STATE_WRITE;
					end if;
					if ( i_iobus_mosi.read_strobe = '1' ) then
						state <= STATE_READ;
					end if;
			
				when STATE_WRITE+0 =>
					write_start <= '0';
					if ( write_done = '1' ) then
						state <= state + 1;
					end if;
				when STATE_WRITE+1 =>
					write_start <= '1';
					write_data <= reg_addr;
					write_data_available <= '1';					
					if ( write_done = '0' ) then
						state <= state + 1;
					end if;
				when STATE_WRITE+2 =>
					write_start <= '0';
					if ( write_data_strobe = '1' ) then
						state <= state + 1;
					end if;
				when STATE_WRITE+3 =>
					write_data <= reg_data;
					write_data_available <= '1';		
					if ( write_data_strobe = '1' ) then
						state <= state + 1;
					end if;
				when STATE_WRITE+4 =>
					write_data_available <= '0';		
					if ( write_done = '1' ) then
						state <= STATE_READY;
					end if;
					
				when STATE_READ+0 =>
					read_start <= '0';
					if ( read_done = '1' ) then
						state <= state + 1;
					end if;
				when STATE_READ+1 =>
					read_start <= '1';
					if ( read_done = '0' ) then
						state <= state + 1;
					end if;
				when STATE_READ+2 =>
					read_start <= '0';
					if ( read_done = '1' ) then
						state <= STATE_READY;
					end if;
						
				when STATE_READY+0 =>
					o_iobus_miso.ready <= '1';
					state <= state + 1;
				when STATE_READY+1 =>
					o_iobus_miso.ready <= '0';
					state <= STATE_IDLE;
			
				when others =>
					state <= STATE_IDLE;
		
			end case;	
		end if;
	end process;
	
	
	
	
	
	
	
	

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
----			o_mcu_o_iobus_miso.ready <= i_mcu_i_iobus_mosi.addr_strobe;
----		end if;
----	end process;
--	
----	iobus_i2c_io : cpt_iobus_i2c_io 
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
--					if ( i_i_iobus_mosi.addr_strobe = '1' and (i_i_iobus_mosi.address and DEVICE_ID_MASK) = DEVICE_ID ) then
--						ip_addr <= SCCB_BUS_ADDR(7 downto 1) & i_i_iobus_mosi.read_strobe;
--						sub_addr <= i_i_iobus_mosi.address(9 downto 2);
--						write_data <= i_i_iobus_mosi.write_data(7 downto 0);
--						if ( i_i_iobus_mosi.read_strobe = '1' ) then							
--							sccb_state <= SCCB_STATE_READ;
--						elsif ( i_i_iobus_mosi.write_strobe = '1' ) then											
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
--			o_o_iobus_miso.read_data <= (others => '0');
--			o_o_iobus_miso.ready <= '0';
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
--					o_o_iobus_miso.ready <= '1';
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

