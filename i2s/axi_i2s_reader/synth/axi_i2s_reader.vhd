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
		tdata		:	out	std_logic_vector((DATA_LENGTH-1) downto 0);	-- sortie sur 2 octets envoyé quand (READY&VALID)

		-- I2S
		mclk	:	out		std_logic;		-- clock du systeme ==> fréquence d'échantillonage
		sclk	:	out 	std_logic;		-- bit clock : frequence des bits de DIN
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din		:	in 		std_logic			-- sortie du PMOD
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is

	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);
	signal count_data	: integer; -- range 0 to DATA_LENGTH + 1;

	signal cpt_sclk		:	unsigned(1 downto 0);		-- divise par 4 mclk
	signal cpt_lrck		:	unsigned(5 downto 0);		-- divise par 64 mclk

	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;

	signal tvalid_reg : std_logic;

begin

	-- Generation de SCLK et LRCK
	clocks_p : process(clk, resetn) begin
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
	end process clocks_p;

	mclk <= clk;
	sclk <= reg_sclk;
	lrck <= reg_lrck;

	-- Gestion des donnees : construction reg_data en continue
	-- TVALID_REG = '1' si une donnée est prête
 	data_p : process (resetn, reg_sclk)
       	begin
		if (resetn = '0') then
			reg_data 		<= (others => '0');
			count_data 	<= 0;
			tdata 			<= (others => '0');

		elsif rising_edge(reg_sclk) then -- on n'écoute qu'une seule voix stereo

			-- on laisse un bit de décalage au début
			if (count_data = 0) then
				count_data <= 1; 				-- ecriture de din[1:16] (din[0:15] décalé de 1)
			elsif (count_data > 0) and (count_data < DATA_LENGTH + 1) then
				reg_data(count_data - 1) <= din;
				count_data <= count_data + 1;
				-- donnée prête
				if ( count_data = DATA_LENGTH ) then
					tvalid_reg <= '1';
					tdata <= reg_data;
				end if;

			else
				tvalid_reg	<= '0';
				count_data 	<= 0;
				reg_data 		<= (others => '0');
			end if;
		end if;
	end process data_p;

	tvalid <= tvalid_reg;

end architecture arc_i2s_reader;
