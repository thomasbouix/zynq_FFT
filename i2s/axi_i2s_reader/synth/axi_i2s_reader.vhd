-- I2S Reader en mode esclave + receiver
-- Lit la sortie de l'ADC et la formatte sur DATA_LENGTH bits en sortie

-- mclk/sclk = 4
-- mclk/lrck = 256
-- sclk/lrck = 64
-- ==> single speed mode

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_reader is

  generic(
    DATA_LENGTH : INTEGER := 16
  );

	port(
		resetn  :	in	std_logic;		-- fourni par le systeme
		clk	    :	in	std_logic;		-- fourni par le systeme
		data	  :	out	std_logic_vector((DATA_LENGTH-1) downto 0);

    -- AXI
		tready	: in  std_logic;   -- on ignore ici
		tvalid	: out std_logic;   -- 1 quand on update une donnée, 0 sinon
		tlast		: out std_logic;   -- 1 tous les 2048 envois
		tdata		:	out	std_logic_vector((DATA_LENGTH-1) downto 0);

		mclk    :	out	std_logic;		-- clock du systeme
		sclk	  :	out std_logic;		-- bit clock : frequence de din
		lrck	  :	out std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din	    :	in 	std_logic		  -- sortie de l'ADC
	);
end entity axi_i2s_reader;

architecture arch of axi_i2s_reader is

  signal cpt_clk		:	unsigned (7 downto 0);
  signal cpt_din    : integer;  -- nombre de din reçu
  signal cpt_data   : integer;  -- nombre de données envoyées
  signal sclk_old   : std_logic;
  signal sclk_cur   : std_logic;
  signal lrck_old   : std_logic;
  signal reg_dec    : std_logic_vector(DATA_LENGTH-1 downto 0);
  signal reg_tvalid : std_logic;

begin

  process(clk, resetn) is

    begin

    if (resetn = '0') then
      cpt_clk    <= (others => '0');
      cpt_din    <= 0;
      cpt_data   <= 0;
      sclk_old   <= '0';
      sclk_cur   <= '0';
      lrck_old   <= '0';

      reg_dec    <= (others => '0');
      reg_tvalid <= '0';
      tdata      <= (others => '0');
      tlast      <= '0';

    elsif (falling_edge(clk)) then
      cpt_clk  <= cpt_clk + 1;
      sclk_old <= sclk_cur;
      sclk_cur <= not(cpt_clk(1));
      lrck_old <= cpt_clk(7);       -- un clk de retard

      -- on ne laisse tvalid que un coup de clk
      if (reg_tvalid = '1') then
        reg_tvalid <= '0';
      else end if;

      -- front descendant lrck = nouvelle donnée PMOD
      -- sorte de reset
      if (lrck_old = '1' and cpt_clk(7) = '0') then
          cpt_din <= 0;
      -- front montant sclk
      elsif (sclk_old = '1' and sclk_cur = '0') then
          cpt_din <= cpt_din + 1;

          -- on remplit reg_dec sur 16 din : din(MSB) = 1, din(LSB) = 16
          if (cpt_din >= 1 and cpt_din <= DATA_LENGTH) then
            -- on remplit de droite à gauche
            reg_dec <= reg_dec(reg_dec'length-2 downto 0) & din;
          else end if;

          -- donnée prête
          if (cpt_din  = DATA_LENGTH) then
              tdata      <= reg_dec;
              reg_tvalid <= '1';
              reg_dec    <= (others => '0');

              if (cpt_data < 2048) then
                cpt_data <= cpt_data + 1;
                tlast    <= '0';
              elsif (cpt_data >= 2048) then
                cpt_data <= 0;
                tlast    <= '1';
              else end if;
          else end if;
      else end if;
  end if;
  end process;

  mclk   <= clk;
  sclk   <= not(cpt_clk(1));
  lrck   <= cpt_clk(7);
  tvalid <= reg_tvalid;

end architecture arch;
