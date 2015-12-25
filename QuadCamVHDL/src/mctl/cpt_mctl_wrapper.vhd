
library ieee;
use ieee.std_logic_1164.all;

library mctl;
use mctl.pkg_mctl.all;

entity cpt_mctl_wrapper is
	  
	generic (
		C3_MEMCLK_PERIOD        : integer := 6944; -- 144 MHz 
		C3_CALIB_SOFT_IP        : string := "FALSE"; 
		C3_SIMULATION           : string := "FALSE"
	);
   
	port (
		
		mcb3_rzq : inout  std_logic;
		
		c3_sys_clk : in  std_logic;
		c3_sys_rst_i : in  std_logic;
		c3_calib_done : out std_logic;
		c3_clk0 : out std_logic;
		c3_rst0 : out std_logic;


			 clk_108         : out std_logic;
			 clk_108_n       : out std_logic;
			 
		ram_bidir : inout typ_mctl_ram_bidir;			
		ram_mosi : out typ_mctl_ram_mosi;
		
		mport0_miso : in typ_mctl_mport_miso;
		mport0_mosi : out typ_mctl_mport_mosi;
		
		mport1_miso : in typ_mctl_mport_miso;
		mport1_mosi : out typ_mctl_mport_mosi;
		
		mport2_miso : in typ_mctl_mport_miso;
		mport2_mosi : out typ_mctl_mport_mosi;
		
		mport3_miso : in typ_mctl_mport_miso;
		mport3_mosi : out typ_mctl_mport_mosi
	);
	
end cpt_mctl_wrapper;


architecture arc of cpt_mctl_wrapper is

begin 


	
	mctl : cpt_mctl
	  
	generic map (
		C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
		C3_SIMULATION => C3_SIMULATION,
		C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER
	)
   
	port map (
					

		mcb3_dram_dq       =>    ram_bidir.dq,        
		mcb3_dram_dqs      =>    ram_bidir.dqs,                          
		mcb3_dram_udqs  =>       ram_bidir.udqs,       
		
		mcb3_dram_a        =>    ram_mosi.a,  
		mcb3_dram_ba       =>    ram_mosi.ba,
		mcb3_dram_ras_n    =>    ram_mosi.ras_n,                        
		mcb3_dram_cas_n    =>    ram_mosi.cas_n,                        
		mcb3_dram_we_n     =>    ram_mosi.we_n,                          
		mcb3_dram_cke      =>    ram_mosi.cke,                          
		mcb3_dram_ck       =>    ram_mosi.ck,                          
		mcb3_dram_ck_n     =>    ram_mosi.ck_n,
		mcb3_dram_udm  =>        ram_mosi.udm,
		mcb3_dram_dm  =>       ram_mosi.dm,


		c3_sys_clk => c3_sys_clk,
		c3_sys_rst_i => c3_sys_rst_i,   

		c3_clk0 => c3_clk0,
		c3_rst0 => c3_rst0,

		c3_calib_done => c3_calib_done,

		mcb3_rzq => mcb3_rzq,
		
		
		
    clk_108   => clk_108,
    clk_108_n => clk_108_n,

		c3_p0_cmd_clk                           =>  mport0_miso.cmd.clk,
		c3_p0_cmd_en                            =>  mport0_miso.cmd.en,
		c3_p0_cmd_instr                         =>  mport0_miso.cmd.instr,
		c3_p0_cmd_bl                            =>  mport0_miso.cmd.bl,
		c3_p0_cmd_byte_addr                     =>  mport0_miso.cmd.byte_addr,
		c3_p0_cmd_empty                         =>  mport0_mosi.cmd.empty,
		c3_p0_cmd_full                          =>  mport0_mosi.cmd.full,
		c3_p0_wr_clk                            =>  mport0_miso.wr.clk,
		c3_p0_wr_en                             =>  mport0_miso.wr.en,
		c3_p0_wr_mask                           =>  mport0_miso.wr.mask,
		c3_p0_wr_data                           =>  mport0_miso.wr.data,
		c3_p0_wr_full                           =>  mport0_mosi.wr.full,
		c3_p0_wr_empty                          =>  mport0_mosi.wr.empty,
		c3_p0_wr_count                          =>  mport0_mosi.wr.count,
		c3_p0_wr_underrun                       =>  mport0_mosi.wr.underrun,
		c3_p0_wr_error                          =>  mport0_mosi.wr.error,
		c3_p0_rd_clk                            =>  mport0_miso.rd.clk,
		c3_p0_rd_en                             =>  mport0_miso.rd.en,
		c3_p0_rd_data                           =>  mport0_mosi.rd.data,
		c3_p0_rd_full                           =>  mport0_mosi.rd.full,
		c3_p0_rd_empty                          =>  mport0_mosi.rd.empty,
		c3_p0_rd_count                          =>  mport0_mosi.rd.count,
		c3_p0_rd_overflow                       =>  mport0_mosi.rd.overflow,
		c3_p0_rd_error                          =>  mport0_mosi.rd.error,		
		c3_p1_cmd_clk                           =>  mport1_miso.cmd.clk,
		c3_p1_cmd_en                            =>  mport1_miso.cmd.en,
		c3_p1_cmd_instr                         =>  mport1_miso.cmd.instr,
		c3_p1_cmd_bl                            =>  mport1_miso.cmd.bl,
		c3_p1_cmd_byte_addr                     =>  mport1_miso.cmd.byte_addr,
		c3_p1_cmd_empty                         =>  mport1_mosi.cmd.empty,
		c3_p1_cmd_full                          =>  mport1_mosi.cmd.full,
		c3_p1_wr_clk                            =>  mport1_miso.wr.clk,
		c3_p1_wr_en                             =>  mport1_miso.wr.en,
		c3_p1_wr_mask                           =>  mport1_miso.wr.mask,
		c3_p1_wr_data                           =>  mport1_miso.wr.data,
		c3_p1_wr_full                           =>  mport1_mosi.wr.full,
		c3_p1_wr_empty                          =>  mport1_mosi.wr.empty,
		c3_p1_wr_count                          =>  mport1_mosi.wr.count,
		c3_p1_wr_underrun                       =>  mport1_mosi.wr.underrun,
		c3_p1_wr_error                          =>  mport1_mosi.wr.error,
		c3_p1_rd_clk                            =>  mport1_miso.rd.clk,
		c3_p1_rd_en                             =>  mport1_miso.rd.en,
		c3_p1_rd_data                           =>  mport1_mosi.rd.data,
		c3_p1_rd_full                           =>  mport1_mosi.rd.full,
		c3_p1_rd_empty                          =>  mport1_mosi.rd.empty,
		c3_p1_rd_count                          =>  mport1_mosi.rd.count,
		c3_p1_rd_overflow                       =>  mport1_mosi.rd.overflow,
		c3_p1_rd_error                          =>  mport1_mosi.rd.error,		
		c3_p2_cmd_clk                           =>  mport2_miso.cmd.clk,
		c3_p2_cmd_en                            =>  mport2_miso.cmd.en,
		c3_p2_cmd_instr                         =>  mport2_miso.cmd.instr,
		c3_p2_cmd_bl                            =>  mport2_miso.cmd.bl,
		c3_p2_cmd_byte_addr                     =>  mport2_miso.cmd.byte_addr,
		c3_p2_cmd_empty                         =>  mport2_mosi.cmd.empty,
		c3_p2_cmd_full                          =>  mport2_mosi.cmd.full,
		c3_p2_wr_clk                            =>  mport2_miso.wr.clk,
		c3_p2_wr_en                             =>  mport2_miso.wr.en,
		c3_p2_wr_mask                           =>  mport2_miso.wr.mask,
		c3_p2_wr_data                           =>  mport2_miso.wr.data,
		c3_p2_wr_full                           =>  mport2_mosi.wr.full,
		c3_p2_wr_empty                          =>  mport2_mosi.wr.empty,
		c3_p2_wr_count                          =>  mport2_mosi.wr.count,
		c3_p2_wr_underrun                       =>  mport2_mosi.wr.underrun,
		c3_p2_wr_error                          =>  mport2_mosi.wr.error,
		c3_p2_rd_clk                            =>  mport2_miso.rd.clk,
		c3_p2_rd_en                             =>  mport2_miso.rd.en,
		c3_p2_rd_data                           =>  mport2_mosi.rd.data,
		c3_p2_rd_full                           =>  mport2_mosi.rd.full,
		c3_p2_rd_empty                          =>  mport2_mosi.rd.empty,
		c3_p2_rd_count                          =>  mport2_mosi.rd.count,
		c3_p2_rd_overflow                       =>  mport2_mosi.rd.overflow,
		c3_p2_rd_error                          =>  mport2_mosi.rd.error,
		c3_p3_cmd_clk                           =>  mport3_miso.cmd.clk,
		c3_p3_cmd_en                            =>  mport3_miso.cmd.en,
		c3_p3_cmd_instr                         =>  mport3_miso.cmd.instr,
		c3_p3_cmd_bl                            =>  mport3_miso.cmd.bl,
		c3_p3_cmd_byte_addr                     =>  mport3_miso.cmd.byte_addr,
		c3_p3_cmd_empty                         =>  mport3_mosi.cmd.empty,
		c3_p3_cmd_full                          =>  mport3_mosi.cmd.full,
		c3_p3_wr_clk                            =>  mport3_miso.wr.clk,
		c3_p3_wr_en                             =>  mport3_miso.wr.en,
		c3_p3_wr_mask                           =>  mport3_miso.wr.mask,
		c3_p3_wr_data                           =>  mport3_miso.wr.data,
		c3_p3_wr_full                           =>  mport3_mosi.wr.full,
		c3_p3_wr_empty                          =>  mport3_mosi.wr.empty,
		c3_p3_wr_count                          =>  mport3_mosi.wr.count,
		c3_p3_wr_underrun                       =>  mport3_mosi.wr.underrun,
		c3_p3_wr_error                          =>  mport3_mosi.wr.error,
		c3_p3_rd_clk                            =>  mport3_miso.rd.clk,
		c3_p3_rd_en                             =>  mport3_miso.rd.en,
		c3_p3_rd_data                           =>  mport3_mosi.rd.data,
		c3_p3_rd_full                           =>  mport3_mosi.rd.full,
		c3_p3_rd_empty                          =>  mport3_mosi.rd.empty,
		c3_p3_rd_count                          =>  mport3_mosi.rd.count,
		c3_p3_rd_overflow                       =>  mport3_mosi.rd.overflow,
		c3_p3_rd_error                          =>  mport3_mosi.rd.error
	);
 
 end  arc;
