
-- sim_ovm.vhd
--
-- Behavioural simulation of OVM7690 CameraCube.
-- 
-- Implemented:
--		PLL (6MHz xvclk in, 24MHz pclk out)
--		Internal registers
-- 	Tristate ctrl/video bus
--
-- To be implemented:
-- 	SCCB register read/write
--		Video readout (RGB/YUV)
--
-- Won't be implemented
--		Image processing
--		


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library util; 
use util.pkg_util.all;

library cctl; 
use cctl.pkg_ovm.all;


entity sim_ovm is
	generic (
		SMALL_FRAME : string := "FALSE" -- Image size is reduced by a factor of ~100 
	);
	port (	
		i_ovm_sccb_mosi : in typ_ovm_sccb_mosi;
		io_ovm_sccb_bidir : inout typ_ovm_sccb_bidir;
		o_ovm_video_miso : out typ_ovm_video_miso 	
	);
end sim_ovm;


architecture Behavioral of sim_ovm is

	signal xvclk : std_logic := '0';
	
	-- PLL
	signal pll_clkfb : std_logic := '0';
	signal pll_reset : std_logic := '1';
	signal pll_lock : std_logic := '0';
	signal pll_lock_n : std_logic := '1';
	
	-- System
	signal clk_8M : std_logic := '0';
	signal clk_12M : std_logic := '0';
	signal clk_24M : std_logic := '0';
	signal clk_48M : std_logic := '0';
	signal reset : std_logic := '1';
	
	
	-- Register bank (refer to OV7690_CSP3 datasheet)
	type typ_ovm_registers is array (0 to 255) of std_logic_vector(7 downto 0);
	
	-- Register addresses
	constant OVM_PIDH 	: integer := 16#0A#; -- product ID MSB 
	constant OVM_PIDL 	: integer := 16#0B#; -- product ID LSB 
	constant OVM_REG0C 	: integer := 16#0C#; -- vflip,hmirror,BRswap,YUYVswap,busorder,tristate,overlay
	constant OVM_REG0D	: integer := 16#0D#; -- VSstart,VSwidth
	constant OVM_REG0E	: integer := 16#0E#; -- Sleep,Range,Drive
	constant OVM_CLKRC 	: integer := 16#11#; -- ExtClk,PreScale
	constant OVM_REG12 	: integer := 16#12#; -- Reset,Subsmp,ITU565,RAW,RGBfmt,OUTfmt
	constant OVM_REG16 	: integer := 16#16#; -- HsizeLSb,Voff,Hoff
	constant OVM_HSIZE 	: integer := 16#18#; -- HsizeMSB
	constant OVM_VSIZE 	: integer := 16#1A#; -- Vsize
	constant OVM_MIDH 	: integer := 16#1C#; -- mfr. ID MSB
	constant OVM_MIDL 	: integer := 16#1D#; -- mfr. ID LSB
	constant OVM_REG28 	: integer := 16#28#; -- DATAneg,HRtoHS,HSrev,HRrev,VSedge,VSneg
	constant OVM_PLL	 	: integer := 16#29#; -- PLLdiv,PLLctl,PLLreset,YAVGsrc
	constant OVM_REG3E 	: integer := 16#3E#; -- PCLKgate,PCLKmult
	constant OVM_REG3F 	: integer := 16#3F#; -- PCLKrev
	constant OVM_PWC0 	: integer := 16#49#; -- DOVDD
	constant OVM_REG62 	: integer := 16#62#; -- TESTen,TESTmode
	
	
	signal ovm_reg : typ_ovm_registers := (
		OVM_PIDH 	=> x"76",	
		OVM_PIDL 	=> x"90",	
		OVM_REG0C 	=> x"00",	
		OVM_REG0D 	=> x"44",	
		OVM_REG0E 	=> x"00",	
		OVM_CLKRC 	=> x"00",	
		OVM_REG12 	=> x"11",	
		OVM_REG16 	=> x"08",	
		OVM_HSIZE 	=> x"A0",	
		OVM_VSIZE 	=> x"F0",	
		OVM_MIDH 	=> x"7F",	
		OVM_MIDL 	=> x"A2",	
		OVM_REG28 	=> x"00",
		OVM_PLL 		=> x"A2",
		OVM_REG3E	=> x"20",
		OVM_REG3F	=> x"44",
		OVM_PWC0		=> x"0D",
		OVM_REG62	=> x"00",
		others => x"00"
	);
	
	
	-- Video generation
	signal red_pixel : integer := 0;
	signal green_pixel : integer := 0;
	signal blue_pixel : integer := 0;
	
	
	
	function f(v1:integer; v2:integer) return integer is
		begin
		if (SMALL_FRAME = "FALSE") then
		  return v1;
		else
		  return v2;
		end if;
   end function;
	
	



	-- -----------------------------------
	-- Characteristic timing constants
	-- -----------------------------------
	
	constant H_ACTIVE_WIDTH : integer := f(640, 12);
	constant H_FRONTPORCH_WIDTH : integer := f(54, 2);
	constant H_SYNC_WIDTH : integer := f(16, 1);
	constant H_BACKPORCH_WIDTH : integer := f(70, 2);
		
	constant V_ACTIVE_WIDTH : integer := f(480, 12);
	constant V_FRONTPORCH_WIDTH : integer := f(12, 1);
	constant V_SYNC_WIDTH : integer := f(4, 1);
	constant V_BACKPORCH_WIDTH : integer := f(16, 2);
	
	
	-- --------------------------------------------------------
	-- Derived timing constants (do not modify without reason)
	-- --------------------------------------------------------
	
	constant H_ACTIVE_FIRST : integer := 0;
	constant H_ACTIVE_LAST : integer := H_ACTIVE_FIRST + H_ACTIVE_WIDTH - 1;
	
	constant H_FRONTPORCH_FIRST : integer := H_ACTIVE_LAST + 1;
	constant H_FRONTPORCH_LAST : integer := H_FRONTPORCH_FIRST + H_FRONTPORCH_WIDTH - 1;
	
	constant H_SYNC_FIRST : integer := H_FRONTPORCH_LAST + 1;
	constant H_SYNC_LAST : integer := H_SYNC_FIRST + H_SYNC_WIDTH - 1;
	
	constant H_BACKPORCH_FIRST : integer := H_SYNC_LAST + 1;
	constant H_BACKPORCH_LAST : integer := H_BACKPORCH_FIRST + H_BACKPORCH_WIDTH - 1;
	
	constant H_BLANK_FIRST : integer := H_FRONTPORCH_FIRST;
	constant H_BLANK_LAST : integer := H_BACKPORCH_LAST;
	
	constant H_FRAME_FIRST : integer := H_ACTIVE_FIRST;
	constant H_FRAME_LAST : integer := H_BACKPORCH_LAST;
		
	constant V_ACTIVE_FIRST : integer := 0;
	constant V_ACTIVE_LAST : integer := V_ACTIVE_FIRST + V_ACTIVE_WIDTH - 1;
	
	constant V_FRONTPORCH_FIRST : integer := V_ACTIVE_LAST + 1;
	constant V_FRONTPORCH_LAST : integer := V_FRONTPORCH_FIRST + V_FRONTPORCH_WIDTH - 1;
	
	constant V_SYNC_FIRST : integer := V_FRONTPORCH_LAST + 1;
	constant V_SYNC_LAST : integer := V_SYNC_FIRST + V_SYNC_WIDTH - 1;
	
	constant V_BACKPORCH_FIRST : integer := V_SYNC_LAST + 1;
	constant V_BACKPORCH_LAST : integer := V_BACKPORCH_FIRST + V_BACKPORCH_WIDTH - 1;
	
	constant V_BLANK_FIRST : integer := V_FRONTPORCH_FIRST;
	constant V_BLANK_LAST : integer := V_BACKPORCH_LAST;
	
	constant V_FRAME_FIRST : integer := V_ACTIVE_FIRST;
	constant V_FRAME_LAST : integer := V_BACKPORCH_LAST;
	
	
	-- Video timing generation 
	signal h_count : integer := 0;
	signal h_active : std_logic := '1';		
	signal h_sync : std_logic := '0';	
	
	signal v_counter_enable : std_logic := '1';
	signal v_count : integer := 0;
	signal v_active : std_logic := '1';
	signal v_sync : std_logic := '0';	
	
	signal frame_counter_enable : std_logic := '1';
	signal frame_count : integer := 0;
	signal frame_active : std_logic := '1';
	
	
	
	
	signal subpixel : integer := 0;
	constant RGB : string := "RGBg";
	constant YCrCb : string := "YRyB";
	
	
	
	-- Video output
	signal data : std_logic_vector(7 downto 0) := (others => '0');
	--signal pclk : std_logic := '0';
	--signal vsync : std_logic := '0';
	--signal href : std_logic := '0';
	signal tristate_ctrl : std_logic := '1';
	signal tristate_data : std_logic := '1';
	
	
begin

	xvclk <= i_ovm_sccb_mosi.xvclk;

--      xvclk_ibufg : IBUFG
--      port map (
--			I => i_ovm_sccb_mosi.xvclk,
--			O => xvclk
--      );
			 
				
			

	-- 6 MHz -> 
	--			48 MHz 
	--			24 MHz -- pixel clock
	--			12 MHz 
	--			8 MHz 

	pll_reset <= ovm_reg(OVM_PLL)(3);
	
   ovm_pll_base : PLL_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED" 
      CLKFBOUT_MULT => 16, -- Multiply value for all CLKOUT clock outputs (1-64)
      CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
      CLKIN_PERIOD => 166.667, -- 6 MHz     -- Input clock period in ns
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      CLKOUT0_DIVIDE => 2,	
      CLKOUT1_DIVIDE => 4,
      CLKOUT2_DIVIDE => 8,
      CLKOUT3_DIVIDE => 12,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLK_FEEDBACK => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      COMPENSATION => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL" 
      DIVCLK_DIVIDE => 1, -- Division value for all output clocks (1-52)
      REF_JITTER => 0.1, -- Reference Clock Jitter in UI (0.000-0.999).
      RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
   )
   port map (
      CLKFBOUT => pll_clkfb, -- 1-bit output: PLL_BASE feedback output
      -- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      CLKOUT0 => clk_48M,
      CLKOUT1 => clk_24M,
      CLKOUT2 => clk_12M,
      CLKOUT3 => clk_8M,
      CLKOUT4 => open,
      CLKOUT5 => open,
      LOCKED => pll_lock, -- 1-bit output: PLL_BASE lock status output
      CLKFBIN => pll_clkfb, -- 1-bit input: Feedback clock input
      CLKIN => xvclk, -- 1-bit input: Clock input
      RST => '0' -- 1-bit input: Reset input
   );


	pll_lock_n <= not pll_lock;
	
	
	

	-- System reset
	-- Released synchronously when PLL locks
	-- Reasserted asynchronously when PLL loses lock
	reset_fdp : fdp 
	port map (
		c => xvclk,
		d => pll_lock_n, 
		q => reset,
		pre => pll_lock_n
	);
	

	
--	pclk_clkout : cpt_clkout
--	generic map (
--		CLK_DIV2 => 0
--	)
--	port map (
--		i_clk => clk_24M,
--		o_clk => o_ovm_video_miso.pclk
--	);
	
	
--	process(clk_24M) 
--	begin
--		if ( falling_edge(clk_24M) ) then
--			red_pixel <= red_pixel + 1;
--			green_pixel <= green_pixel + 1;
--			blue_pixel <= blue_pixel + 1;
--		end if;
--	end process;


--	process(clk_24M)
--	begin
--		
--	end process;



-- ----------------------------------------------------
-- Video generation
-- ----------------------------------------------------

--	subpixel <= (H_ACTIVE_WIDTH * v_count + h_count + (v_count mod 4)) mod 4
--		when h_active = '1' and v_active = '1' 
--		else 0;
		
	data <= std_logic_vector(to_unsigned(h_count mod 256, 8))
		when h_active = '1' and v_active = '1' 
		else (others => '0');

--	process(subpixel)
--	begin
--		data <= conv_std_logic_vector(character'pos(RGB(subpixel+1)), 8);
--	end process;
	





-- ----------------------------------------------------
-- Video timing generation
-- ----------------------------------------------------

	h_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => clk_24M,
		i_enable => '1',
		i_lowest => H_FRAME_FIRST,
		i_highest => H_FRAME_LAST,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => h_count,
		o_carry => open	
	);
	
	h_active <= '1' when reset = '0' and h_count >= H_ACTIVE_FIRST and h_count <= H_ACTIVE_LAST else '0';
	h_sync <= '1' when reset = '0' and h_count >= H_SYNC_FIRST and h_count <= H_SYNC_LAST else '0';
	
	v_counter_enable <= '1' when h_count = H_FRAME_LAST else '0';
	
	v_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => clk_24M,
		i_enable => v_counter_enable,
		i_lowest => V_FRAME_FIRST,
		i_highest => V_FRAME_LAST,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => v_count,
		o_carry => open
	);	
		
	v_active <= '1' when reset = '0' and v_count >= V_ACTIVE_FIRST and v_count <= V_ACTIVE_LAST else '0';
	v_sync <= '1' when reset = '0' and v_count >= V_SYNC_FIRST and v_count <= V_SYNC_LAST else '0';
	

	frame_counter_enable <= '1' when h_count = H_FRAME_LAST and v_count = V_FRAME_LAST else '0';
	
	frame_counter : cpt_upcounter
	generic map (
		INIT => 0
	)
	port map ( 
		i_clk => clk_24M,
		i_enable => frame_counter_enable,
		i_lowest => 0,
		i_highest => 2**30-1,
		i_increment => 1,
		i_clear => reset,
		i_preset => '0',
		o_count => frame_count,
		o_carry => open
	);	

	frame_active <= '1' when v_count >= 0 else '0';


-- ----------------------------------------------------
-- Output buffers
-- ----------------------------------------------------

	tristate_data <= '0'; --not ovm_reg(OVM_REG0C)(2);
	tristate_ctrl <= '0'; --not ovm_reg(OVM_REG0C)(1);

	o_ovm_video_miso.data <= data when tristate_data = '0' else (others => 'Z');
		
--	gen_data_obuft :
--	for i in 0 to 7 generate
--		data_obuft : obuft
--		port map (
--			i => data(i),
--			o => o_ovm_video_miso.data(i),
--			t => tristate_data
--		);
--	end generate;
	
	
	o_ovm_video_miso.pclk <= clk_24M when tristate_ctrl = '0' else 'Z';
	
--	pclk_obuft : obuft
--	port map (
--		i => clk_24M,
--		o => o_ovm_video_miso.pclk,
--		t => tristate_ctrl
--	);
	
	
	o_ovm_video_miso.vsync <= v_sync when tristate_ctrl = '0' else 'Z';
	
--	vsync_obuft : obuft
--	port map (
--		i => v_sync,
--		o => o_ovm_video_miso.vsync,
--		t => tristate_ctrl
--	);
	
	
	o_ovm_video_miso.href <= h_active when tristate_ctrl = '0' else 'Z';
	
--	href_obuft : obuft
--	port map (
--		i => h_active,
--		o => o_ovm_video_miso.href,
--		t => tristate_ctrl
--	);
		
		
	io_ovm_sccb_bidir.sda <= 'Z';
		
end Behavioral;

