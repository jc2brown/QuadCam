--
-- Memory controller package
-- Reference ug388_Spartan6_MemoryControlBlock.pdf
--

library ieee;
use ieee.std_logic_1164.all;

library mctl;

package pkg_mctl is
	constant C3_NUM_DQ_PINS         : integer := 16;	-- External memory data width.
	constant C3_MEM_ADDR_WIDTH      : integer := 13;	-- External memory address width.
	constant C3_MEM_BANKADDR_WIDTH  : integer := 2;		-- External memory bank address width.
	constant C3_MEM_ADDR_ORDER      : string  := "ROW_BANK_COLUMN"; 
	constant C3_P0_MASK_SIZE        : integer := 4;
	constant C3_P0_DATA_PORT_SIZE   : integer := 32;
	constant C3_P1_MASK_SIZE        : integer := 4;
	constant C3_P1_DATA_PORT_SIZE   : integer := 32;


	type typ_mctl_mport_cmd_miso is record
		clk : std_logic;
		en : std_logic;
		instr : std_logic_vector(2 downto 0);
		bl : std_logic_vector(5 downto 0);
		byte_addr : std_logic_vector(29 downto 0);
	end record;

	constant init_mctl_mport_cmd_miso : typ_mctl_mport_cmd_miso := ( 
		clk => '0', 
		en => '0', 
		instr => (others => '0'), 
		bl => (others => '0'), 
		byte_addr => (others => '0') 
	);


	type typ_mctl_mport_wr_miso is record
		clk : std_logic;
		en : std_logic;
		mask : std_logic_vector(3 downto 0);
		data : std_logic_vector(31 downto 0);
	end record;

	constant init_mctl_mport_wr_miso : typ_mctl_mport_wr_miso := (
		clk => '0', 
		en => '0', 
		mask => (others => '0'), 
		data => (others => '0')	
	);


	type typ_mctl_mport_rd_miso is record
		clk : std_logic;
		en : std_logic;
	end record;

	constant init_mctl_mport_rd_miso : typ_mctl_mport_rd_miso := (
		clk => '0', 
		en => '0'	
	);


	type typ_mctl_mport_miso is record
		cmd : typ_mctl_mport_cmd_miso;
		wr : typ_mctl_mport_wr_miso;
		rd : typ_mctl_mport_rd_miso;
	end record;

	constant init_mctl_mport_miso : typ_mctl_mport_miso := (
		cmd => init_mctl_mport_cmd_miso,
		wr => init_mctl_mport_wr_miso,
		rd => init_mctl_mport_rd_miso
	);


	type typ_mctl_mport_cmd_mosi is record
		empty : std_logic;
		full : std_logic;
	end record;

	constant init_mctl_mport_cmd_mosi : typ_mctl_mport_cmd_mosi := (
		empty => '0',
		full => '0'
	);


	type typ_mctl_mport_wr_mosi is record
		empty : std_logic;
		full : std_logic;
		count : std_logic_vector(6 downto 0);
		underrun : std_logic;
		error : std_logic;
	end record;

	constant init_mctl_mport_wr_mosi : typ_mctl_mport_wr_mosi := (
		empty => '0',
		full => '0',
		count => (others => '0'),
		underrun => '0',
		error => '0'
	);


	type typ_mctl_mport_rd_mosi is record
		data : std_logic_vector(31 downto 0);
		empty : std_logic;
		full : std_logic;
		count : std_logic_vector(6 downto 0);
		overflow : std_logic;
		error : std_logic;
	end record;

	constant init_mctl_mport_rd_mosi : typ_mctl_mport_rd_mosi := (
		data => (others => '0'),
		empty => '0',
		full => '0',
		count => (others => '0'),
		overflow => '0',
		error => '0'
	);


	type typ_mctl_mport_mosi is record
		cmd : typ_mctl_mport_cmd_mosi;
		wr : typ_mctl_mport_wr_mosi;
		rd : typ_mctl_mport_rd_mosi;
	end record;

	constant init_mctl_mport_mosi : typ_mctl_mport_mosi := (
		cmd => init_mctl_mport_cmd_mosi,
		wr => init_mctl_mport_wr_mosi,
		rd => init_mctl_mport_rd_mosi
	);


	type typ_mctl_ram_bidir is record
		dq : std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
		udqs : std_logic;
		dqs : std_logic;
	end record;

	type typ_mctl_ram_mosi is record
		a : std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
		ba : std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
		cke : std_logic;
		ras_n : std_logic;
		cas_n : std_logic;
		we_n : std_logic;
		dm : std_logic;
		udm : std_logic;
		ck : std_logic;
		ck_n : std_logic;
	end record;

	component cpt_mctl_wrapper is
		generic (
			--INCLUDE_MCTL_CHIPSCOPE  : string  := "TRUE";
			C3_MEMCLK_PERIOD        : integer := 6000;
												-- Memory data transfer clock period.
			--C3_CALIB_SOFT_IP        : string := "TRUE";
												-- # = TRUE, Enables the soft calibration logic,
												-- # = FALSE, Disables the soft calibration logic.
			C3_SIMULATION           : string := "FALSE"
												-- # = TRUE, Simulating the design. Useful to reduce the simulation time,
												-- # = FALSE, Implementing the design.
			--DEBUG_EN                : integer := 1
												-- # = 1, Enable debug signals/controls,
												--   = 0, Disable debug signals/controls.
		);
		port (
			mcb3_rzq                : inout std_logic;
			
			c3_sys_clk              : in std_logic;
			c3_sys_rst_i            : in std_logic;
			c3_calib_done           : out std_logic;
			c3_clk0                 : out std_logic;
			c3_rst0                 : out std_logic;
			
			clk_108                 : out std_logic;
			clk_108_n               : out std_logic;
			
			ram_bidir   : inout typ_mctl_ram_bidir;
			ram_mosi    : out typ_mctl_ram_mosi;
			
			mport0_miso : in typ_mctl_mport_miso;
			mport0_mosi : out typ_mctl_mport_mosi;
			
			mport1_miso : in typ_mctl_mport_miso;
			mport1_mosi : out typ_mctl_mport_mosi;
			
			mport2_miso : in typ_mctl_mport_miso;
			mport2_mosi : out typ_mctl_mport_mosi;
			
			mport3_miso : in typ_mctl_mport_miso;
			mport3_mosi : out typ_mctl_mport_mosi
		);
	end component;

	component cpt_mctl is
		generic (
--			C3_P0_MASK_SIZE         : integer;
--			C3_P0_DATA_PORT_SIZE    : integer;
--			C3_P1_MASK_SIZE         : integer;
--			C3_P1_DATA_PORT_SIZE    : integer;
			
			C3_MEMCLK_PERIOD        : integer; 
--			C3_RST_ACT_LOW          : integer;
--			C3_INPUT_CLK_TYPE       : string;
--			DEBUG_EN                : integer;
			
--			C3_CALIB_SOFT_IP        : string;
			C3_SIMULATION           : string;
			C3_MEM_ADDR_ORDER       : string
--			C3_NUM_DQ_PINS          : integer; 
--			C3_MEM_ADDR_WIDTH       : integer; 
--			C3_MEM_BANKADDR_WIDTH   : integer
		);
		port (
			mcb3_dram_dq            : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
			mcb3_dram_dqs           : inout std_logic;
			mcb3_dram_udqs          : inout std_logic;
			mcb3_dram_a             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
			mcb3_dram_ba            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
			mcb3_dram_ras_n         : out std_logic;
			mcb3_dram_cas_n         : out std_logic;
			mcb3_dram_we_n          : out std_logic;
			mcb3_dram_cke           : out std_logic;
			mcb3_dram_dm            : out std_logic;
			mcb3_dram_ck            : out std_logic;
			mcb3_dram_udm           : out std_logic;
			mcb3_dram_ck_n          : out std_logic;
			
			mcb3_rzq                : inout std_logic;
			c3_sys_clk              : in std_logic;
			c3_sys_rst_i            : in std_logic;
			c3_calib_done           : out std_logic;
			c3_clk0                 : out std_logic;
			c3_rst0                 : out std_logic;
			
			clk_108                 : out std_logic;
			clk_108_n               : out std_logic;
			
			c3_p0_cmd_clk           : in std_logic;
			c3_p0_cmd_en            : in std_logic;
			c3_p0_cmd_instr         : in std_logic_vector(2 downto 0);
			c3_p0_cmd_bl            : in std_logic_vector(5 downto 0);
			c3_p0_cmd_byte_addr     : in std_logic_vector(29 downto 0);
			c3_p0_cmd_empty         : out std_logic;
			c3_p0_cmd_full          : out std_logic;
			c3_p0_wr_clk            : in std_logic;
			c3_p0_wr_en             : in std_logic;
			c3_p0_wr_mask           : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
			c3_p0_wr_data           : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_wr_full           : out std_logic;
			c3_p0_wr_empty          : out std_logic;
			c3_p0_wr_count          : out std_logic_vector(6 downto 0);
			c3_p0_wr_underrun       : out std_logic;
			c3_p0_wr_error          : out std_logic;
			c3_p0_rd_clk            : in std_logic;
			c3_p0_rd_en             : in std_logic;
			c3_p0_rd_data           : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_rd_full           : out std_logic;
			c3_p0_rd_empty          : out std_logic;
			c3_p0_rd_count          : out std_logic_vector(6 downto 0);
			c3_p0_rd_overflow       : out std_logic;
			c3_p0_rd_error          : out std_logic;
			c3_p1_cmd_clk           : in std_logic;
			c3_p1_cmd_en            : in std_logic;
			c3_p1_cmd_instr         : in std_logic_vector(2 downto 0);
			c3_p1_cmd_bl            : in std_logic_vector(5 downto 0);
			c3_p1_cmd_byte_addr     : in std_logic_vector(29 downto 0);
			c3_p1_cmd_empty         : out std_logic;
			c3_p1_cmd_full          : out std_logic;
			c3_p1_wr_clk            : in std_logic;
			c3_p1_wr_en             : in std_logic;
			c3_p1_wr_mask           : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
			c3_p1_wr_data           : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_wr_full           : out std_logic;
			c3_p1_wr_empty          : out std_logic;
			c3_p1_wr_count          : out std_logic_vector(6 downto 0);
			c3_p1_wr_underrun       : out std_logic;
			c3_p1_wr_error          : out std_logic;
			c3_p1_rd_clk            : in std_logic;
			c3_p1_rd_en             : in std_logic;
			c3_p1_rd_data           : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_rd_full           : out std_logic;
			c3_p1_rd_empty          : out std_logic;
			c3_p1_rd_count          : out std_logic_vector(6 downto 0);
			c3_p1_rd_overflow       : out std_logic;
			c3_p1_rd_error          : out std_logic;
			c3_p2_cmd_clk           : in std_logic;
			c3_p2_cmd_en            : in std_logic;
			c3_p2_cmd_instr         : in std_logic_vector(2 downto 0);
			c3_p2_cmd_bl            : in std_logic_vector(5 downto 0);
			c3_p2_cmd_byte_addr     : in std_logic_vector(29 downto 0);
			c3_p2_cmd_empty         : out std_logic;
			c3_p2_cmd_full          : out std_logic;
			c3_p2_wr_clk            : in std_logic;
			c3_p2_wr_en             : in std_logic;
			c3_p2_wr_mask           : in std_logic_vector(3 downto 0);
			c3_p2_wr_data           : in std_logic_vector(31 downto 0);
			c3_p2_wr_full           : out std_logic;
			c3_p2_wr_empty          : out std_logic;
			c3_p2_wr_count          : out std_logic_vector(6 downto 0);
			c3_p2_wr_underrun       : out std_logic;
			c3_p2_wr_error          : out std_logic;
			c3_p2_rd_clk            : in std_logic;
			c3_p2_rd_en             : in std_logic;
			c3_p2_rd_data           : out std_logic_vector(31 downto 0);
			c3_p2_rd_full           : out std_logic;
			c3_p2_rd_empty          : out std_logic;
			c3_p2_rd_count          : out std_logic_vector(6 downto 0);
			c3_p2_rd_overflow       : out std_logic;
			c3_p2_rd_error          : out std_logic;
			c3_p3_cmd_clk           : in std_logic;
			c3_p3_cmd_en            : in std_logic;
			c3_p3_cmd_instr         : in std_logic_vector(2 downto 0);
			c3_p3_cmd_bl            : in std_logic_vector(5 downto 0);
			c3_p3_cmd_byte_addr     : in std_logic_vector(29 downto 0);
			c3_p3_cmd_empty         : out std_logic;
			c3_p3_cmd_full          : out std_logic;
			c3_p3_wr_clk            : in std_logic;
			c3_p3_wr_en             : in std_logic;
			c3_p3_wr_mask           : in std_logic_vector(3 downto 0);
			c3_p3_wr_data           : in std_logic_vector(31 downto 0);
			c3_p3_wr_full           : out std_logic;
			c3_p3_wr_empty          : out std_logic;
			c3_p3_wr_count          : out std_logic_vector(6 downto 0);
			c3_p3_wr_underrun       : out std_logic;
			c3_p3_wr_error          : out std_logic;
			c3_p3_rd_clk            : in std_logic;
			c3_p3_rd_en             : in std_logic;
			c3_p3_rd_data           : out std_logic_vector(31 downto 0);
			c3_p3_rd_full           : out std_logic;
			c3_p3_rd_empty          : out std_logic;
			c3_p3_rd_count          : out std_logic_vector(6 downto 0);
			c3_p3_rd_overflow       : out std_logic;
			c3_p3_rd_error          : out std_logic
		);
	end component;
end pkg_mctl;

package body pkg_mctl is

end pkg_mctl;
