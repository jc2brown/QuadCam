
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



library cctl; 
use cctl.pkg_ovm.all;

library cctl; 
use cctl.pkg_cctl.all;


entity cpt_cctl is

	port (
		
		i_clk : in std_logic;
		
		i_ovm0_video_miso : in typ_ovm_video_miso;
--		io_ovm0_sccb_bidir : inout typ_ovm_sccb_bidir;
--		o_ovm0_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm1_video_miso : in typ_ovm_video_miso;
--		io_ovm1_sccb_bidir : inout typ_ovm_sccb_bidir;
--		o_ovm1_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm2_video_miso : in typ_ovm_video_miso;
--		io_ovm2_sccb_bidir : inout typ_ovm_sccb_bidir;
--		o_ovm2_sccb_mosi : out typ_ovm_sccb_mosi;
		
		i_ovm3_video_miso : in typ_ovm_video_miso
--		io_ovm3_sccb_bidir : inout typ_ovm_sccb_bidir;
--		o_ovm3_sccb_mosi : out typ_ovm_sccb_mosi
	
	);

end cpt_cctl;

architecture Behavioral of cpt_cctl is

begin



	cam0 : cpt_cam
	generic map (
		ADDR => 0
	)
	port map (
		i_clk => i_clk,
		i_ovm_video_miso => i_ovm0_video_miso
	);
	
	cam1 : cpt_cam
	generic map (
		ADDR => 0
	)
	port map (
		i_clk => i_clk,
		i_ovm_video_miso => i_ovm1_video_miso
	);
	
	cam2 : cpt_cam
	generic map (
		ADDR => 0
	)
	port map (
		i_clk => i_clk,
		i_ovm_video_miso => i_ovm2_video_miso
	);
	
	cam3 : cpt_cam
	generic map (
		ADDR => 0
	)
	port map (
		i_clk => i_clk,
		i_ovm_video_miso => i_ovm3_video_miso
	);

end Behavioral;

