library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader_tb is
	generic(
			MCLK_FREQ	:	INTEGER := 22579200;	-- mclk/sclk = 8
			SCLK_FREQ	:	INTEGER := 2822400;	-- sclk/lrck = 64 
			LRCK_FREQ	:	INTEGER	:= 44100;	-- frequence d'echantillonage 
			DATA_LENGTH	:	INTEGER	:= 16		-- taille des données de l'ADC
	);

end i2s_reader_tb;

architecture arc_i2s_reader_tb of i2s_reader_tb is
    signal reset, clk, mclk, sclk, lrck, din : std_logic; 
    signal data : std_logic_vector(15 downto 0);
begin

    i2s_reader : entity work.i2s_reader 
    	generic map(MCLK_FEQ => MCLK_FREQ, SCLK_FREQ => SCLK_FREQ, LRCK_FREQ => LRCK_FREQ, DATA_LENGTH => DATA_LENGTH)
    	port map (reset => reset, clk => clk, data => data, mclk => mclk, sclk => sclk, lrck=>lrck, din=>din);
	
	process
	begin
		reset <= '1';
		wait for 44.288941 ns;
		reset <= '0';
		wait for 50 us;

		wait;
	end process;
	
	process
	begin
	
		clk <= '0';
		wait for 1/MCLK_FREQ ns;
		clk <= '1';
		wait for 1/MCLK_FREQ ns;
	
	end process;
	
	process
	begin
	
		wait for 1/SCLK_FREQ ns;
		din <= '0';
		wait for 1/SCLK_FREQ ns;
		din <= '1';
		wait for 1/SCLK_FREQ ns;
		din <= '0';
		wait for 1/SCLK_FREQ ns;
		din <= '0';
		wait for 1/SCLK_FREQ ns;
		din <= '1';
		wait for 1/SCLK_FREQ ns;
		din <= '1';
		wait for 1/SCLK_FREQ ns;
		
	end process;
	
	
end architecture arc_i2s_reader_tb ;
