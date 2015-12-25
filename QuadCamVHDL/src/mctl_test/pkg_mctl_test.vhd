
library ieee;
use ieee.std_logic_1164.all;


library mctl;
use mctl.pkg_mctl.all;

library mctl_test;

package pkg_mctl_test is



   constant C3_MEM_BURST_LEN	  : integer := 8;
   constant C3_MEM_NUM_COL_BITS   : integer := 10;


	component cpt_mctl_test_wrapper is
		generic (
			C3_HW_TESTING : string := "FALSE"
--			C_P0_MASK_SIZE                   : integer := 4;
--			C_P0_DATA_PORT_SIZE              : integer := 32;
--			C_P1_MASK_SIZE                   : integer := 4;
--			C_P1_DATA_PORT_SIZE              : integer := 32;
--			C_MEM_BURST_LEN                  : integer := 8;
--			C_SIMULATION                     : string  := "FALSE";
--			C_MEM_NUM_COL_BITS               : integer := 11;
--			C_NUM_DQ_PINS                    : integer := 8;
--			C_SMALL_DEVICE                   : string := "FALSE";
--			C_p0_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000100";
--			C_p0_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
--			C_p0_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000002ff";
--			C_p0_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffffc00";
--			C_p0_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000100";
--			C_p1_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000300";
--			C_p1_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
--			C_p1_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000004ff";
--			C_p1_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff800";
--			C_p1_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000300";
--			C_p2_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000500";
--			C_p2_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
--			C_p2_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000006ff";
--			C_p2_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff800";
--			C_p2_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000500";
--			C_p3_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000700";
--			C_p3_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
--			C_p3_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000008ff";
--			C_p3_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff000";
--			C_p3_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000700"
		);
		port (

			clk0            : in std_logic;
			rst0            : in std_logic;
			calib_done      : in std_logic;


			mport0_enabled : in std_logic;
			
			mport0_mosi : in typ_mctl_mport_mosi;
			mport0_miso : out typ_mctl_mport_miso;

			mport1_enabled : in std_logic;
						
			mport1_mosi : in typ_mctl_mport_mosi;
			mport1_miso : out typ_mctl_mport_miso;

			mport2_enabled : in std_logic;
			
			mport2_mosi : in typ_mctl_mport_mosi;
			mport2_miso : out typ_mctl_mport_miso;
			
			mport3_enabled : in std_logic;
			
			mport3_mosi : in typ_mctl_mport_mosi;
			mport3_miso : out typ_mctl_mport_miso;
			
			vio_modify_enable   : in std_logic;
			vio_data_mode_value : in std_logic_vector(2 downto 0);
			vio_addr_mode_value : in std_logic_vector(2 downto 0);

			cmp_error       : out std_logic;
			cmp_data        : out std_logic_vector(31 downto 0);
			cmp_data_valid  : out std_logic;
			error           : out std_logic;
			error_status    : out std_logic_vector(127 downto 0)

		);
	end component;
	
	
	

	component cpt_mctl_test is
		generic (
			C_P0_MASK_SIZE                   : integer := 4;
			C_P0_DATA_PORT_SIZE              : integer := 32;
			C_P1_MASK_SIZE                   : integer := 4;
			C_P1_DATA_PORT_SIZE              : integer := 32;
			C_MEM_BURST_LEN                  : integer := 8;
			C_SIMULATION                     : string  := "FALSE";
			C_MEM_NUM_COL_BITS               : integer := 11;
			C_NUM_DQ_PINS                    : integer := 8;
			C_SMALL_DEVICE                   : string := "FALSE";
			C_p0_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000100";
			C_p0_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
			C_p0_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000002ff";
			C_p0_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffffc00";
			C_p0_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000100";
			C_p1_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000300";
			C_p1_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
			C_p1_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000004ff";
			C_p1_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff800";
			C_p1_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000300";
			C_p2_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000500";
			C_p2_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
			C_p2_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000006ff";
			C_p2_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff800";
			C_p2_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000500";
			C_p3_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000700";
			C_p3_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
			C_p3_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000008ff";
			C_p3_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff000";
			C_p3_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000700"
		);
		port (

			clk0            : in std_logic;
			rst0            : in std_logic;
			calib_done      : in std_logic;


			p0_enabled : in std_logic;
			
			
			p0_mcb_cmd_en_o                           : out std_logic;
			p0_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
			p0_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
			p0_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
			p0_mcb_cmd_full_i                         : in std_logic;

			p0_mcb_wr_en_o                            : out std_logic;
			p0_mcb_wr_mask_o                          : out std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
			p0_mcb_wr_data_o                          : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
			p0_mcb_wr_full_i                          : in std_logic;
			p0_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

			p0_mcb_rd_en_o                            : out std_logic;
			p0_mcb_rd_data_i                          : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
			p0_mcb_rd_empty_i                         : in std_logic;
			p0_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

			p1_enabled : in std_logic;
						
						
			p1_mcb_cmd_en_o                           : out std_logic;
			p1_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
			p1_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
			p1_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
			p1_mcb_cmd_full_i                         : in std_logic;

			p1_mcb_wr_en_o                            : out std_logic;
			p1_mcb_wr_mask_o                          : out std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
			p1_mcb_wr_data_o                          : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
			p1_mcb_wr_full_i                          : in std_logic;
			p1_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

			p1_mcb_rd_en_o                            : out std_logic;
			p1_mcb_rd_data_i                          : in std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
			p1_mcb_rd_empty_i                         : in std_logic;
			p1_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

			p2_enabled : in std_logic;
			
			
			p2_mcb_cmd_en_o                           : out std_logic;
			p2_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
			p2_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
			p2_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
			p2_mcb_cmd_full_i                         : in std_logic;

			p2_mcb_wr_en_o                            : out std_logic;
			p2_mcb_wr_mask_o                          : out std_logic_vector(3 downto 0);
			p2_mcb_wr_data_o                          : out std_logic_vector(31 downto 0);
			p2_mcb_wr_full_i                          : in std_logic;
			p2_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

			p2_mcb_rd_en_o                            : out std_logic;
			p2_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
			p2_mcb_rd_empty_i                         : in std_logic;
			p2_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

			p3_enabled : in std_logic;
			
			
			p3_mcb_cmd_en_o                           : out std_logic;
			p3_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
			p3_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
			p3_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
			p3_mcb_cmd_full_i                         : in std_logic;

			p3_mcb_wr_en_o                            : out std_logic;
			p3_mcb_wr_mask_o                          : out std_logic_vector(3 downto 0);
			p3_mcb_wr_data_o                          : out std_logic_vector(31 downto 0);
			p3_mcb_wr_full_i                          : in std_logic;
			p3_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

			p3_mcb_rd_en_o                            : out std_logic;
			p3_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
			p3_mcb_rd_empty_i                         : in std_logic;
			p3_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);


			vio_modify_enable   : in std_logic;
			vio_data_mode_value : in std_logic_vector(2 downto 0);
			vio_addr_mode_value : in std_logic_vector(2 downto 0);

			cmp_error       : out std_logic;
			cmp_data        : out std_logic_vector(31 downto 0);
			cmp_data_valid  : out std_logic;
			error           : out std_logic;
			error_status    : out std_logic_vector(127 downto 0)

		);
	end component;
	
end pkg_mctl_test;

package body pkg_mctl_test is

end pkg_mctl_test;
