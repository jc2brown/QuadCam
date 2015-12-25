
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity cpt_clkgen is
	port (
		 i_clk_24M : in std_logic;	-- 24 MHz input
		 i_reset : in std_logic;
		 o_clk_72M : out std_logic;	-- 72 MHz
		 o_reset : out std_logic;
		 o_async_reset : out std_logic;
		 o_clk_288M : out std_logic;	-- 288 MHz
		 o_clk_288M_180 : out std_logic;	-- 288 MHz
		 o_mcb_drp_clk : out std_logic;	-- 72 MHz
		 o_clk_144M : out std_logic;	-- 144 MHz 
		 o_clk_144M_90 : out std_logic;	-- 144 MHz 
		 o_pll_lock : out std_logic	  
	);
end cpt_clkgen;

architecture cpt of cpt_clkgen is

--   constant C_MEMCLK_PERIOD     : integer := 41666;
   constant C_MEMCLK_PERIOD     : integer := 6944;

--   constant C_RST_ACT_LOW      : integer := 0;
--   constant C_INPUT_CLK_TYPE   : string  := "DIFFERENTIAL";
--   constant C_CLKOUT0_DIVIDE   : integer := 2;
--   constant C_CLKOUT1_DIVIDE   : integer := 2;
--   constant C_CLKOUT2_DIVIDE   : integer := 8;
--   constant C_CLKOUT3_DIVIDE   : integer := 8;
--   constant C_CLKFBOUT_MULT   : integer := 4;
--   constant C_DIVCLK_DIVIDE   : integer := 1
	
--   constant C_INCLK_PERIOD     : integer := 2500;
   constant C_RST_ACT_LOW      : integer := 0;
   constant C_INPUT_CLK_TYPE   : string  := "SINGLE_ENDED";
	
   constant C_CLKOUT0_DIVIDE       : integer := 2; 
   constant C_CLKOUT1_DIVIDE       : integer := 2; 
   constant C_CLKOUT2_DIVIDE       : integer := 8; 
   constant C_CLKOUT3_DIVIDE       : integer := 8; 
   constant C_CLKFBOUT_MULT        : integer := 24; 
   constant C_DIVCLK_DIVIDE        : integer := 1; 
   constant C_INCLK_PERIOD         : integer := ((C_MEMCLK_PERIOD * C_CLKFBOUT_MULT) / (C_DIVCLK_DIVIDE * C_CLKOUT0_DIVIDE * 2)); 
	
	


  -- # of clock cycles to delay deassertion of reset. Needs to be a fairly
  -- high number not so much for metastability protection, but to give time
  -- for reset (i.e. stable clock cycles) to propagate through all state
  -- machines and to all control signals (i.e. not all control signals have
  -- resets, instead they rely on base state logic being reset, and the effect
  -- of that reset propagating through the logic). Need this because we may not
  -- be getting stable clock cycles while reset asserted (i.e. since reset
  -- depends on PLL/DCM lock status)

  constant RST_SYNC_NUM   : integer := 25;
  constant CLK_PERIOD_NS  : real := (real(C_INCLK_PERIOD)) / 1000.0;
  constant CLK_PERIOD_INT : integer := C_INCLK_PERIOD/1000;


  signal   clk_2x_0            : std_logic;
  signal   clk_2x_180          : std_logic;
  signal   o_clk_72M_bufg           : std_logic;
  signal   o_clk_72M_bufg_in        : std_logic;
  signal   o_mcb_drp_clk_bufg_in : std_logic;
  signal   clkfbout_clkfbin    : std_logic;
  signal   rst_tmp             : std_logic;
  signal   i_clk_24M_ibufg       : std_logic;
  signal   sys_rst             : std_logic;
  signal   o_reset_sync_r         : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal   powerup_o_pll_locked  : std_logic;
  signal   syn_o_clk_72M_powerup_o_pll_locked : std_logic;
  signal   locked              : std_logic;
  signal   bufpll_mcb_locked   : std_logic;
  signal   o_mcb_drp_clk_sig     : std_logic;

  attribute max_fanout : string;
  attribute syn_maxfan : integer;
  attribute KEEP : string; 
  attribute max_fanout of o_reset_sync_r : signal is "10";
  attribute syn_maxfan of o_reset_sync_r : signal is 10;
  attribute KEEP of i_clk_24M_ibufg     : signal is "TRUE";

begin 

  sys_rst  <= not(i_reset) when (C_RST_ACT_LOW /= 0) else i_reset;
  o_clk_72M     <= o_clk_72M_bufg;
  o_pll_lock <= bufpll_mcb_locked;
  o_mcb_drp_clk <= o_mcb_drp_clk_sig;

--  diff_input_clk : if(C_INPUT_CLK_TYPE = "DIFFERENTIAL") generate   
--      --***********************************************************************
--      -- Differential input clock input buffers
--      --***********************************************************************
--      u_ibufg_i_clk_24M : IBUFGDS
--        generic map (
--          DIFF_TERM => TRUE		    
--        )
--        port map (
--          I  => i_clk_24M_p,
--          IB => i_clk_24M_n,
--          O  => i_clk_24M_ibufg
--          );
--  end generate;   
  
  
  se_input_clk : if(C_INPUT_CLK_TYPE = "SINGLE_ENDED") generate   
      --***********************************************************************
      -- SINGLE_ENDED input clock input buffers
      --***********************************************************************
      u_ibufg_i_clk_24M : IBUFG
        port map (
          I  => i_clk_24M,
          O  => i_clk_24M_ibufg
          );
  end generate;   

  --***************************************************************************
  -- Global clock generation and distribution
  --***************************************************************************

    u_pll_adv : PLL_ADV 
    generic map 
        (
         BANDWIDTH          => "OPTIMIZED",
         CLKIN1_PERIOD      => CLK_PERIOD_NS,
         CLKIN2_PERIOD      => CLK_PERIOD_NS,
         CLKOUT0_DIVIDE     => C_CLKOUT0_DIVIDE,
         CLKOUT1_DIVIDE     => C_CLKOUT1_DIVIDE,
         CLKOUT2_DIVIDE     => C_CLKOUT2_DIVIDE,
         CLKOUT3_DIVIDE     => C_CLKOUT3_DIVIDE,
         CLKOUT4_DIVIDE     => 1,
         CLKOUT5_DIVIDE     => 1,
         CLKOUT0_PHASE      => 0.000,
         CLKOUT1_PHASE      => 180.000,
         CLKOUT2_PHASE      => 0.000,
         CLKOUT3_PHASE      => 0.000,
         CLKOUT4_PHASE      => 0.000,
         CLKOUT5_PHASE      => 0.000,
         CLKOUT0_DUTY_CYCLE => 0.500,
         CLKOUT1_DUTY_CYCLE => 0.500,
         CLKOUT2_DUTY_CYCLE => 0.500,
         CLKOUT3_DUTY_CYCLE => 0.500,
         CLKOUT4_DUTY_CYCLE => 0.500,
         CLKOUT5_DUTY_CYCLE => 0.500,
	 SIM_DEVICE         => "SPARTAN6",
         COMPENSATION       => "INTERNAL",
         DIVCLK_DIVIDE      => C_DIVCLK_DIVIDE,
         CLKFBOUT_MULT      => C_CLKFBOUT_MULT,
         CLKFBOUT_PHASE     => 0.0,
         REF_JITTER         => 0.005000
         )
        port map
          (
           CLKFBIN          => clkfbout_clkfbin,
           CLKINSEL         => '1',
           CLKIN1           => i_clk_24M_ibufg,
           CLKIN2           => '0',
           DADDR            => (others => '0'),
           DCLK             => '0',
           DEN              => '0',
           DI               => (others => '0'),
           DWE              => '0',
           REL              => '0',
           RST              => sys_rst,
           CLKFBDCM         => open,
           CLKFBOUT         => clkfbout_clkfbin,
           CLKOUTDCM0       => open,
           CLKOUTDCM1       => open,
           CLKOUTDCM2       => open,
           CLKOUTDCM3       => open,
           CLKOUTDCM4       => open,
           CLKOUTDCM5       => open,
           CLKOUT0          => clk_2x_0,
           CLKOUT1          => clk_2x_180,
           CLKOUT2          => o_clk_72M_bufg_in,
           CLKOUT3          => o_mcb_drp_clk_bufg_in,
           CLKOUT4          => open,
           CLKOUT5          => open,
           DO               => open,
           DRDY             => open,
           LOCKED           => locked
           );

    U_BUFG_o_clk_72M : BUFG
    port map
    (
     O => o_clk_72M_bufg,
     I => o_clk_72M_bufg_in
     );

   --U_BUFG_CLK1 : BUFG 
   -- port map (  
   --  O => o_mcb_drp_clk_sig,
   --  I => o_mcb_drp_clk_bufg_in
   --  );

   U_BUFG_CLK1 : BUFGCE 
    port map (  
     O => o_mcb_drp_clk_sig,
     I => o_mcb_drp_clk_bufg_in,
     CE => locked
     );

   process (o_mcb_drp_clk_sig, sys_rst)
   begin
      if(sys_rst = '1') then
         powerup_o_pll_locked <= '0';
      elsif (o_mcb_drp_clk_sig'event and o_mcb_drp_clk_sig = '1') then
         if (bufpll_mcb_locked = '1') then
            powerup_o_pll_locked <= '1';
         end if;
      end if;
   end process;      


   process (o_clk_72M_bufg, sys_rst)
   begin
      if(sys_rst = '1') then
         syn_o_clk_72M_powerup_o_pll_locked <= '0';
      elsif (o_clk_72M_bufg'event and o_clk_72M_bufg = '1') then
         if (bufpll_mcb_locked = '1') then
            syn_o_clk_72M_powerup_o_pll_locked <= '1';
         end if;
      end if;
   end process;      


   --***************************************************************************
   -- Reset synchronization
   -- NOTES:
   --   1. shut down the whole operation if the PLL hasn't yet locked (and
   --      by inference, this means that external sys_rst has been asserted -
   --      PLL deasserts LOCKED as soon as sys_rst asserted)
   --   2. asynchronously assert reset. This was we can assert reset even if
   --      there is no clock (needed for things like 3-stating output buffers).
   --      reset deassertion is synchronous.
   --   3. asynchronous reset only look at o_pll_lock from PLL during power up. After
   --      power up and o_pll_lock is asserted, the powerup_o_pll_locked will be asserted
   --      forever until sys_rst is asserted again. PLL will lose lock when FPGA 
   --      enters suspend mode. We don't want reset to MCB get
   --      asserted in the application that needs suspend feature.
   --***************************************************************************


  o_async_reset <= sys_rst or not(powerup_o_pll_locked);
  -- o_async_reset <= rst_tmp;
  rst_tmp <= sys_rst or not(syn_o_clk_72M_powerup_o_pll_locked);
  -- rst_tmp <= sys_rst or not(powerup_o_pll_locked);

process (o_clk_72M_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      o_reset_sync_r <= (others => '1');
    elsif (rising_edge(o_clk_72M_bufg)) then      
      o_reset_sync_r <= o_reset_sync_r(RST_SYNC_NUM-2 downto 0) & '0';  -- logical left shift by one (pads with 0)
    end if;
  end process;

  o_reset    <= o_reset_sync_r(RST_SYNC_NUM-1);


BUFPLL_MCB_INST : BUFPLL_MCB
port map
( IOCLK0         => o_clk_288M,	
  IOCLK1         => o_clk_288M_180, 
  LOCKED         => locked,
  GCLK           => o_mcb_drp_clk_sig,
  SERDESSTROBE0  => o_clk_144M, 
  SERDESSTROBE1  => o_clk_144M_90, 
  PLLIN0         => clk_2x_0,  
  PLLIN1         => clk_2x_180,
  LOCK           => bufpll_mcb_locked 
  );

end cpt;

