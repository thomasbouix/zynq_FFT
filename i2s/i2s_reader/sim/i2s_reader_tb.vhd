library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader_tb is
end i2s_reader_tb;

architecture arc_i2s_reader_tb of i2s_reader_tb is

  signal reset_n, clk : std_logic;
  signal mclk, sclk, lrclk, din : std_logic;
  signal data : std_logic_vector(15 downto 0);

  constant clock_t : time :=  44.288941 ns;

begin


  i2s_reader : entity work.i2s_reader port map (	reset_n => reset_n,
  							clk     => clk,
  							data    => data,
      							mclk    => mclk,
      							sclk    => sclk,
      							lrclk   => lrclk,
      							din     => din
      						 );

  clock_p : process begin
      clk <= '0';
      wait for clock_t;
      clk <= '1';
      wait for clock_t;
  end process;

  rst_p : process begin
      reset_n <= '0';
      wait for clock_t;
      reset_n <= '1';
      wait for 50 us;
      wait;
  end process;

  din_p : process begin
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
  end process;

end arc_i2s_reader_tb;
