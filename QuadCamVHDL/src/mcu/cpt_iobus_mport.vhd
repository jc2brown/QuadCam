--
-- RAM/IOBus link
-- Provides an interface for the Microblaze MCU to read and write external memory via the IOBus
--

library ieee;
use ieee.std_logic_1164.all;

library mctl;
use mctl.pkg_mctl.all;

library mcu;
use mcu.pkg_mcu.all;

entity cpt_iobus_mport is
	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0)
	);
	port (
		i_clk : in std_logic;
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;
		i_mctl_mport_mosi : in typ_mctl_mport_mosi;
		o_mctl_mport_miso : out typ_mctl_mport_miso
	);
end cpt_iobus_mport;

architecture Behavioral of cpt_iobus_mport is
	signal addr_latch : std_logic_vector(31 downto 0);
	signal wr_data_latch : std_logic_vector(31 downto 0);

	constant RAMSTATE_IDLE : integer := 16#0000#;
	constant RAMSTATE_READ : integer := 16#0010#;
	constant RAMSTATE_WRITE : integer := 16#0020#;

	signal ramstate : integer := RAMSTATE_IDLE;
begin

	-- Send input clock to all other clock signals
	o_mctl_mport_miso.cmd.clk <= i_clk;
	o_mctl_mport_miso.wr.clk <= i_clk;
	o_mctl_mport_miso.rd.clk <= i_clk;

	process (i_clk)
	begin
		if rising_edge(i_clk) then
			
			-- IO Bus
			o_mcu_iobus_miso.read_data <= (others => '0');
			o_mcu_iobus_miso.ready <= '0';
			
			-- Command signal defaults
			o_mctl_mport_miso.cmd.en <= '0';
			o_mctl_mport_miso.cmd.instr <= "000";
			o_mctl_mport_miso.cmd.bl <= "000000";
			o_mctl_mport_miso.cmd.byte_addr <= (others => '0');
			
			-- Write signal defaults
			o_mctl_mport_miso.wr.en <= '0';
			o_mctl_mport_miso.wr.mask <= "0000";
			
			-- Read signal defaults
			o_mctl_mport_miso.rd.en <= '0';
			
			case ramstate is
				when RAMSTATE_IDLE+0 =>
					if ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then
						
						if ( i_mcu_iobus_mosi.Read_Strobe = '1' ) then
							addr_latch <= i_mcu_iobus_mosi.address;
							ramstate <= RAMSTATE_READ; 
						end if;
						
						if ( i_mcu_iobus_mosi.Write_Strobe = '1' ) then
							addr_latch <= i_mcu_iobus_mosi.address;
							wr_data_latch <= i_mcu_iobus_mosi.write_data;
							ramstate <= RAMSTATE_WRITE; 
						end if;
						
					end if;
					
				when RAMSTATE_READ+0 =>
					if ( i_mctl_mport_mosi.cmd.full /= '1' ) then
						o_mctl_mport_miso.cmd.en <= '1';
						o_mctl_mport_miso.cmd.instr <= "011";
						o_mctl_mport_miso.cmd.bl <= "000000";
						o_mctl_mport_miso.cmd.byte_addr <= "0000" & addr_latch(25 downto 0);
						ramstate <= ramstate + 1;
					end if;
					
				when RAMSTATE_READ+1 =>
					if ( i_mctl_mport_mosi.rd.empty = '0' ) then
						--rd.en <= '1';
						--rd.data_latch <= rd.data;
						ramstate <= ramstate + 1;
					end if;
					
				when RAMSTATE_READ+2 =>
					if ( i_mctl_mport_mosi.rd.empty = '0' ) then
						o_mctl_mport_miso.rd.en <= '1';
						o_mcu_iobus_miso.read_data <= i_mctl_mport_mosi.rd.data;
						o_mcu_iobus_miso.ready <= '1';
						ramstate <= RAMSTATE_IDLE;
					end if;
					
				when RAMSTATE_WRITE+0 =>
					if ( i_mctl_mport_mosi.wr.full /= '1' ) then
						--wr.en <= '1';
						o_mctl_mport_miso.wr.data <= wr_data_latch;
						ramstate <= ramstate + 1;
					end if;
					
				when RAMSTATE_WRITE+1 =>
					if ( i_mctl_mport_mosi.wr.full /= '1' ) then
						o_mctl_mport_miso.wr.en <= '1';
						o_mctl_mport_miso.wr.data <= wr_data_latch;
						ramstate <= ramstate + 1;
					end if;
					
				when RAMSTATE_WRITE+2 =>
					if ( i_mctl_mport_mosi.cmd.full /= '1' ) then
						o_mctl_mport_miso.cmd.en <= '1';
						o_mctl_mport_miso.cmd.instr <= "010";
						o_mctl_mport_miso.cmd.bl <= "000000";
						o_mctl_mport_miso.cmd.byte_addr <= "0000" & addr_latch(25 downto 0);
						o_mcu_iobus_miso.ready <= '1';
						ramstate <= RAMSTATE_IDLE;
					end if;
					
				when others =>
					ramstate <= RAMSTATE_IDLE;
					
			end case;
		end if;
	end process;
end Behavioral;
