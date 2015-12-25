

library ieee;
use ieee.std_logic_1164.all;

library mctl;
use mctl.pkg_mctl.all;

package pkg_ovm is


	type typ_ovm_sccb_bidir is record
		scl : std_logic;
		sda : std_logic;			
	end record;
	
	constant init_ovm_sccb_bidir : typ_ovm_sccb_bidir := (
		scl => 'Z',
		sda => 'Z'
	);


	type typ_ovm_sccb_mosi is record
		pwdn : std_logic;
		xvclk : std_logic;
	end record;

	constant init_ovm_sccb_mosi : typ_ovm_sccb_mosi := (
		pwdn => '1',
		xvclk => '0'
	);
	

	type typ_ovm_video_miso is record
		pclk : std_logic;
		data : std_logic_vector(7 downto 0);
		href : std_logic;
		vsync : std_logic;
	end record;

	constant init_ovm_video_miso : typ_ovm_video_miso := (
		pclk => '0',
		data => (others => '0'),
		href => '0',
		vsync => '0'
	);
	

   component cpt_ovm_bram
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
    end component;
    

    component cpt_ovm_mux
    port(
         i_clk : in  std_logic;
         i_reset : in  std_logic;
         i0_frame_count : in  integer range 0 to 3;
         i1_frame_count : in  integer range 0 to 3;
         i2_frame_count : in  integer range 0 to 3;
         i3_frame_count : in  integer range 0 to 3;
         i_frame_addr0 : in  std_logic_vector(28 downto 0);
         i_frame_addr1 : in  std_logic_vector(28 downto 0);
         i_frame_addr2 : in  std_logic_vector(28 downto 0);
         i_frame_addr3 : in  std_logic_vector(28 downto 0);
         i0_line_offset : in  integer range 0 to 8191;
         i1_line_offset : in  integer range 0 to 8191;
         i2_line_offset : in  integer range 0 to 8191;
         i3_line_offset : in  integer range 0 to 8191;
         i0_words_read : in  integer range 0 to 511;
         i1_words_read : in  integer range 0 to 511;
         i2_words_read : in  integer range 0 to 511;
         i3_words_read : in  integer range 0 to 511;
         i0_line_count : in  integer range 0 to 511;
         i1_line_count : in  integer range 0 to 511;
         i2_line_count : in  integer range 0 to 511;
         i3_line_count : in  integer range 0 to 511;
         i0_rd_data : in  std_logic_vector(31 downto 0);
         i1_rd_data : in  std_logic_vector(31 downto 0);
         i2_rd_data : in  std_logic_vector(31 downto 0);
         i3_rd_data : in  std_logic_vector(31 downto 0);
         i0_burst_available : in  std_logic;
         i1_burst_available : in  std_logic;
         i2_burst_available : in  std_logic;
         i3_burst_available : in  std_logic;
         o0_rd_enable : out  std_logic;
         o1_rd_enable : out  std_logic;
         o2_rd_enable : out  std_logic;
         o3_rd_enable : out  std_logic;
         i_burst_length : in  std_logic_vector(5 downto 0);
         o_mport_miso : out  typ_mctl_mport_miso;
         i_mport_mosi : in  typ_mctl_mport_mosi
        );
    end component;
    




end pkg_ovm;


package body pkg_ovm is
end pkg_ovm;
