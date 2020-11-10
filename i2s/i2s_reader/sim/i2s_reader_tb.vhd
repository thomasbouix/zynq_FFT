library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader_tb is
end i2s_reader_tb;

architecture arc_i2s_reader_tb of i2s_reader_tb is
	signal reset, clk, mclk, sclk, lrck, din : std_logic; 
	signal data : std_logic_vector(15 downto 0);
	constant clock_t : time :=  44.288941 ns;
begin

	i2s_reader : entity work.i2s_reader 
    		port map (reset => reset, clk => clk, data => data, mclk => mclk, sclk => sclk, lrck=>lrck, din=>din);
	
	rst_p : process begin
		reset <= '1';
		wait for clock_t;
		reset <= '0';
		wait for 50 us;
		wait;
	end process;
	
	clock : process begin
		clk <= '0';
		wait for clock_t;
		clk <= '1';
		wait for clock_t;
	end process clock;
	
	data_in : process begin
		wait until rising_edge(sclk);
		din <= '0';
		wait until rising_edge(sclk);
		din <= '1';
		wait until rising_edge(sclk);
		din <= '0';
		wait until rising_edge(sclk);
		din <= '1';
		wait until rising_edge(sclk);
		din <= '1';
		wait until rising_edge(sclk);
		din <= '0';
		wait until rising_edge(sclk);
		din <= '0';
		wait until rising_edge(sclk);
		din <= '0';
	end process data_in;
	
	
end architecture arc_i2s_reader_tb ;
