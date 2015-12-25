
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library cctl; 
use cctl.pkg_cctl.all;

library cctl; 
use cctl.pkg_ovm.all;

library mctl; 
use mctl.pkg_mctl.all;


library util; 
use util.pkg_util.all;


entity cpt_ovm is


	port (
		
		--i_clk : in std_logic;
		
		i_ovm_video_miso: in typ_ovm_video_miso;		
		
		i_mport_mosi : in typ_mctl_mport_mosi;
		o_mport_miso : out typ_mctl_mport_miso
				
	);

end cpt_ovm;

architecture Behavioral of cpt_ovm is



	signal pixel : std_logic_vector(15 downto 0);
	signal addr_latch : std_logic_vector(25 downto 0);
	signal h_count : integer;
	signal burst_count : integer;
	signal pclk_wr_en : std_logic;

begin
	
	pclk_div_gate : cpt_clk_gate
	port map (
		i_clk => i_ovm_video_miso.pclk,
		i_enable => i_ovm_video_miso.href,
		i_div => 1,
		o_clk_pgate => pclk_wr_en,
		o_clk_ngate => open
	);
	
	
	process(i_ovm_video_miso.pclk)
	begin
		if ( rising_edge(i_ovm_video_miso.pclk) ) then
			pixel <= i_ovm_video_miso.data & pixel(15 downto 8);
		end if;
	end process;
	

	
	o_mport_miso.cmd.clk <= i_ovm_video_miso.pclk;
	o_mport_miso.wr.clk <= i_ovm_video_miso.pclk;
	
	process(i_ovm_video_miso.pclk)
	begin
		if ( rising_edge(i_ovm_video_miso.pclk) ) then
			if ( i_ovm_video_miso.vsync = '1' ) then
				addr_latch <= (others => '0');	
			elsif ( pclk_wr_en = '1' and h_count = 640 ) then
				addr_latch <= std_logic_vector(to_unsigned(640*4+to_integer(unsigned(addr_latch)),26));
			elsif  ( pclk_wr_en = '1' and i_ovm_video_miso.href = '1' ) then
				if ( i_mport_mosi.cmd.full = '0' and burst_count = 31 ) then
					o_mport_miso.cmd.en <= '1';
					o_mport_miso.cmd.instr <= "010";
					o_mport_miso.cmd.bl <= "011111";
					o_mport_miso.cmd.byte_addr <= "0000" & addr_latch(25 downto 0);
					addr_latch <= std_logic_vector(to_unsigned(32*4+to_integer(unsigned(addr_latch)),26));
				else			
					o_mport_miso.cmd.en <= '0';
				end if;		
			end if;
		end if;	
	end process;




	h_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => i_ovm_video_miso.pclk,
		i_enable => pclk_wr_en,
		i_lowest => 0,
		i_highest => 779,
		i_increment => 1,
		i_clear => i_ovm_video_miso.vsync,
		i_preset => '0',
		o_count => h_count,
		o_carry => open	
	);
	
	burst_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => i_ovm_video_miso.pclk,
		i_enable => pclk_wr_en,
		i_lowest => 0,
		i_highest => 31,
		i_increment => 1,
		i_clear => i_ovm_video_miso.vsync,
		i_preset => '0',
		o_count => burst_count,
		o_carry => open	
	);


	
	o_mport_miso.wr.en <= pclk_wr_en;
	o_mport_miso.wr.data(15 downto 0) <= pixel;
	
	

end Behavioral;

