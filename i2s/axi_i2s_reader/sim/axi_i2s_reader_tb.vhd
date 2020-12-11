library ieee;
use ieee.std_logic_1164.all;

entity axi_i2s_reader_tb is
end axi_i2s_reader_tb;

architecture arc of axi_i2s_reader_tb is

  signal resetn, clk : std_logic;
  signal mclk, sclk, lrck, din : std_logic;
  signal tvalid, tready, tlast : std_logic;
  signal tdata : std_logic_vector(15 downto 0);

  constant clock_t : time :=  44.288941 ns;

begin


  axi_i2s_reader : entity work.axi_i2s_reader port map (
      resetn=>resetn, clk=>clk,
      mclk=>mclk, sclk=>sclk, lrck=>lrck, din=>din,
      tvalid=>tvalid, tready=>tready, tlast=>tlast,
      tdata=>tdata);

  ready_p : process begin
      tready <= '1';
      wait for 200 us;
      tready <= '0';
      wait for 20 us;
  end process;

  clock : process begin
      clk <= '0';
      wait for clock_t;
      clk <= '1';
      wait for clock_t;
  end process clock;

  rst_p : process begin
      resetn <= '0';
      wait for clock_t;
      resetn <= '1';
      wait for 50 us;
      wait;
  end process;

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

end arc;
