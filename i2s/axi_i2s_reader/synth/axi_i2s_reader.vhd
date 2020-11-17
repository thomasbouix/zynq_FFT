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
		tdata	:	out	std_logic_vector((DATA_LENGTH-1) downto 0);

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


end architecture arc_i2s_reader;
