
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library usb;
use usb.pkg_usb.all;

entity cpt_usb is

	port (
		i_usb_ctrl_miso : in typ_usb_ctrl_miso;
		o_usb_ctrl_mosi : out typ_usb_ctrl_mosi;
		io_usb_data : inout std_logic_vector(7 downto 0);
		
		i_mcu_usb_data : in std_logic_vector(7 downto 0);
		o_mcu_usb_data : out std_logic_vector(7 downto 0);
		o_mcu_usb_ctrl_miso : out typ_usb_ctrl_miso;
		i_mcu_usb_ctrl_mosi : in typ_usb_ctrl_mosi;
		i_usb_mode : in std_logic;
		
		o_usbclk : out std_logic;
		i_fifo_data : in std_logic_vector(7 downto 0);
		o_fifo_rd_en : out std_logic;
		i_fifo_empty : in std_logic
	);

end cpt_usb;

architecture Behavioral of cpt_usb is

	signal usbclk : std_logic := '0';
	signal usbclk_n : std_logic := '1';
	
	signal txe_n_d1 : std_logic := '0';
	signal txe_n_d2 : std_logic := '0';
	
	signal fifo_rd_en : std_logic := '0';
	signal fifo_data : std_logic_vector(7 downto 0);
	
	signal usb_data : std_logic_vector(7 downto 0);
	signal usb_oe : std_logic := '0';
	
	signal usb_ctrl_mosi : typ_usb_ctrl_mosi := init_usb_ctrl_mosi;

begin



	usbclk_ibufg : ibufg
	port map (
		i => i_usb_ctrl_miso.clk,
		o => usbclk
	);
	
	usbclk_n <= not usbclk;
	
	o_usbclk <= usbclk;
		
	o_mcu_usb_ctrl_miso <= i_usb_ctrl_miso;	
		
	txe_n_d1_fd : fd
	port map (
		d => i_usb_ctrl_miso.txe_n,
		q => txe_n_d1,
		c => usbclk
	);
	
	txe_n_d2_fd : fd
	port map (
		d => txe_n_d1,
		q => txe_n_d2,
		c => usbclk_n
	);
	
	fifo_rd_en <= (not i_fifo_empty) and (not txe_n_d2);
	
	process(usbclk)
	begin
		if ( rising_edge(usbclk) and fifo_rd_en = '1' ) then
			fifo_data <= i_fifo_data;
		end if;
	end process;
	
	with i_usb_mode select usb_data <= 
		i_mcu_usb_data when '0',
		fifo_data when '1';
	
	
	with i_usb_mode select usb_oe <= 
		not i_mcu_usb_ctrl_mosi.oe_n when '0',
		not usb_ctrl_mosi.oe_n when '1';
		
	--usb_oe <= not i_mcu_usb_ctrl_mosi.oe_n when ;
	
	usb_data_iobufs :
	for i in 0 to 7 generate 
		
		usb_data_iobuf : iobuf
		port map (
			i => usb_data(i),
			o => o_mcu_usb_data(i),
			io => io_usb_data(i),
			t => usb_oe
		);
		
	end generate;
	
	wr_n_fd : fd
	port map (
		d => fifo_rd_en,
		q => usb_ctrl_mosi.wr_n,
		c => usbclk
	);

	with i_usb_mode select o_usb_ctrl_mosi <= 
		i_mcu_usb_ctrl_mosi when '0',
		usb_ctrl_mosi when '1';
	
	
end Behavioral;

