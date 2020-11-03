-- I2S Reader en mode esclave + receiver
-- Lit la sortie de l'ADC et la formatte sur DATA_LENGTH bits

library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader is 
	generic(
		MCLK_FREQ	:	INTEGER := 22579200;	-- mclk/sclk = 8
		SCLK_FREQ	:	INTEGER := 2822400;	-- sclk/lrck = 64 
		LRCK_FREQ	:	INTEGER	:= 44100;	-- frequence d'echantillonage 
		DATA_LENGTH	:	INTEGER	:= 16
	);
	port(
		reset	:	in	std_logic;
		clk	:	in	std_logic;
		data	:	out	std_logic_vector((DATA_LENGTH-1) downto 0);
		
		mclk	:	out	std_logic;		-- clock du systeme
		sclk	:	out 	std_logic;		-- frequence din
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
		din	:	in 	std_logic		-- sortie de l'ADC
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is
	
	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);
	signal count_data	: 	integer range 0 to DATA_LENGTH;

	signal cmp_sclk		:	integer; -- range 0 to (CLK_FREQ/SCLK_FREQ);
	signal cmp_lrck		:	integer; -- range 0 to (CLK_FREQ/LRCK_FREQ);
	
	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;


begin

	process(clk,reset)
	begin
		if(reset = '1') then
			reg_data 	<= (others => '0');
			count_data 	<= 0;
			
			cmp_sclk  	<= 0;
			cmp_lrck 	<= 0;

			reg_sclk	<= '0';
			reg_lrck	<= '0';
			
		elsif rising_edge(clk) then
				
			if(cmp_sclk > ((MCLK_FREQ/SCLK_FREQ)/2)-2 ) then
				reg_sclk <= not(reg_sclk);
				cmp_sclk <= 0;
			else
				cmp_sclk <= cmp_sclk + 1;
			end if;
			
			if(cmp_lrck > ((MCLK_FREQ/LRCK_FREQ)/2)-2 ) then
				reg_lrck <= not(reg_lrck);
				cmp_lrck <= 0;
			else
				cmp_lrck <= cmp_lrck + 1;
			end if;
			
			if(reg_lrck = '1') then
				if(count_data < 16) then
					reg_data(count_data) <= din;
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
