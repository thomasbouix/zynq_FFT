-- mclk/sclk = 4
-- mclk/lrck = 128
-- sclk/lrck = 32

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_writer is

  generic(
    DATA_LENGTH : INTEGER := 16
  );

	port(
    -- SYSTEM
		resetn  :	in	std_logic;
		clk	    :	in	std_logic;

    -- AXI
		tvalid	: in  std_logic;
    tlast		: in  std_logic;
		tdata		:	in  std_logic_vector((DATA_LENGTH-1) downto 0);
    tready	: out std_logic;

    -- I2S
		mclk    :	out	std_logic;
		sclk	  :	out std_logic;
		lrck	  :	out std_logic;
		dout    :	out std_logic
	);
end entity axi_i2s_writer;

architecture arch of axi_i2s_writer is

  signal cpt_clk		:	unsigned (6 downto 0);
  signal sclk_old   : std_logic;
  -- signal sclk_cur   : std_logic;
  signal lrck_old   : std_logic;
  signal reg_dec    : std_logic_vector(DATA_LENGTH-1 downto 0);
  signal cpt_dout   : integer;  -- compte les bits ecrits sur dout
  signal reg_tready : std_logic;
  signal reg_dout   : std_logic;

begin

  process(clk, resetn) is

    begin

    if (resetn = '0') then
      cpt_clk    <= (others => '0');
      sclk_old   <= '0';
      -- sclk_cur   <= '0';
      reg_dec    <= (others => '0');
      cpt_dout   <= 0;
      reg_tready <= '0';
      lrck_old   <= '0';
      reg_dout   <= '0';

    elsif (falling_edge(clk)) then
      cpt_clk  <= cpt_clk + 1;
      -- sclk_old <= sclk_cur;
      sclk_old <= not(cpt_clk(1));  -- un clk de retard
      lrck_old <= cpt_clk(6);       -- un clk de retard

      -- on ne laisse tready que un coup de clk
      if (reg_tready = '1') then
            reg_tready <= '0';
      else end if;

        -- detection front montant sclk
      if (sclk_old = '0' and not(cpt_clk(1)) = '1') then

            -- front descendant lrck = ecrire nouvelle donnée PMOD
            if (lrck_old = '1' and cpt_clk(6) = '0') then
                  reg_dec    <= tdata;
                  reg_dout   <= '0'
                  reg_tready <= '0';
                  cpt_dout   <= 0;
            else
                  cpt_dout <= cpt_dout + 1;
                  -- ecriture pour cpt_dout=1 jusqu'à cpt_dout=16
                  if  (cpt_dout > 0 and cpt_dout <= DATA_LENGTH) then
                      reg_dec    <= reg_dec(reg_dec'length-2 downto 0) & '0';
                      reg_dout   <= reg_dec(reg_dec'length - 1);
                  else end if;

                if (cpt_dout = 16) then
                  reg_tready <= '1';
                else end if;
            end if;
      else end if;
    end if;

  end process;

  mclk   <= clk;
  sclk   <= not(cpt_clk(1));
  lrck   <= cpt_clk(6);
  tready <= reg_tready;
  dout   <= reg_dout;

end architecture arch;
