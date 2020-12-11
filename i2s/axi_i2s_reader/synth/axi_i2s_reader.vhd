-- I2S Reader en mode esclave + receiver
-- Lit la sortie de l'ADC et la formatte sur DATA_LENGTH bits en sortie

-- mclk/sclk = 4
-- mclk/lrck = 64

library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader is

  generic(
    DATA_LENGTH : INTEGER := 16
  );

	port(
		resetn  :	in	std_logic;		-- fourni par le systeme
		clk	    :	in	std_logic;		-- fourni par le systeme
		data	  :	out	std_logic_vector((DATA_LENGTH-1) downto 0);

    -- AXI
		tready	: in  std_logic;   -- on ignore ici
		tvalid	: out std_logic;
		tlast		: out std_logic;
		tdata		:	out	std_logic_vector((DATA_LENGTH-1) downto 0);

		mclk	:	out	std_logic;		-- clock du systeme
		sclk	:	out std_logic;		-- bit clock : frequence de din
		lrck	:	out std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din	  :	in 	std_logic		  -- sortie de l'ADC
	);
end entity i2s_reader;

architecture arch of i2s_reader is

  signal cpt_clk		:	unsigned (5 downto 0);
  signal cpt_data   : integer;  -- nombre de données envoyées
  signal sclk_old   : std_logic;
  signal reg_dec    : std_logic(DATA_LENGTH-1 downto 0);

begin

  process(clk, resetn) is

    begin

    if (resetn = '0') then
      cpt_clk    <= 0;
      count_data <= 0;
      cpt_data   <= 0;

    elsif (rising_edge(clk)) then
      cpt_clk <= cpt_clk + 1;

      -- detection front montant sclk
      if (sclk_old = '0' and cpt_clk(1) = '1') then

        count_data <= count_data + 1;

        if (count_data >= 1 and count_data <= DATA_LENGTH) then
          -- on remplit de droite à gauche
          reg_dec <= reg_dec(reg_dec'length-2 downto 0) & din;
          tvalid  <= '0';

        -- donnée prête
        elsif (count_data >= DATA_LENGTH + 1) then
          count_data <= 0;
          data <= reg_dec;
          tvalid <= '1';

          if (cpt_data < 2048) then
            cpt_data <= cpt_data + 1;
            tlast <= '0';
          elsif (cpt_data >= 2048) then
            cpt_data <= 0;
            tlast <= '1';
          else end if;

        else end if;
      else end if;
    end if;

  end process;

  mclk <= clk;
  sclk <= cpt_clk(1);
  lrck <= cpt_clk(5);

end architecture arch;
