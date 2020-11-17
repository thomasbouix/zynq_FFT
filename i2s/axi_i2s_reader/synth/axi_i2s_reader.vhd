-- I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader is
	generic(
		MCLK_FREQ		:	INTEGER := 22579200;	-- mclk/sclk = 8
		SCLK_FREQ		:	INTEGER := 2822400;		-- sclk/lrck = 64
		LRCK_FREQ		:	INTEGER	:= 44100;			-- frequence d'echantillonage
		DATA_LENGTH	:	INTEGER	:= 16					-- taille des données du PMOD
	);
	port(
		-- SYSTEM
		reset	:	in	std_logic;
		clk		:	in	std_logic;

		-- AXI
		tready	: in std_logic;		-- envoyé par l'esclave : on envoie une donnée puis on bloque jusqu'à avoir un TREADY
		tvalid	: out std_logic;	-- mis à 1 quand une donnée est disponible (écrite sur le bus)
		tdata		:	out	std_logic_vector((DATA_LENGTH-1) downto 0);	-- sortie sur 2 octets, on enchaine à chaque READY

		-- I2S
		mclk	:	out		std_logic;		-- clock du systeme
		sclk	:	out 	std_logic;		-- bit clock : frequence de din
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din		:	in 		std_logic			-- sortie du PMOD
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is

	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);
	signal count_data	: integer; --range 0 to DATA_LENGTH + 1;

	signal cpt_sclk		:	integer; -- range 0 to (MCLK_FREQ/SCLK_FREQ) - 1;
	signal cpt_lrck		:	integer; -- range 0 to (MCLK_FREQ/LRCK_FREQ) - 1;

	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;


begin

	-- Generation de SCLK et LRCK
	clocks_p : process(clk, reset)
	begin
		if(reset = '1') then

			cpt_sclk  <= 0;
			cpt_lrck 	<= 0;
			reg_sclk	<= '0';
			reg_lrck	<= '0';

		elsif rising_edge(clk) then

			if (cpt_sclk = ((MCLK_FREQ/SCLK_FREQ)-1)) then	-- 7
				reg_sclk <= not(reg_sclk);
				cpt_sclk <= 0;
			else
				cpt_sclk <= cpt_sclk + 1;
			end if;

			if (cpt_lrck = ((SCLK_FREQ/LRCK_FREQ)-1)) then	-- 63
				reg_lrck <= not(reg_lrck);
				cpt_lrck <= 0;
			else
				cpt_lrck <= cpt_lrck + 1;
			end if;
		end if;
	end process clocks_p;

	-- Gestion des donnees : construction reg_data en continue
	-- TVALID = '1' si une donnée est prête
 	data_p : process (reset, reg_sclk)
       	begin
		if (reset = '1') then
			reg_data 	<= (others => '0');
			count_data 	<= 0;
			tdata 		<= (others => '0');

		elsif rising_edge(reg_sclk) then -- on n'écoute qu'une seule voix stereo

			if (count_data = 0) then -- on laisse un bit de décalage au début
				count_data <= 1; -- ecriture de din[1:16] (din[0:15] décalé de 1)

			elsif (count_data > 0) and (count_data < DATA_LENGTH + 1) then
				reg_data(count_data - 1) <= din;
				count_data <= count_data + 1;
			elsif (count_data = DATA_LENGTH) then
				tvalid <= '1';
				count_data <= count_data + 1;
			else
				tvalid <= '0';
				count_data 	<= 0;
				reg_data 	<= (others => '0');
				tvalid <= '0';
			end if;
		end if;
	end process data_p;

	-- On ne produit tdata que si une donnée est 'valid', et que le dma est 'ready'
	-- On drop les pacquets sinon
	state_p : process(clk, reset) is
	begin
			if (rising_edge(clk)) then
				if (tvalid = '1' and tready = '1') then
					tdata <= reg_data;
				else
					tdata <= (others => '0');
				end if;
			end if;
	end process state_p;


end architecture arc_i2s_reader;
