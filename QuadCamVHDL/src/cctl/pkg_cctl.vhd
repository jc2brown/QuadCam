
library ieee;
use ieee.std_logic_1164.all;



library util; 
use util.pkg_util.all;

library mctl; 
use mctl.pkg_mctl.all;

library cctl; 
use cctl.pkg_ovm.all;


package pkg_cctl is


	type typ_cctl_cport_miso is record
		clk : std_logic;	
		rd_en : std_logic;
	end record;
	
	constant init_cctl_cport_miso : typ_cctl_cport_miso := (
		clk => '0',
		rd_en => '0'
	);


	type typ_cctl_cport_mosi is record
		data : std_logic_vector(7 downto 0);
		empty : std_logic;
		full : std_logic;
	end record;

	constant init_cctl_cport_mosi : typ_cctl_cport_mosi := (
		data => (others => '0'),
		empty => '0',
		full => '0'
	);


	
	component cpt_cctl is

		port (
		i_clk : in std_logic;
			
			i_ovm0_video_miso : in typ_ovm_video_miso;
--			io_ovm0_sccb_bidir : inout typ_ovm_sccb_bidir;
--			o_ovm0_sccb_mosi : out typ_ovm_sccb_mosi;
			
			i_ovm1_video_miso : in typ_ovm_video_miso;
--			io_ovm1_sccb_bidir : inout typ_ovm_sccb_bidir;
--			o_ovm1_sccb_mosi : out typ_ovm_sccb_mosi;
			
			i_ovm2_video_miso : in typ_ovm_video_miso;
--			io_ovm2_sccb_bidir : inout typ_ovm_sccb_bidir;
--			o_ovm2_sccb_mosi : out typ_ovm_sccb_mosi;
			
			i_ovm3_video_miso : in typ_ovm_video_miso
--			io_ovm3_sccb_bidir : inout typ_ovm_sccb_bidir;
--			o_ovm3_sccb_mosi : out typ_ovm_sccb_mosi
	
		);

	end component;


	component cpt_cam is	
		generic (
			ADDR : integer 
		);		
		port (
			i_clk : in std_logic;		
			i_ovm_video_miso : in typ_ovm_video_miso
--			io_ovm_sccb_bidir : inout typ_ovm_sccb_bidir;
--			o_ovm_sccb_mosi : out typ_ovm_sccb_mosi
		);	
	end component;
	
	
	




	component cpt_ovm is


		port (
			
			--i_clk : in std_logic;
			
			i_ovm_video_miso : in typ_ovm_video_miso;		
			
			i_mport_mosi : in typ_mctl_mport_mosi;
			o_mport_miso : out typ_mctl_mport_miso
					
		);

	end component;



end pkg_cctl;


package body pkg_cctl is
end pkg_cctl;
