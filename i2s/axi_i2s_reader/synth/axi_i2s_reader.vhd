-- I2S Reader en mode esclave + receiver
-- mclk/sclk = 4 (cf M.BRESSON)
-- mclk/lrck = 64

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_reader is
	generic(
		DATA_LENGTH	:	INTEGER	:= 16			-- taille des données du PMOD
	);
	port(
		-- SYSTEM
		resetn	:	in	std_logic;	-- RESET ACTIVE LOW
		clk			:	in	std_logic;

		-- AXI
		tready	: in  std_logic;		-- slave prêt à recevoir
		tvalid	: out std_logic;  	-- master prêt à transmettre
		tlast		: out std_logic;		-- 1 après 2048 transferts => 4096 octets == 1 page
		tdata		:	out	std_logic_vector((DATA_LENGTH-1) downto 0);	-- sortie sur 2 octets envoyé quand (READY&VALID)

		-- I2S
		mclk	:	out		std_logic;		-- clock du systeme ==> fréquence d'échantillonage
		sclk	:	out 	std_logic;		-- bit clock : frequence des bits de DIN
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din		:	in 		std_logic			-- sortie du PMOD
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is

	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);	-- construction en continue
	signal data_ready	: std_logic_vector((DATA_LENGTH-1) downto 0);	-- sauvegarde le dernier data construit
	signal count_data	: integer; -- range 0 to DATA_LENGTH + 1;

	signal cpt_sclk		:	unsigned(1 downto 0);		-- divise par 4 mclk
	signal cpt_lrck		:	unsigned(5 downto 0);		-- divise par 64 mclk

	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;

	signal reg_tvalid : std_logic;
	signal cpt_tlast	: unsigned(9 downto 0);

begin

	-- Generation des clocks i2s SCLK, LRCK
	i2s_p : process(clk, resetn) begin
			if(resetn = '0') then
						cpt_sclk  <= (others => '0');
						cpt_lrck 	<= (others => '0');
						reg_sclk	<= '0';
						reg_lrck	<= '0';
			elsif rising_edge(clk) then
						cpt_lrck <= cpt_lrck + 1;
						cpt_sclk <= cpt_sclk + 1;
						reg_sclk <= cpt_sclk(1);
						reg_lrck <= cpt_lrck(5);
			end if;
	end process i2s_p;

	mclk <= clk;
	sclk <= reg_sclk;
	lrck <= reg_lrck;

	-- Gestion des donnees : construction reg_data en continue
	-- actualisation de data_ready quand une donnée est prête
	data_p : process (resetn, reg_sclk) begin
			if (resetn = '0') then
					count_data 	<= 0;
					reg_data 		<= (others => '0');		-- construction en continue
					data_ready	<= (others => '0');		-- sauvegarde d'une donnée complète

			-- on n'écoute qu'une seule voix stereo
			elsif rising_edge(reg_sclk) then

					-- on laisse un bit de décalage au début
						if (count_data = 0) then
								-- ecriture de din[1:16] (din[0:15] décalé de 1)
								count_data <= 1;
						elsif ((count_data > 0) and (count_data < DATA_LENGTH + 1)) then
								reg_data(count_data - 1) <= din;
								count_data <= count_data + 1;
								-- donnée prête
								if ( count_data = DATA_LENGTH ) then
										data_ready <= reg_data;
								else end if;
						else
									count_data 	<= 0;
									reg_data 		<= (others => '0');
						end if;
			end if;
	end process data_p;

	-- actualisation des signaux AXI
		-- tvalid
		-- tlast
		-- tdata
	axi_p : process(resetn, reg_sclk) begin
			if (resetn = '0') then
					reg_tvalid 	<= '0';
					cpt_tlast		<= (others => '0');
					tvalid 			<= '0';
					tdata	 			<= (others => '0');
					tlast  			<= '0';

			else
					-- nouvelle donnée disponible
					if (count_data = DATA_LENGTH) then
							reg_tvalid <= '1';
					else end if;

					-- envoie des données
					if (tready = '1' and reg_tvalid = '1') then
							tdata 			<= data_ready;
							reg_tvalid 	<= '0';
							cpt_tlast 	<= cpt_tlast + 1;
					else end if;

					-- génération de tlast
					if rising_edge(cpt_tlast(9)) then	-- tous les 2048 envois
							tlast <= '1';
					else
							tlast <= '0';
					end if;
			end if;
	end process axi_p;

end architecture arc_i2s_reader;
