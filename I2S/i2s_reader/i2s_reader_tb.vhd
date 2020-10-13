library ieee;
use ieee.std_logic_1164.all;


entity i2s_reader_tb is
end i2s_reader_tb;

architecture arc_i2s_reader_tb of i2s_reader_tb is
    signal reset, clk, mclk, sclk, lrck, din : std_logic; 
    signal data : std_logic_vector(15 downto 0);
begin

    U : entity work.i2s_reader port map (reset => reset, clk => clk, data => data, mclk => mclk, sclk => sclk, lrck=>lrck, din=>din);
	
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
		wait for 22.1444705 ns;
		clk <= '1';
		wait for 22.1444705 ns;
	
	end process;
	
	process
	begin
	
		wait for 22.1444705 ns;
		din <= '0';
		wait for 44.288941 ns;
		din <= '1';
		wait for 44.288941 ns;
		din <= '0';
		wait for 44.288941 ns;
		din <= '0';
		wait for 44.288941 ns;
		din <= '1';
		wait for 44.288941 ns;
		din <= '1';
		wait for 44.288941 ns;
		
	end process;
	
	
end architecture arc_i2s_reader_tb ;
