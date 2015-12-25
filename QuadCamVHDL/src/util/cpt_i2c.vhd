
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


library util;
use util.pkg_util.all;


entity cpt_i2c is

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

end cpt_i2c;

architecture Behavioral of cpt_i2c is


	signal i2c_clk_pgate : std_logic;

	signal addr : std_logic_vector(6 downto 0);
	
	signal sda_oe_n : std_logic;
	signal sda_oe : std_logic;
	signal sda_i : std_logic;	
	signal sda_o : std_logic := '1';
	
	signal scl_oe_n : std_logic;
	signal scl_oe : std_logic;
	signal scl_i : std_logic;	
	signal scl_o : std_logic := '1';
	signal scl_oddr : std_logic;
	
	
	
	signal rd_active : std_logic;
	signal wr_active : std_logic;
	
	signal write_data : std_logic_vector(7 downto 0);
	signal write_bit_count : integer;
	signal write_word_count : integer;
	
	signal read_data : std_logic_vector(7 downto 0);
	signal read_bit_count : integer;
	signal read_word_count : integer;

	signal state : integer;

	constant STATE_IDLE : integer := 16#00#;
	constant STATE_START : integer := 16#10#;
	constant STATE_WRITE : integer := 16#20#;
	constant STATE_READ : integer := 16#30#;
	constant STATE_WR_ACK : integer := 16#40#;
	constant STATE_RD_ACK : integer := 16#50#;
	constant STATE_STOP : integer := 16#60#;

	signal wr_data_strobe : std_logic;
	signal last_wr_data_strobe : std_logic;
	
	signal rd_data_strobe : std_logic;
	signal last_rd_data_strobe : std_logic;
	


begin

	
	sda_iobuf : iobuf
	port map (
		io => io_i2c_sda,
		i => sda_o,
		o => sda_i,
		t => sda_oe_n
	);
	
	
	
	scl_iobuf : iobuf
	port map (
		io => io_i2c_scl,
		i => scl_oddr,
		o => scl_i,
		t => scl_oe_n
	);
	
	
--	-- TODO: add clock streching support
--	scl_oddr2 : oddr2
--	port map (
--		Q => scl_oddr, 
--		C0 => i_clk,
--		C1 => i_clk,
--		CE => i2c_clk_pgate,
--		D0 => scl_o,
--		D1 => scl_o,
--		R => '0',
--		S => '0'
--	);
	
	scl_fd : fd
	port map (
		Q => scl_oddr,
		D => scl_o,
		C => i_clk
	);


	i2c_clk_gate : cpt_clk_gate
	port map (
		i_clk => i_clk,
		i_enable => '1',
		i_div => i_scl_clk_div,
		o_clk_pgate => i2c_clk_pgate,
		o_clk_ngate => open
	);
	
	



	-- One-shot filters
	-- data strobes changes with i2c clock, but we need strobe width == period(i_clk)
	
	o_wr_data_strobe <= wr_data_strobe and not last_wr_data_strobe;

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			last_wr_data_strobe <= wr_data_strobe;
		end if;
	end process;
	
	
	o_rd_data_strobe <= rd_data_strobe and not last_rd_data_strobe;

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			last_rd_data_strobe <= rd_data_strobe;
		end if;
	end process;
	


	scl_oe_n <= not scl_oe;
	sda_oe_n <= not sda_oe;

	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
		
			if ( i_enable = '0' ) then
				scl_o <= '1';
				scl_oe <= '1';
				sda_o <= '1';
				sda_oe <= '0';
				o_rd_done <= '0';
				o_wr_done <= '0';
				rd_data_strobe <= '0';
				wr_data_strobe <= '0';
				rd_active <= '0';
				wr_active <= '0';
				state <= STATE_IDLE;
			
			elsif ( i2c_clk_pgate = '1' ) then							
				
				case state is 
					when STATE_IDLE+0 =>
						scl_o <= '1';
						scl_oe <= '1';
						sda_o <= '1';
						sda_oe <= '0';
						o_rd_done <= '1';
						o_wr_done <= '1';
						rd_data_strobe <= '0';
						wr_data_strobe <= '0';
						rd_active <= '0';
						wr_active <= '0';
						if ( i_rd_start = '1' ) then
							addr <= i_addr;
							read_word_count <= 1;
							rd_active <= '1';
							o_rd_done <= '0';
							state <= STATE_START;
						end if;
						if ( i_wr_start = '1' ) then
							addr <= i_addr;
							wr_active <= '1';
							o_wr_done <= '0';
							state <= STATE_START;
						end if;
					
					when STATE_START+0 | STATE_START+1 =>
						scl_o <= '1';
						scl_oe <= '1';
						sda_o <= '1';
						sda_oe <= '1';
						state <= state + 1;
					
					when STATE_START+2 | STATE_START+3 =>
						scl_o <= '1';
						sda_o <= '0';					
						state <= state + 1;
					
					when STATE_START+4 =>
						scl_o <= '0';
						sda_o <= '0';					
					   write_data <= addr & rd_active;	-- LSb R/W bit: 0:write,1:read
						write_bit_count <= 7;
						state <= STATE_WRITE;
						

					when STATE_WRITE+0 =>	
						wr_data_strobe <= '0';
						scl_o <= '0';
						sda_o <= write_data(write_bit_count);
						sda_oe <= '1';
						state <= state + 1;

					when STATE_WRITE+1 | STATE_WRITE+2 =>
						scl_o <= '1';
						state <= state + 1;
					
					when STATE_WRITE+3 =>
						scl_o <= '0';			
						if ( write_bit_count = 0 ) then
							state <= STATE_WR_ACK;
						else 
							write_bit_count <= write_bit_count - 1;
							state <= STATE_WRITE;
						end if;
						
									
		
					when STATE_WR_ACK+0 =>	
						scl_o <= '0';
						sda_o <= '0';
						sda_oe <= '0';
						state <= state + 1;

					when STATE_WR_ACK+1 | STATE_WR_ACK+2 =>
						scl_o <= '1';
						sda_o <= '0';
						state <= state + 1;
					
					when STATE_WR_ACK+3 =>
						scl_o <= '0';
						state <= STATE_STOP; -- Default here if the following conditions are not met
						if ( rd_active = '1' and read_word_count /= 0 ) then
							read_word_count <= read_word_count - 1;
							read_bit_count <= 7;
							state <= STATE_READ;
						end if;
						if ( wr_active = '1' and i_wr_data_available = '1' ) then
							wr_data_strobe <= '1';
							write_data <= i_wr_data;
							write_bit_count <= 7;
							state <= STATE_WRITE;
						end if;
						
						
						
						
					
					when STATE_READ+0 =>	
						--write_data_strobe <= '0';
						scl_o <= '0';
						sda_oe <= '0';
						state <= state + 1;

					when STATE_READ+1 =>
						scl_o <= '1';
						state <= state + 1;
					
					when STATE_READ+2 =>
						state <= state + 1;
					
					when STATE_READ+3 =>
						scl_o <= '0';
						read_data(read_bit_count) <= sda_i;
						if ( read_bit_count = 0 ) then
							state <= STATE_RD_ACK;
						else 						
							read_bit_count <= read_bit_count - 1;
							state <= STATE_READ;
						end if;
						
						
						
						
					when STATE_RD_ACK+0 =>	
						scl_o <= '0';
						sda_o <= '1';
						sda_oe <= '1';
						rd_data_strobe <= '0';
						state <= state + 1;

					when STATE_RD_ACK+1 | STATE_RD_ACK+2 =>
						scl_o <= '1';
						sda_o <= '1';
						state <= state + 1;
					
					when STATE_RD_ACK+3 =>
						scl_o <= '0';
						o_rd_data <= read_data;
						rd_data_strobe <= '1';
						state <= STATE_STOP; -- Default here if the following conditions are not met
						if ( rd_active = '1' and read_word_count /= 0 ) then
							read_word_count <= read_word_count - 1;
							read_bit_count <= 8;
							state <= STATE_READ;
						end if;
						
						
					when STATE_STOP+0 | STATE_STOP+1=>
						scl_o <= '0';
						sda_o <= '0';
						sda_oe <= '1';
						state <= state + 1;
						
					when STATE_STOP+2 | STATE_STOP+3 =>
						scl_o <= '1';
						sda_o <= '0';
						state <= state + 1;
						
					when STATE_STOP+4 | STATE_STOP+5 =>
						scl_o <= '1';
						sda_o <= '1';
						state <= state + 1;
						
					when STATE_STOP+6 =>
						scl_o <= '1';
						sda_o <= '1';
						sda_oe <= '0';
						state <= STATE_IDLE;
						
											
				
					when others =>
						state <= STATE_IDLE;
				end case;		
			end if;
		end if;
	end process;
	














end Behavioral;

