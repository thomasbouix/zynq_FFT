-- mclk/sclk = 4
-- mclk/lrck = 64

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
  signal sclk_cur   : std_logic;
  signal reg_dec    : std_logic_vector(DATA_LENGTH-1 downto 0);
  signal cpt_dout   : integer;  -- compte les bits ecrits sur dout
  signal reg_tready : std_logic;

begin

  process(clk, resetn) is

    begin

    if (resetn = '0') then
      cpt_clk    <= (others => '0');
      sclk_old   <= '0';
      sclk_cur   <= '0';
      reg_dec    <= (others => '0');
      cpt_dout   <= 0;
      reg_tready <= '0';

    elsif (rising_edge(clk)) then
      cpt_clk  <= cpt_clk + 1;
      sclk_old <= sclk_cur;
      sclk_cur <= cpt_clk(1);

      if (reg_tready = '1') then
        reg_tready <= '0';
      else end if;

      -- detection front montant sclk
      if (sclk_old = '0' and sclk_cur = '1') then
        -- nouvelle donnée
        if (cpt_dout = 0) then
          reg_dec    <= tdata;
          reg_tready <= '0';
          cpt_dout   <= 1;
        -- lecture 1 ; 14
        elsif (cpt_dout < DATA_LENGTH - 1) then
          reg_dec    <= reg_dec(reg_dec'length-2 downto 0) & '0';
          cpt_dout   <= cpt_dout + 1;
          reg_tready <= '0';
        -- dernière lecture (cpt_data = 15)
        else
          reg_dec    <= reg_dec(reg_dec'length-2 downto 0) & '0';
          cpt_dout   <= 0;
          reg_tready <= '1';
        end if;
      else end if;
    end if;

  end process;

  mclk   <= clk;
  sclk   <= cpt_clk(1);
  lrck   <= cpt_clk(6);
  tready <= reg_tready;
  dout   <= reg_dec(reg_dec'length - 1);

end architecture arch;
