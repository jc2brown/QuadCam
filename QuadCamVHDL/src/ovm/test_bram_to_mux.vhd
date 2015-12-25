

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
  
  
-- Work library for testing
library work;
use work.pkg_testing.all;

library mctl;
use mctl.pkg_mctl.all;





  ENTITY test_bram_to_mux IS
  END test_bram_to_mux;

  ARCHITECTURE behavior OF test_bram_to_mux IS 
  
  
	component sim_ovm_testing is
		generic (
			SMALL_FRAME : string := "FALSE"
		);
		port (			
			i_ovm_sccb_mosi : in typ_ovm_sccb_mosi;
			io_ovm_sccb_bidir : inout typ_ovm_sccb_bidir;
			o_ovm_video_miso : out typ_ovm_video_miso 			
		);
	end component;


   COMPONENT cpt_ovm_bram
    PORT(
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
    END COMPONENT;
    

    COMPONENT cpt_ovm_mux
    PORT(
         i_clk : IN  std_logic;
         i_reset : IN  std_logic;
         i0_frame_count : IN  integer range 0 to 3;
         i1_frame_count : IN  integer range 0 to 3;
         i2_frame_count : IN  integer range 0 to 3;
         i3_frame_count : IN  integer range 0 to 3;
         i_frame_addr0 : IN  std_logic_vector(28 downto 0);
         i_frame_addr1 : IN  std_logic_vector(28 downto 0);
         i_frame_addr2 : IN  std_logic_vector(28 downto 0);
         i_frame_addr3 : IN  std_logic_vector(28 downto 0);
         i0_line_offset : IN  integer range 0 to 8191;
         i1_line_offset : IN  integer range 0 to 8191;
         i2_line_offset : IN  integer range 0 to 8191;
         i3_line_offset : IN  integer range 0 to 8191;
         i0_words_read : IN  integer range 0 to 511;
         i1_words_read : IN  integer range 0 to 511;
         i2_words_read : IN  integer range 0 to 511;
         i3_words_read : IN  integer range 0 to 511;
         i0_line_count : IN  integer range 0 to 511;
         i1_line_count : IN  integer range 0 to 511;
         i2_line_count : IN  integer range 0 to 511;
         i3_line_count : IN  integer range 0 to 511;
         i0_rd_data : IN  std_logic_vector(31 downto 0);
         i1_rd_data : IN  std_logic_vector(31 downto 0);
         i2_rd_data : IN  std_logic_vector(31 downto 0);
         i3_rd_data : IN  std_logic_vector(31 downto 0);
         i0_burst_available : IN  std_logic;
         i1_burst_available : IN  std_logic;
         i2_burst_available : IN  std_logic;
         i3_burst_available : IN  std_logic;
         o0_rd_enable : OUT  std_logic;
         o1_rd_enable : OUT  std_logic;
         o2_rd_enable : OUT  std_logic;
         o3_rd_enable : OUT  std_logic;
         i_burst_length : IN  std_logic_vector(5 downto 0);		
			o_mport_miso : out typ_mctl_mport_miso;
			i_mport_mosi : in typ_mctl_mport_mosi
        );
    END COMPONENT;
    

   signal mport_mosi : typ_mctl_mport_mosi := init_mctl_mport_mosi;
   signal mport_miso : typ_mctl_mport_miso := init_mctl_mport_miso;

   signal clk : std_logic := '0';
   signal bram_reset : std_logic := '0';
   signal mux_reset : std_logic := '0';
   signal burst_length : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(15,6));

	signal frame_addr0 : std_logic_vector(28 downto 0) := "00000" & x"000000";
   signal frame_addr1 : std_logic_vector(28 downto 0) := "00000" & x"100000";
   signal frame_addr2 : std_logic_vector(28 downto 0) := "00000" & x"200000";
   signal frame_addr3 : std_logic_vector(28 downto 0) := "00000" & x"300000";
	
   signal line_offset0 : integer range 0 to 8191 := 0;
   signal line_offset1 : integer range 0 to 8191 := 1024;
   signal line_offset2 : integer range 0 to 8191 := 1024;
   signal line_offset3 : integer range 0 to 8191 := 0;
		
	signal ovm0_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm0_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm0_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
	--signal ovm0.href : std_logic := '0';
   signal ovm0_bram_rd_enable : std_logic := '0';
   signal ovm0_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm0_bram_frame_number : integer range 0 to 3;
   signal ovm0_bram_line_number : integer range 0 to 2047;
   signal ovm0_bram_words_read : integer range 0 to 511;
   signal ovm0_bram_burst_available : std_logic;
	
	signal ovm1_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm1_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm1_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
   signal ovm1_bram_rd_enable : std_logic := '0';
   signal ovm1_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm1_bram_frame_number : integer range 0 to 3;
   signal ovm1_bram_line_number : integer range 0 to 2047;
   signal ovm1_bram_words_read : integer range 0 to 511;
   signal ovm1_bram_burst_available : std_logic;
		
	signal ovm2_video_miso : typ_ovm_video_miso := init_ovm_video_miso;
	signal ovm2_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;
	signal ovm2_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
   signal ovm2_bram_rd_enable : std_logic := '0';
   signal ovm2_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm2_bram_frame_number : integer range 0 to 3;
   signal ovm2_bram_line_number : integer range 0 to 2047;
   signal ovm2_bram_words_read : integer range 0 to 511;
   signal ovm2_bram_burst_available : std_logic;
		
	signal ovm3_video_miso : typ_ovm_video_miso := init_ovm_video_miso;	
	signal ovm3_sccb_bidir : typ_ovm_sccb_bidir := init_ovm_sccb_bidir;	
	signal ovm3_sccb_mosi : typ_ovm_sccb_mosi := init_ovm_sccb_mosi;
   signal ovm3_bram_rd_enable : std_logic := '0';
   signal ovm3_bram_rd_data : std_logic_vector(31 downto 0);
   signal ovm3_bram_frame_number : integer range 0 to 3;
   signal ovm3_bram_line_number : integer range 0 to 2047;
   signal ovm3_bram_words_read : integer range 0 to 511;
   signal ovm3_bram_burst_available : std_logic;

   signal o0_collision : std_logic;
   signal o1_collision : std_logic;
   signal o2_collision : std_logic;
   signal o3_collision : std_logic;


   -- Clock period definitions
   constant xvclk_period : time := 166.667 ns;
  -- constant pclk_period : time := 41.667 ns;
   constant clk_period : time := 9.259 ns;
	--constant tp : time := 2*pclk_period;
	--constant tline : time := 780*tp;
	
	constant SMALL_FRAME : string := "FALSE";
	 
BEGIN

 
	ovm0_sccb_mosi.pwdn <= '0';
	ovm1_sccb_mosi.pwdn <= '0';
	ovm2_sccb_mosi.pwdn <= '0';
	ovm3_sccb_mosi.pwdn <= '0';
 
   ovm0_xvclk_process : process
   begin
		ovm0_sccb_mosi.xvclk <= '0';
		wait for xvclk_period/2;
		ovm0_sccb_mosi.xvclk <= '1';
		wait for xvclk_period/2;
   end process;
	
   ovm1_xvclk_process : process
   begin
		ovm1_sccb_mosi.xvclk <= '0';
		wait for xvclk_period/2;
		ovm1_sccb_mosi.xvclk <= '1';
		wait for xvclk_period/2;
   end process; 
	
   ovm2_xvclk_process : process
   begin
		ovm2_sccb_mosi.xvclk <= '0';
		wait for xvclk_period/2;
		ovm2_sccb_mosi.xvclk <= '1';
		wait for xvclk_period/2;
   end process; 
	
   ovm3_xvclk_process : process
   begin
		ovm3_sccb_mosi.xvclk <= '0';
		wait for xvclk_period/2;
		ovm3_sccb_mosi.xvclk <= '1';
		wait for xvclk_period/2;
   end process; 

 
	ovm0 : sim_ovm_testing 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm0_sccb_mosi,
		io_ovm_sccb_bidir => ovm0_sccb_bidir, 
		o_ovm_video_miso => ovm0_video_miso
	);
	
	ovm1 : sim_ovm_testing 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm1_sccb_mosi,
		io_ovm_sccb_bidir => ovm1_sccb_bidir, 
		o_ovm_video_miso => ovm1_video_miso
	);
	
	ovm2 : sim_ovm_testing 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm2_sccb_mosi,
		io_ovm_sccb_bidir => ovm2_sccb_bidir, 
		o_ovm_video_miso => ovm2_video_miso
	);

	ovm3 : sim_ovm_testing 
	generic map (
		SMALL_FRAME => SMALL_FRAME
	)
	port map (
		i_ovm_sccb_mosi => ovm3_sccb_mosi,
		io_ovm_sccb_bidir => ovm3_sccb_bidir, 
		o_ovm_video_miso => ovm3_video_miso
	);
	
	
	-- Instantiate the Unit Under Test (UUT)
   ovm_mux: cpt_ovm_mux PORT MAP (
		 i_clk => clk,
		 i_reset => mux_reset,
		 i0_frame_count => ovm0_bram_frame_number,
		 i1_frame_count => ovm1_bram_frame_number,
		 i2_frame_count => ovm2_bram_frame_number,
		 i3_frame_count => ovm3_bram_frame_number,
		 i_frame_addr0 => frame_addr0,
		 i_frame_addr1 => frame_addr1,
		 i_frame_addr2 => frame_addr2,
		 i_frame_addr3 => frame_addr3,
		 i0_line_offset => line_offset0,
		 i1_line_offset => line_offset1,
		 i2_line_offset => line_offset2,
		 i3_line_offset => line_offset3,
		 i0_words_read => ovm0_bram_words_read,
		 i1_words_read => ovm1_bram_words_read,
		 i2_words_read => ovm2_bram_words_read,
		 i3_words_read => ovm3_bram_words_read,
		 i0_line_count => ovm0_bram_line_number,
		 i1_line_count => ovm1_bram_line_number,
		 i2_line_count => ovm2_bram_line_number,
		 i3_line_count => ovm3_bram_line_number,
		 i0_rd_data => ovm0_bram_rd_data,
		 i1_rd_data => ovm1_bram_rd_data,
		 i2_rd_data => ovm2_bram_rd_data,
		 i3_rd_data => ovm3_bram_rd_data,
		 i0_burst_available => ovm0_bram_burst_available,
		 i1_burst_available => ovm1_bram_burst_available,
		 i2_burst_available => ovm2_bram_burst_available,
		 i3_burst_available => ovm3_bram_burst_available,
		 o0_rd_enable => ovm0_bram_rd_enable,
		 o1_rd_enable => ovm1_bram_rd_enable,
		 o2_rd_enable => ovm2_bram_rd_enable,
		 o3_rd_enable => ovm3_bram_rd_enable,
		 i_burst_length => burst_length,
		 o_mport_miso => mport_miso,
		 i_mport_mosi => mport_mosi
	  );


	ovm0_bram : cpt_ovm_bram PORT MAP (
		i_pclk => ovm0_video_miso.pclk,
		i_vsync => ovm0_video_miso.vsync,
		i_href => ovm0_video_miso.href,
		i_data => ovm0_video_miso.data,
		i_reset => bram_reset,
		o_rd_data => ovm0_bram_rd_data,
		o_frame_number => ovm0_bram_frame_number,
		o_line_number => ovm0_bram_line_number,
		o_words_read => ovm0_bram_words_read,
		i_burst_length => burst_length,
		o_burst_available => ovm0_bram_burst_available,
		o_collision => o0_collision,
		i_clk => clk,
		i_rd_enable => ovm0_bram_rd_enable
	);

	ovm1_bram : cpt_ovm_bram PORT MAP (
		i_pclk => ovm1_video_miso.pclk,
		i_vsync => ovm1_video_miso.vsync,
		i_href => ovm1_video_miso.href,
		i_data => ovm1_video_miso.data,
		i_reset => bram_reset,
		o_rd_data => ovm1_bram_rd_data,
		o_frame_number => ovm1_bram_frame_number,
		o_line_number => ovm1_bram_line_number,
		o_words_read => ovm1_bram_words_read,
		i_burst_length => burst_length,
		o_burst_available => ovm1_bram_burst_available,
		o_collision => o1_collision,
		i_clk => clk,
		i_rd_enable => ovm1_bram_rd_enable
	);
	
	ovm2_bram : cpt_ovm_bram PORT MAP (
		i_pclk => ovm2_video_miso.pclk,
		i_vsync => ovm2_video_miso.vsync,
		i_href => ovm2_video_miso.href,
		i_data => ovm2_video_miso.data,
		i_reset => bram_reset,
		o_rd_data => ovm2_bram_rd_data,
		o_frame_number => ovm2_bram_frame_number,
		o_line_number => ovm2_bram_line_number,
		o_words_read => ovm2_bram_words_read,
		i_burst_length => burst_length,
		o_burst_available => ovm2_bram_burst_available,
		o_collision => o2_collision,
		i_clk => clk,
		i_rd_enable => ovm2_bram_rd_enable
	);
	
	ovm3_bram: cpt_ovm_bram PORT MAP (
		i_pclk => ovm3_video_miso.pclk,
		i_vsync => ovm3_video_miso.vsync,
		i_href => ovm3_video_miso.href,
		i_data => ovm3_video_miso.data,
		i_reset => bram_reset,
		o_rd_data => ovm3_bram_rd_data,
		o_frame_number => ovm3_bram_frame_number,
		o_line_number => ovm3_bram_line_number,
		o_words_read => ovm3_bram_words_read,
		i_burst_length => burst_length,
		o_burst_available => ovm3_bram_burst_available,
		o_collision => o3_collision,
		i_clk => clk,
		i_rd_enable => ovm3_bram_rd_enable
	);


   -- Clock process definitions
   i_clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 
--   -- Clock process definitions
--   rd_full_process :process
--   begin
--		wait until rising_edge(i_clk);
--		mport_mosi.rd.full <= '0';
--		wait for clk_period * 10;
--		wait until rising_edge(i_clk);
--		mport_mosi.rd.full <= '1';
--		wait for clk_period * 10;
--   end process;
--	
--	
--	-- Clock process definitions
--   cmd_full_process :process
--   begin
--		wait until rising_edge(i_clk);
--		mport_mosi.cmd.full <= '0';
--		wait for clk_period * 100;
--		wait until rising_edge(i_clk);
--		mport_mosi.cmd.full <= '1';
--		wait for clk_period * 100;
--   end process;
	
	
	
--	-- Clock process definitions
--   ovm0_pclk_process :process
--   begin
--		ovm0.pclk <= '0';
--		wait for pclk_period/2;
--		ovm0.pclk <= '1';
--		wait for pclk_period/2;
--   end process; 
--	  
--   ovm1_pclk_process :process
--   begin
--		ovm1.pclk <= '0';
--		wait for pclk_period/2;
--		ovm1.pclk <= '1';
--		wait for pclk_period/2;
--   end process; 
--
--   ovm2_pclk_process :process
--   begin
--		ovm2.pclk <= '0';
--		wait for pclk_period/2;
--		ovm2.pclk <= '1';
--		wait for pclk_period/2;
--   end process; 
--
--   ovm3_pclk_process :process
--   begin
--		ovm3.pclk <= '0';
--		wait for pclk_period/2;
--		ovm3.pclk <= '1';
--		wait for pclk_period/2;
--   end process; 
--
--
--	ovm0_vsync_process : process
--	begin
--		wait until falling_edge(ovm0.pclk);
--		ovm0.vsync <= '1';
--		wait for 4*tline;
--		ovm0.vsync <= '0';
--		wait for (512-4)*tline;
--	end process;
--	
--	ovm1_vsync_process : process
--	begin
--		wait until falling_edge(ovm1.pclk);
--		ovm1.vsync <= '1';
--		wait for 4*tline;
--		ovm1.vsync <= '0';
--		wait for (512-4)*tline;
--	end process;
--	
--	ovm2_vsync_process : process
--	begin
--		wait until falling_edge(ovm2.pclk);
--		ovm2.vsync <= '1';
--		wait for 4*tline;
--		ovm2.vsync <= '0';
--		wait for (512-4)*tline;
--	end process;
--	
--	ovm3_vsync_process : process
--	begin
--		wait until falling_edge(ovm3.pclk);
--		ovm3.vsync <= '1';
--		wait for 4*tline;
--		ovm3.vsync <= '0';
--		wait for (512-4)*tline;
--	end process;
--	
--	ovm0_href_process : process
--	begin
--		ovm0.href <= '0';
--		wait for 20*tline;
--		wait until falling_edge(ovm0.pclk);
--		for i in 0 to 479 loop
--			ovm0.href <= '1';
--			wait for 640*tp;
--			ovm0.href <= '0';
--			wait for 140*tp;
--		end loop;
--		wait for 12*tline;
--	end process;
--	
--	ovm1_href_process : process
--	begin
--		ovm1.href <= '0';
--		wait for 20*tline;
--		wait until falling_edge(ovm1.pclk);
--		for i in 0 to 479 loop
--			ovm1.href <= '1';
--			wait for 640*tp;
--			ovm1.href <= '0';
--			wait for 140*tp;
--		end loop;
--		wait for 12*tline;
--	end process;
--	
--	ovm2_href_process : process
--	begin
--		ovm2.href <= '0';
--		wait for 20*tline;
--		wait until falling_edge(ovm2.pclk);
--		for i in 0 to 479 loop
--			ovm2.href <= '1';
--			wait for 640*tp;
--			ovm2.href <= '0';
--			wait for 140*tp;
--		end loop;
--		wait for 12*tline;
--	end process;
--	
--	ovm3_href_process : process
--	begin
--		ovm3.href <= '0';
--		wait for 20*tline;
--		wait until falling_edge(ovm3.pclk);
--		for i in 0 to 479 loop
--			ovm3.href <= '1';
--			wait for 640*tp;
--			ovm3.href <= '0';
--			wait for 140*tp;
--		end loop;
--		wait for 12*tline;
--	end process;
--	
--	ovm0_data_process : process
--	begin
--		--wait until rising_edge(ovm0.href);
--		wait until ovm0.href = '1';
--		report "OVM0 rise";
--		--		wait until falling_edge(i_pclk);
--		for i in 0 to 1279 loop
--			ovm0.data <= std_logic_vector(to_unsigned(i mod 256, ovm0.data'length)); --mod to avoid truncation warnings everywhere
--			wait for pclk_period;
--		end loop;
--	end process;
--		
--	ovm1_data_process : process
--	begin
--		--wait until rising_edge(ovm1.href);
--		wait until ovm1.href = '1';
--		--		wait until falling_edge(i_pclk);
--		for i in 0 to 1279 loop
--			ovm1.data <= std_logic_vector(to_unsigned(i mod 256, ovm1.data'length)); --mod to avoid truncation warnings everywhere
--			wait for pclk_period;
--		end loop;
--	end process;
--	
--	ovm2_data_process : process
--	begin
--		wait until rising_edge(ovm2.href);
--		--		wait until falling_edge(i_pclk);
--		for i in 0 to 1279 loop
--			ovm2.data <= std_logic_vector(to_unsigned(i mod 256, ovm2.data'length)); --mod to avoid truncation warnings everywhere
--			wait for pclk_period;
--		end loop;
--	end process;
--	
--	ovm3_data_process : process
--	begin
--		wait until rising_edge(ovm3.href);
--		--		wait until falling_edge(i_pclk);
--		for i in 0 to 1279 loop
--			ovm3.data <= std_logic_vector(to_unsigned(i mod 256, ovm3.data'length)); --mod to avoid truncation warnings everywhere
--			wait for pclk_period;
--		end loop;
--	end process;
	
	
	 
   -- Clock process definitions
   rd_full_process :process
   begin
		wait until rising_edge(clk);
		mport_mosi.wr.full <= '0';
		wait for clk_period * 10;
		wait until rising_edge(clk);
		mport_mosi.wr.full <= '1';
		wait for clk_period * 10;
   end process;
	
	
	-- Clock process definitions
   cmd_full_process :process
   begin
		wait until rising_edge(clk);
		mport_mosi.cmd.full <= '0';
		wait for clk_period * 100;
		wait until rising_edge(clk);
		mport_mosi.cmd.full <= '1';
		wait for clk_period * 100;
   end process;
	
	
	
	
   stim_proc: process
   begin		
		bram_reset <= '0';
		mux_reset <= '0';
      wait for 100 ns;	
		bram_reset <= '1';
		mux_reset <= '1';
      wait for 100 ns;	
		bram_reset <= '0';
		mux_reset <= '0';
      wait;
   end process;

END;
