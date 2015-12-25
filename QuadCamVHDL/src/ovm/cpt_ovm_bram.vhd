----------------------------------------------------------------------------------
-- Refer to cpt_ovm_bram.schdoc for diagram
-- Chris Brown / David Bell
--
-- Uses VGA signals from camera to put pixel data in BRAM, maintaining line/frame
-- count for use at MUX stage (later).
-- Allows reads from BRAM in internal clock domain, prechecked by the desired 
-- burst length.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


library util;
use util.pkg_util.all;



entity cpt_ovm_bram is
	port(
		i_pclk : in std_logic;
		i_vsync : in std_logic;
		i_href : in std_logic;
		i_data : in std_logic_vector (7 downto 0);
		i_reset : in std_logic;
		
		o_rd_data : out std_logic_vector(31 downto 0);
		o_frame_number : out integer range 0 to 3;
		o_line_number : out integer range 0 to 2047;
		
		o_words_read: out integer range 0 to 511;
		i_burst_length : std_logic_vector(5 downto 0);
		o_burst_available : out std_logic;
		o_collision : out std_logic;
		
		i_clk : in std_logic;
		i_rd_enable : in std_logic
		);
		
end cpt_ovm_bram;

architecture Behavioral of cpt_ovm_bram is
	
	COMPONENT cpt_upcounter
	generic (
		INIT : integer := -1
	);
	PORT(
		i_clk : IN std_logic;
		i_enable : IN std_logic;
		i_lowest : IN integer;
		i_highest : IN integer;
		i_increment : IN integer;
		i_clear : IN std_logic;
		i_preset : IN std_logic;          
		o_count : OUT integer;
		o_carry : OUT std_logic
		);
	END COMPONENT;
	
	signal data : std_logic_vector(31 downto 0);
	
	signal pclk : std_logic;
	signal pclk_n : std_logic;
	
	signal vsync : std_logic;	
	signal vsync_d1 : std_logic;

	signal frame_count_en : std_logic;

	signal href : std_logic;
	signal href_d1 : std_logic;
	signal line_count_en : std_logic;

	signal bytes_written : integer range 0 to 2**12-1;
	signal words_written : integer range 0 to 2**10-1;
	
	signal pixel_addr : std_logic_vector (13 downto 0);
	signal word_addr : std_logic_vector (13 downto 0);
	signal words_read : integer range 0 to 511;
	signal burst_length : integer range 0 to 63;
	signal bram_empty : std_logic;
	signal clear_count : std_logic;
	
	signal words_diff : integer range 0 to 511;


begin

	pclk_bufg : BUFG
	port map (
		O => pclk, 
		I => i_pclk 
	);
	
	pclk_n <= not pclk;
	
	vsync_fd : fd
	port map (
		D => i_vsync,
		C => pclk_n,
		Q => vsync
	);
	
	vsync_d1_fd : fd
	port map (
		D => vsync,
		C => pclk,
		Q => vsync_d1
	);
		
	frame_count_en <= (not vsync) and vsync_d1;
	
	frame_counter : cpt_upcounter
	port map (
		i_clk => pclk,
		i_enable => frame_count_en,
		i_clear => i_reset,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 3,
		i_increment => 1,
		o_count => o_frame_number,
		o_carry => open		
	);
	
	href_fd : fd
	port map (
		D => i_href,
		C => pclk_n,
		Q => href
	);
	
	href_d1_fd : fd
	port map (
		D => href,
		C => pclk,
		Q => href_d1
	);
	
	line_count_en <= href and (not href_d1);
	
	line_counter : cpt_upcounter
	generic map (INIT => 0)
	port map (
		i_clk => pclk,
		i_enable => line_count_en,
		i_clear => vsync,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 2047,
		i_increment => 1,
		o_count => o_line_number,
		o_carry => open		
	);
	
	
	bram_empty <= '1' when (words_diff = 0) else '0';
	clear_count <= (bram_empty and (not href)) or i_reset;
	
	--Tracks the number of bytes written BRAM port A
	bytes_written_counter : cpt_upcounter
	generic map (INIT => 0)
	port map (
		i_clk => pclk,
		i_enable => href,
		i_clear => clear_count,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 2047,
		i_increment => 1,
		o_count => bytes_written,
		o_carry => open		
	);
	
	-- Tracks 32-bit words written to the Block RAM
	word_written_calc : 
		words_written <= (bytes_written / 4); 
	
	-- Uses pixel number as the WRITE ADDR for BRAM, shifted up because BRAM port A is set to 8 bits
	pixel_addr_calc :
		pixel_addr <= std_logic_vector(to_unsigned((bytes_written * 8), pixel_addr'length));
	
	-- Uses word number as the READ ADDR for BRAM, shifted because BRAM port B is set to 32 bits.
	word_addr_calc :
		word_addr <= std_logic_vector(to_unsigned((words_read * 32), word_addr'length));
	
	process(i_clk)
	begin
		if ( rising_edge(i_clk) ) then
			data(7 downto 0) <= i_data;
		end if;
	end process;
	
	data(31 downto 8) <= x"000000";
	
	pixel_bram : ramb16bwer
		generic map (
			DATA_WIDTH_A => 9,
			DATA_WIDTH_B => 36,
			SIM_DEVICE => "SPARTAN6",
			SIM_COLLISION_CHECK => "NONE"		
		)
		port map (
			-- Port A Address/Control Signals: 14-bit (each) input: Port A address and control signals
			ADDRA => pixel_addr,		-- 14-bit input: A port address input
			WEA => (others => href),				-- 4-bit input: Port A byte-wide write enable input
			CLKA => pclk, 				-- 1-bit input: A port clock input
			ENA => '1', 				-- 1-bit input: A port enable input
			REGCEA => '0', 			-- 1-bit input: A port register clock enable input
			RSTA => '0', 				-- 1-bit input: A port register set/reset input

			-- Port A Data: 32-bit (each) input: Port A data
			DIA => data,			-- 32-bit input: A port data input
			DIPA => "0000", 				-- 4-bit input: A port parity input
			
			-- Port A Data: 32-bit (each) output: Port A data
			DOA => open, 				-- 32-bit output: A port data output
			DOPA => open, 				-- 4-bit output: A port parity output
			
			
			-- Port B Address/Control Signals: 14-bit (each) input: Port B address and control signals
			ADDRB => word_addr, 		-- 14-bit input: B port address input
			WEB => "0000",				-- 4-bit input: Port B byte-wide write enable input
			CLKB => i_clk, 			-- 1-bit input: B port clock input
			ENB => '1', 				-- 1-bit input: B port enable input
			REGCEB => '0', 			-- 1-bit input: B port register clock enable input
			RSTB => '0', 				-- 1-bit input: B port register set/reset input
			
			-- Port B Data: 32-bit (each) input: Port B data
			DIB => (others => '0'),		-- 32-bit input: B port data input
			DIPB => "0000",	-- 4-bit input: B port parity input
			
			-- Port B Data: 32-bit (each) output: Port B data
			DOB => o_rd_data,			-- 32-bit output: B port data output
			DOPB => open 				-- 4-bit output: B port parity output
	);
	
	
	o_words_read <= words_read;
	
	-- Calculates running total of words (32-bit) stored in BRAM
	words_diff_calc :
		words_diff <= words_written - words_read; -- written must always be higher than read
	
	burst_length_calc :
		burst_length <= to_integer(unsigned(i_burst_length));

	-- Compares desired burst to words (32-bit) available to read
	burst_avail_calc :
--		o_burst_available <= '1' when (words_diff > burst_length) or ((words_diff = burst_length) and href = '0') else '0';
		--o_burst_available <= '1' when (words_diff > burst_length) else '0';-- or ((words_diff = burst_length) and href = '0') else '0';
		--o_burst_available <= '1' when (words_diff >= burst_length); and words_written /= 0 else '0';-- or ((words_diff = burst_length) and href = '0') else '0';
		o_burst_available <= '1' when (words_diff > burst_length) else '0';
	
	
	
	o_collision <= '1' when (pixel_addr(13 downto 5) = word_addr(13 downto 5)) else '0';
	
	--Tracks the number of words (32 bit) read from the BRAM
	words_read_counter : cpt_upcounter
	generic map (INIT => 0)
	port map (
		i_clk => i_clk,
		i_enable => i_rd_enable,
		i_clear => clear_count,
		i_preset => '0',
		i_lowest => 0,
		i_highest => 511,
		i_increment => 1,
		o_count => words_read,
		o_carry => open		
	);

end Behavioral;

