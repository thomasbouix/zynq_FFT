library ieee;
use ieee.std_logic_1164.all;

entity i2s_writer_tb is
end i2s_writer_tb;

architecture arc_i2s_writer_tb of i2s_writer_tb is

  signal reset_n, clk : std_logic;
  signal mclk, sclk, lrclk, dout : std_logic;
  signal data : std_logic_vector(15 downto 0);

  constant clock_t : time :=  44.288941 ns;
  signal counter   : integer;

begin


  i2s_writer : entity work.i2s_writer port map (	reset_n => reset_n,
  							clk     => clk,
  							data    => data,
      							mclk    => mclk,
      							sclk    => sclk, 
      							lrclk   => lrclk,
      							dout    => dout
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

  -- data envoyée par le i2s reader
  data_in : process (lrclk, reset_n) begin
    if (reset_n = '0') then
      counter <= 0;
    elsif rising_edge(lrclk) then
      if (counter = 0) then
        data <= x"0001";
        counter <= counter + 1;
      elsif (counter = 1) then
        data <= x"000A";
        counter <= counter + 1;
      elsif (counter = 2) then
        data <= x"FF01";
        counter <= counter + 1;
      elsif (counter = 3) then
        data <= x"AAAA";
        counter <= counter + 1;
      elsif (counter = 4) then
        data <= x"0A0F";
        counter <= counter + 1;
      elsif (counter = 5) then
      	counter <= 0;
      else end if;
    else end if;
  end process;

end arc_i2s_writer_tb;
