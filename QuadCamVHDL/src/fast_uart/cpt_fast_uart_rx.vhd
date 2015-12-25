
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;




library mcu;
use mcu.pkg_mcu.all;


--library fifo;
--use fifo.pkg_fifo_parameters.all;
--use fifo.pkg_fifo.all;


library fast_uart;
use fast_uart.pkg_fast_uart.all;


entity cpt_fast_uart_rx is

	generic (
		DEVICE_ID : std_logic_vector(31 downto 0);
		DEVICE_ID_MASK : std_logic_vector(31 downto 0)
	);

	port (

		 clk : in std_logic;
		 reset : in std_logic;
		 enable : in std_logic;
		
		 baud_div : in integer;
		 
		i_mcu_iobus_mosi : in typ_mcu_iobus_mosi;
		o_mcu_iobus_miso : out typ_mcu_iobus_miso;	
		 
		 empty : out std_logic;
		 full : out std_logic;
		
		 rxd : in std_logic
	);
	
end cpt_fast_uart_rx;

architecture cpt of cpt_fast_uart_rx is
	
	
	component cpt_uart_rx_fifo is
		port (
			CLK                       : in  std_logic;
			WR_ACK                    : out std_logic;
			VALID 							: out std_logic;
			RST                       : in  std_logic;
			WR_EN 		     				: in  std_logic;
			RD_EN                     : in  std_logic;
			DIN                       : in  std_logic_vector(8-1 downto 0);
			DOUT                      : out std_logic_vector(8-1 downto 0);
			FULL                      : out std_logic;
			EMPTY                     : out std_logic
		);
	end component;
  
	
	signal fifo_wen : std_logic := '0';
	signal fifo_ren : std_logic := '0';
	signal fifo_in : std_logic_vector(7 downto 0) := (others => '0');
	signal fifo_out : std_logic_vector(7 downto 0);
	signal fifo_word_in : std_logic_vector(15 downto 0) := (others => '0');
	signal fifo_word_out : std_logic_vector(15 downto 0);
	signal fifo_ack : std_logic;
	signal fifo_ack_del : std_logic;
	signal fifo_ack_del2 : std_logic;
	signal fifo_ack_del3 : std_logic;
	signal fifo_valid : std_logic;
	signal fifo_full : std_logic;
	signal fifo_empty : std_logic;





	constant RX_LINE_IDLE : std_logic := '1';
	constant START_BIT : std_logic := not RX_LINE_IDLE;
	constant STOP_BIT : std_logic := RX_LINE_IDLE;
	
	signal ref : std_logic;
	signal rxd_lpf : std_logic;
	signal last_rxd : std_logic;

	constant STAGE_RESET : integer := 0;
	constant STAGE_IDLE : integer := 1;
	constant STAGE_HOLDOFF : integer := 2;
	constant STAGE_RX : integer := 10;
	
	signal state : integer range 0 to 15;
	signal count : integer;
	
	signal bitpoint : std_logic_vector(10 downto 0) := "00000000001";
	
	signal dbnc_count : integer;
	
	signal rx_in : std_logic;
	signal rx_buf : std_logic_vector(9 downto 0);
	signal rx_byte : std_logic_vector(7 downto 0);
	signal rx_en : std_logic;
	signal rx_we : std_logic;
	
	signal clk_en : std_logic;
	
	signal is_start_bit : std_logic;
	signal is_stop_bit : std_logic;

	
	signal bcount : integer;
	
begin



	rx_fifo  : cpt_uart_rx_fifo 
    port map (
           CLK                       => clk,
           RST                       => reset,
           WR_EN 		     				 => fifo_wen,
           RD_EN                     => fifo_ren,
           DIN                       => fifo_in,
           DOUT                      => fifo_out,
           WR_ACK                    => fifo_ack,
           VALID                    => fifo_valid,
           FULL                      => fifo_full,
           EMPTY                     => fifo_empty
	);
	
	
	
	fifo_ren <= i_mcu_iobus_mosi.read_strobe when ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) else '0';
	
	fifo_in <= rx_byte;	
			
	o_mcu_iobus_miso.read_data <= x"000000" & fifo_out;		
			
	fifo_wen <= rx_we;
	
	empty <= fifo_empty;
	
	o_mcu_iobus_miso.ready <= fifo_valid;


	rx_byte <= rx_buf(rx_buf'left-1 downto 1);
						
	rx_in <= rxd;

	is_start_bit <= '1' when bitpoint(9) = '1' else '0';
	is_stop_bit <= '1' when bitpoint(0) = '1' else '0';


	-- Baud rate clk_en generator 
	process (clk)
		begin  
			if ( rising_edge(clk) ) then
				if ( rx_en /= '1' ) then
					bcount <= 0;
					clk_en <= '0';
				elsif (bcount = 0)then
					bcount <= baud_div;
					clk_en <= '1';
				else
					bcount <= bcount - 1;
					clk_en <= '0';
				end if;
			end if;
	end process;
	
	
	

	process(clk)
	begin		
		if ( falling_edge(clk) ) then
			if ( reset /= '0' ) then
				dbnc_count <= 0;	
			elsif ( rx_in = last_rxd ) then
				if ( dbnc_count = 0 ) then
					rxd_lpf <= rx_in;
				else
					dbnc_count <= dbnc_count - 1;
				end if;
			else
				last_rxd <= rx_in;
				dbnc_count <= 0;
			end if;
		end if;
	end process;
	

	process(clk)
	begin
		
			
		if ( falling_edge(clk) ) then
			if ( reset /= '0' ) then
				rx_buf <= (others =>RX_LINE_IDLE);
				rx_en <= '0';
				rx_we <= '0';
				state <= STAGE_RESET;
			else
				case state is
				
					when STAGE_RESET =>
						rx_buf <= (others => RX_LINE_IDLE);
						rx_en <= '0';
						rx_we <= '0';
						state <= STAGE_IDLE;
						
					when STAGE_IDLE =>
						rx_buf <= (others => RX_LINE_IDLE);
						rx_en <= '0';
						rx_we <= '0';	
						bitpoint <= "00000000001";				
						if ( rxd_lpf = START_BIT ) then			-- Wait for a start bit
							rx_we <= '0';
							bitpoint <= "10000000000";						
							state <= STAGE_HOLDOFF;
							count <= 0;
						end if;
					
					when STAGE_HOLDOFF =>
						if ( count = 0 and rxd_lpf = START_BIT ) then
							rx_en <= '1';
							state <= STAGE_RX;
						elsif ( count = 0 and rxd_lpf /= START_BIT ) then
							state <= STAGE_IDLE;
						else
							count <= count - 1;
						end if;						
					
					-- Shift bits in
					when STAGE_RX =>
						if ( bitpoint(0) = '1' ) then
							state <= STAGE_IDLE;
							rx_en <= '0';
							-- Write rx byte only if a stop bit was seen
							if ( rx_buf(rx_buf'left) = STOP_BIT ) then
								rx_we <= '1';
							end if;
						elsif ( clk_en = '1' ) then 
							rx_buf <= rxd_lpf & rx_buf(rx_buf'left downto 1);
							bitpoint <= bitpoint(0) & bitpoint(10 downto 1);
						end if;	
						
					when others =>
						state <= STAGE_IDLE;
						
				end case;		
			end if;
		end if;
	end process;

	
end cpt;