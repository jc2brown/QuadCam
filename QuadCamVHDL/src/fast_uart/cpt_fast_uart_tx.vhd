
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



library mcu;
use mcu.pkg_mcu.all;


entity cpt_fast_uart_tx is

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

		txd : out std_logic
	);
	
end cpt_fast_uart_tx;


architecture Behavioral of cpt_fast_uart_tx is


	COMPONENT cpt_uart_tx_fifo
	  PORT (
		 clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 wr_en : IN STD_LOGIC;
		 rd_en : IN STD_LOGIC;
		 dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 full : OUT STD_LOGIC;
		 wr_ack : OUT STD_LOGIC;
		 empty : OUT STD_LOGIC;
		 valid : OUT STD_LOGIC
	  );
	END COMPONENT;

	
	signal clk_en : std_logic;

	signal newbyte : std_logic;
	signal newbyte_del : std_logic;

	signal outbuf : std_logic_vector(9 downto 0) := "1111111111";
	
	signal outval : std_logic_vector(7 downto 0);
	
	signal bitpoint : std_logic_vector(7 downto 0) := "00000000";
	
	--signal count : integer range 0 to 2**16-1;
	signal count : integer;
	
	signal fcount : integer range 0 to 15 := 0;	
	signal fcount_max : integer range 0 to 15 := 0;

	signal fifo_wen : std_logic := '0';
	signal fifo_ren : std_logic := '0';
	signal fifo_in : std_logic_vector(7 downto 0) := (others => '0');
	signal fifo_out : std_logic_vector(7 downto 0);
	signal fifo_ack : std_logic;
	signal fifo_full : std_logic;
	signal fifo_empty : std_logic;

	signal fifo_valid : std_logic;
	
	
	signal write_data : std_logic_vector(31 downto 0);
	signal write_strobe : std_logic;
		
	
	signal read_state : std_logic_vector(3 downto 0) := (others => '0');

begin


	 tx_fifo  : cpt_uart_tx_fifo
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
	
	

	
	write_data <= 	i_mcu_iobus_mosi.write_data;
						
	write_strobe <= i_mcu_iobus_mosi.write_strobe;
								

	fifo_in <= write_data(7 downto 0);	
	
	fifo_wen <= write_strobe when ( (i_mcu_iobus_mosi.address and DEVICE_ID_MASK) = (DEVICE_ID and DEVICE_ID_MASK) ) else '0';

	fifo_ren <= read_state(2);
	
	o_mcu_iobus_miso.ready <= fifo_ack;

	full <= fifo_full;
	
	empty <= fifo_empty;
	


	-- Baud rate clk_en generator 
	process (clk)
		begin  
			if ( enable /= '1' ) then
					count <= 0;
					clk_en <= '0';
			elsif ( rising_edge(clk) ) then
				
			   if (count = 0)then
					count <= baud_div;
					clk_en <= '1';
				else
					count <= count - 1;
					clk_en <= '0';
				end if;
			end if;
	end process;
	
	
	
	process(clk)
	begin
		if ( enable /= '1' ) then
				outbuf <= (others => '0');
				outval <= (others => '0');
		elsif ( falling_edge(clk)) then
			
			if ( read_state(2) = '1' ) then	
				outbuf <= '1' & fifo_out & '0'; 
				outval <= fifo_out;
			elsif ( clk_en = '1' ) then
				outbuf <= '1' & outbuf(9 downto 1);
			end if;
		end if;	
	end process;
	
	
	process(clk)
	begin
		if ( enable /= '1' ) then
				read_state <= (others => '0');
		elsif ( falling_edge(clk) ) then	
					
			if ( bitpoint = "00000000" and newbyte_del = '0') then
				read_state <= (clk_en and not fifo_empty) & read_state(3 downto 1);
			else
				read_state <= '0' & read_state(3 downto 1);
			end if;
		end if;
	end process;
	
	
	
	process(clk)
	begin
		if ( enable /= '1' ) then
				newbyte <= '0';
		elsif ( falling_edge(clk) ) then
			
			if ( clk_en = '1' ) then
				newbyte <= '0';
			elsif ( read_state(3) = '1' ) then
				newbyte <= '1';
			end if;
		end if;	
	end process;
	
	process(clk)
	begin
		if ( rising_edge(clk) ) then
			newbyte_del <= newbyte;
		end if;	
	end process;
	
	
	
	
	process(clk)
	begin
		if ( enable /= '1' ) then
				bitpoint <= (others => '0');
		elsif ( falling_edge(clk)) then
			
			if (clk_en /= '1') then
				
			else
				bitpoint <= newbyte_del & bitpoint(7 downto 1);
			end if;
		end if;	
	end process;
	
	

	process(clk)
	begin
		if ( enable /= '1' ) then
				txd <= '1';
		elsif ( falling_edge(clk)) then
			
			if (clk_en /= '1') then
				
			else
				txd <= outbuf(0);
			end if;
		end if;	
	end process;
	

end Behavioral;
