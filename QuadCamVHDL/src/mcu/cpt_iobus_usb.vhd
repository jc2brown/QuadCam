--
-- USB/IOBus link
-- Provides an interface for the Microblaze MCU to read and write USB via the IOBus
--

library ieee;
use ieee.std_logic_1164.all;

library usb;
use usb.pkg_usb.all;

library mcu;
use mcu.pkg_mcu.all;

entity cpt_iobus_usb is
	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0)
	);
	port (
		i_clk : in std_logic;
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;
		i_usb_data : in std_logic_vector(7 downto 0);
		o_usb_data : out std_logic_vector(7 downto 0);
		i_usb_ctrl_miso : in typ_usb_ctrl_miso;
		o_usb_ctrl_mosi : out typ_usb_ctrl_mosi
	);
end cpt_iobus_usb;

architecture Behavioral of cpt_iobus_usb is

	signal wr_data_latch : std_logic_vector(7 downto 0);
	signal rd_data : std_logic_vector(7 downto 0);

	constant USBSTATE_IDLE : integer := 16#0000#;
	constant USBSTATE_READ : integer := 16#0010#;
	constant USBSTATE_WRITE : integer := 16#0020#;

	signal usbstate : integer := USBSTATE_IDLE;
begin


	process (i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			
			-- IO Bus
			o_mcu_iobus_miso.read_data <= (others => '0');
			o_mcu_iobus_miso.ready <= '0';
			
			-- USB signal defaults
			o_usb_ctrl_mosi.rd_n <= '1';
			o_usb_ctrl_mosi.wr_n <= '1';
			o_usb_ctrl_mosi.oe_n <= '1';
			o_usb_ctrl_mosi.siwu_n <= '1';
			
			
			case usbstate is
				when USBSTATE_IDLE+0 =>
					if ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) then
						
						if ( i_mcu_iobus_mosi.Read_Strobe = '1' ) then
							usbstate <= USBSTATE_READ; 
						end if;
						
						if ( i_mcu_iobus_mosi.Write_Strobe = '1' ) then
							wr_data_latch <= i_mcu_iobus_mosi.write_data(7 downto 0);
							usbstate <= USBSTATE_WRITE; 
						end if;
						
					end if;
					
				when USBSTATE_READ+0 =>
				o_usb_ctrl_mosi.oe_n <= '0';
					if ( i_usb_ctrl_miso.rxf_n = '0' ) then					
						o_usb_ctrl_mosi.rd_n <= '0';
						usbstate <= usbstate + 1;
					end if;
					
				when USBSTATE_READ+1 =>			
				o_usb_ctrl_mosi.oe_n <= '0';		
					o_usb_ctrl_mosi.rd_n <= '0';	
					usbstate <= usbstate + 1;
					
				when USBSTATE_READ+2 =>	
				o_usb_ctrl_mosi.oe_n <= '0';	
					o_usb_ctrl_mosi.rd_n <= '0';			
					usbstate <= usbstate + 1;
					
				when USBSTATE_READ+3 =>	
				o_usb_ctrl_mosi.oe_n <= '0';
					o_usb_ctrl_mosi.rd_n <= '0';
					rd_data <= i_usb_data;				
					usbstate <= usbstate + 1;
					
				when USBSTATE_READ+4 =>		
				o_usb_ctrl_mosi.oe_n <= '0';		
					o_usb_ctrl_mosi.rd_n <= '1';
					usbstate <= usbstate + 1;
					
				when USBSTATE_READ+5 =>	
				o_usb_ctrl_mosi.oe_n <= '0';			
					o_mcu_iobus_miso.read_data <= x"000000" & rd_data;
					o_mcu_iobus_miso.ready <= '1';
					usbstate <= USBSTATE_IDLE;
					
					
				when USBSTATE_WRITE+0 =>
					if ( i_usb_ctrl_miso.txe_n = '0' ) then
						o_usb_data <= wr_data_latch(7 downto 0);
						usbstate <= usbstate + 1;
					end if;
					
				when USBSTATE_WRITE+1 =>
					o_usb_ctrl_mosi.wr_n <= '0';
					o_usb_data <= wr_data_latch(7 downto 0);
					usbstate <= usbstate + 1;
										
				when USBSTATE_WRITE+2 =>
					o_usb_ctrl_mosi.wr_n <= '0';
					o_usb_data <= wr_data_latch(7 downto 0);
					usbstate <= usbstate + 1;
										
				when USBSTATE_WRITE+3 =>
					o_usb_ctrl_mosi.wr_n <= '0';
					o_usb_data <= wr_data_latch(7 downto 0);
					usbstate <= usbstate + 1;
										
				when USBSTATE_WRITE+4 =>
					o_usb_ctrl_mosi.wr_n <= '0';
					o_usb_data <= wr_data_latch(7 downto 0);
					usbstate <= usbstate + 1;
										
				when USBSTATE_WRITE+5 =>
					o_usb_ctrl_mosi.wr_n <= '1';
					o_usb_data <= wr_data_latch(7 downto 0);
					usbstate <= usbstate + 1;
										
				when USBSTATE_WRITE+6 =>
					o_usb_ctrl_mosi.wr_n <= '1';
					o_usb_data <= wr_data_latch(7 downto 0);
					o_mcu_iobus_miso.ready <= '1';
					usbstate <= USBSTATE_IDLE;				
					
				when others =>
					usbstate <= USBSTATE_IDLE;
					
			end case;
		end if;
	end process;
end Behavioral;
