-- I2S Reader en mode esclave + receiver
-- Lit la sortie de l'ADC et la formatte sur DATA_LENGTH bits en sortie

library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader is 
	generic(
		MCLK_FREQ	:	INTEGER := 22579200;	-- mclk/sclk = 8
		SCLK_FREQ	:	INTEGER := 2822400;	-- sclk/lrck = 64 
		LRCK_FREQ	:	INTEGER	:= 44100;	-- frequence d'echantillonage 
		DATA_LENGTH	:	INTEGER	:= 16		-- taille des données de l'ADC
	);
	port(
		reset	:	in	std_logic;		-- fourni par le systeme
		clk	:	in	std_logic;		-- fourni par le systeme
		data	:	out	std_logic_vector((DATA_LENGTH-1) downto 0);
		
		mclk	:	out	std_logic;		-- clock du systeme
		sclk	:	out 	std_logic;		-- bit clock : frequence de din
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din	:	in 	std_logic		-- sortie de l'ADC
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is
	
	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);
	signal count_data	: 	integer; --range 0 to DATA_LENGTH + 1;

	signal cpt_sclk		:	integer; -- range 0 to (MCLK_FREQ/SCLK_FREQ) - 1;
	signal cpt_lrck		:	integer; -- range 0 to (MCLK_FREQ/LRCK_FREQ) - 1;
	
	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;


begin

	process(clk,reset)
	begin
		if(reset = '1') then
			reg_data 	<= (others => '0');
			count_data 	<= 0;
			
			cpt_sclk  	<= 0;
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

			-- on n'écoute qu'une seule voix stereo
			if rising_edge(reg_sclk) then				
				-- on laisse un bit de décalage au début		
				if (count_data = 0) then
					count_data <= 1;
				-- ecriture de din[1:16] (din[0:15] décalé de 1)
				elsif (count_data > 0) and (count_data < DATA_LENGTH + 1) then		
					reg_data(count_data - 1) <= din;
					count_data <= count_data + 1;
				else
					count_data <= count_data + 1;
				end if;
			else
				count_data <= 0;
			end if;
				
		end if;
	
	end process;
	
	data <= reg_data;
	
	mclk <= clk;
	sclk <= reg_sclk;
	lrck <= reg_lrck;


end architecture arc_i2s_reader;
