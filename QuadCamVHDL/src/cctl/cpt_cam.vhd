
library ieee;
use ieee.std_logic_1164.all;


library util; 
use util.pkg_util.all;

library cctl;
use cctl.pkg_ovm.all;
use cctl.pkg_cctl.all;



entity cpt_cam is

	generic (
		ADDR : integer 
	);
	
	port (
		i_clk : in std_logic;
	
		i_ovm_video_miso : in typ_ovm_video_miso
	);				
	
			
end cpt_cam;

architecture Behavioral of cpt_cam is

begin



end Behavioral;

