
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library mctl;
use mctl.pkg_mctl.all;

library mctl_test;
use mctl_test.pkg_mctl_test.all;

entity cpt_mctl_test_wrapper is

	generic (
		C3_HW_TESTING : string := "FALSE"
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
			
end cpt_mctl_test_wrapper;

architecture Behavioral of cpt_mctl_test_wrapper is



	function c3_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
		begin
		if (C3_HW_TESTING = "FALSE") then
		  return val1;
		else
		  return val2;
		end if;
   end function;	
	
   constant C3_p0_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p0_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p0_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000002ff", x"02ffffff");
   constant C3_p0_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffffc00", x"fc000000");
   constant C3_p0_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p1_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p1_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p1_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000004ff", x"04ffffff");
   constant C3_p1_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff800", x"f8000000");
   constant C3_p1_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p2_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000500", x"05000000");
   constant C3_p2_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p2_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000006ff", x"06ffffff");
   constant C3_p2_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff800", x"f8000000");
   constant C3_p2_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000500", x"05000000");
   constant C3_p3_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000700", x"01000000");
   constant C3_p3_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p3_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000008ff", x"02ffffff");
   constant C3_p3_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff000", x"fc000000");
   constant C3_p3_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000700", x"01000000");	





begin



				
				
	mport0_miso.cmd.clk <= clk0;
	mport0_miso.wr.clk <= clk0;
	mport0_miso.rd.clk <= clk0;
				
	mport1_miso.cmd.clk <= clk0;
	mport1_miso.wr.clk <= clk0;
	mport1_miso.rd.clk <= clk0;
				
	mport2_miso.cmd.clk <= clk0;
	mport2_miso.wr.clk <= clk0;
	mport2_miso.rd.clk <= clk0;
	
	mport3_miso.cmd.clk <= clk0;
	mport3_miso.wr.clk <= clk0;
	mport3_miso.rd.clk <= clk0;

 

	mctl_test :  cpt_mctl_test 
	generic map (
		C_NUM_DQ_PINS       =>     C3_NUM_DQ_PINS,
		C_MEM_BURST_LEN     =>     C3_MEM_BURST_LEN,
		C_MEM_NUM_COL_BITS  =>     C3_MEM_NUM_COL_BITS,
		C_P0_MASK_SIZE      =>     C3_P0_MASK_SIZE,
		C_P0_DATA_PORT_SIZE =>     C3_P0_DATA_PORT_SIZE,        
		C_P1_MASK_SIZE      =>     C3_P1_MASK_SIZE,        
		C_P1_DATA_PORT_SIZE =>     C3_P1_DATA_PORT_SIZE,        
		C_p0_BEGIN_ADDRESS                      => C3_p0_BEGIN_ADDRESS,
		C_p0_DATA_MODE                          => C3_p0_DATA_MODE,
		C_p0_END_ADDRESS                        => C3_p0_END_ADDRESS,
		C_p0_PRBS_EADDR_MASK_POS                => C3_p0_PRBS_EADDR_MASK_POS,
		C_p0_PRBS_SADDR_MASK_POS                => C3_p0_PRBS_SADDR_MASK_POS,
		C_p1_BEGIN_ADDRESS                      => C3_p1_BEGIN_ADDRESS,
		C_p1_DATA_MODE                          => C3_p1_DATA_MODE,
		C_p1_END_ADDRESS                        => C3_p1_END_ADDRESS,
		C_p1_PRBS_EADDR_MASK_POS                => C3_p1_PRBS_EADDR_MASK_POS,
		C_p1_PRBS_SADDR_MASK_POS                => C3_p1_PRBS_SADDR_MASK_POS,
		C_p2_BEGIN_ADDRESS                      => C3_p2_BEGIN_ADDRESS,
		C_p2_DATA_MODE                          => C3_p2_DATA_MODE,
		C_p2_END_ADDRESS                        => C3_p2_END_ADDRESS,
		C_p2_PRBS_EADDR_MASK_POS                => C3_p2_PRBS_EADDR_MASK_POS,
		C_p2_PRBS_SADDR_MASK_POS                => C3_p2_PRBS_SADDR_MASK_POS,
		C_p3_BEGIN_ADDRESS                      => C3_p3_BEGIN_ADDRESS,
		C_p3_DATA_MODE                          => C3_p3_DATA_MODE,
		C_p3_END_ADDRESS                        => C3_p3_END_ADDRESS,
		C_p3_PRBS_EADDR_MASK_POS                => C3_p3_PRBS_EADDR_MASK_POS,
		C_p3_PRBS_SADDR_MASK_POS                => C3_p3_PRBS_SADDR_MASK_POS
	)
	port map	(
		clk0			         => clk0,
		rst0			         => rst0,
		calib_done            => calib_done, 
		cmp_error             => cmp_error,
		error                 => error,
		error_status          => error_status,
		vio_modify_enable     => vio_modify_enable,
		vio_data_mode_value   => vio_data_mode_value,
		vio_addr_mode_value   => vio_addr_mode_value,
				p0_enabled 										  =>  mport0_enabled,

		p0_mcb_cmd_en_o                          =>  mport0_miso.cmd.en,
		p0_mcb_cmd_instr_o                       =>  mport0_miso.cmd.instr,
		p0_mcb_cmd_bl_o                          =>  mport0_miso.cmd.bl,
		p0_mcb_cmd_addr_o                        =>  mport0_miso.cmd.byte_addr,
		p0_mcb_cmd_full_i                        =>  mport0_mosi.cmd.full,
		p0_mcb_wr_en_o                           =>  mport0_miso.wr.en,
		p0_mcb_wr_mask_o                         =>  mport0_miso.wr.mask,
		p0_mcb_wr_data_o                         =>  mport0_miso.wr.data,
		p0_mcb_wr_full_i                         =>  mport0_mosi.wr.full,
		p0_mcb_wr_fifo_counts                    =>  mport0_mosi.wr.count,
		p0_mcb_rd_en_o                           =>  mport0_miso.rd.en,
		p0_mcb_rd_data_i                         =>  mport0_mosi.rd.data,
		p0_mcb_rd_empty_i                        =>  mport0_mosi.rd.empty,
		p0_mcb_rd_fifo_counts                    =>  mport0_mosi.rd.count,

		p1_enabled 										  =>  mport1_enabled,

		p1_mcb_cmd_en_o                          =>  mport1_miso.cmd.en,
		p1_mcb_cmd_instr_o                       =>  mport1_miso.cmd.instr,
		p1_mcb_cmd_bl_o                          =>  mport1_miso.cmd.bl,
		p1_mcb_cmd_addr_o                        =>  mport1_miso.cmd.byte_addr,
		p1_mcb_cmd_full_i                        =>  mport1_mosi.cmd.full,
		p1_mcb_wr_en_o                           =>  mport1_miso.wr.en,
		p1_mcb_wr_mask_o                         =>  mport1_miso.wr.mask,
		p1_mcb_wr_data_o                         =>  mport1_miso.wr.data,
		p1_mcb_wr_full_i                         =>  mport1_mosi.wr.full,
		p1_mcb_wr_fifo_counts                    =>  mport1_mosi.wr.count,
		p1_mcb_rd_en_o                           =>  mport1_miso.rd.en,
		p1_mcb_rd_data_i                         =>  mport1_mosi.rd.data,
		p1_mcb_rd_empty_i                        =>  mport1_mosi.rd.empty,
		p1_mcb_rd_fifo_counts                    =>  mport1_mosi.rd.count,

		p2_enabled 										  =>  mport2_enabled,

		p2_mcb_cmd_en_o                          =>  mport2_miso.cmd.en,
		p2_mcb_cmd_instr_o                       =>  mport2_miso.cmd.instr,
		p2_mcb_cmd_bl_o                          =>  mport2_miso.cmd.bl,
		p2_mcb_cmd_addr_o                        =>  mport2_miso.cmd.byte_addr,
		p2_mcb_cmd_full_i                        =>  mport2_mosi.cmd.full,
		p2_mcb_wr_en_o                           =>  mport2_miso.wr.en,
		p2_mcb_wr_mask_o                         =>  mport2_miso.wr.mask,
		p2_mcb_wr_data_o                         =>  mport2_miso.wr.data,
		p2_mcb_wr_full_i                         =>  mport2_mosi.wr.full,
		p2_mcb_wr_fifo_counts                    =>  mport2_mosi.wr.count,
		p2_mcb_rd_en_o                           =>  mport2_miso.rd.en,
		p2_mcb_rd_data_i                         =>  mport2_mosi.rd.data,
		p2_mcb_rd_empty_i                        =>  mport2_mosi.rd.empty,
		p2_mcb_rd_fifo_counts                    =>  mport2_mosi.rd.count,

		p3_enabled 										  =>  mport3_enabled,

		p3_mcb_cmd_en_o                          =>  mport3_miso.cmd.en,
		p3_mcb_cmd_instr_o                       =>  mport3_miso.cmd.instr,
		p3_mcb_cmd_bl_o                          =>  mport3_miso.cmd.bl,
		p3_mcb_cmd_addr_o                        =>  mport3_miso.cmd.byte_addr,
		p3_mcb_cmd_full_i                        =>  mport3_mosi.cmd.full,
		p3_mcb_wr_en_o                           =>  mport3_miso.wr.en,
		p3_mcb_wr_mask_o                         =>  mport3_miso.wr.mask,
		p3_mcb_wr_data_o                         =>  mport3_miso.wr.data,
		p3_mcb_wr_full_i                         =>  mport3_mosi.wr.full,
		p3_mcb_wr_fifo_counts                    =>  mport3_mosi.wr.count,
		p3_mcb_rd_en_o                           =>  mport3_miso.rd.en,
		p3_mcb_rd_data_i                         =>  mport3_mosi.rd.data,
		p3_mcb_rd_empty_i                        =>  mport3_mosi.rd.empty,
		p3_mcb_rd_fifo_counts                    =>  mport3_mosi.rd.count
	);




end Behavioral;

