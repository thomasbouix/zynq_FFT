library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_loop_tb is

end entity;

architecture arch of i2s_loop_tb is

  constant clock_t : time :=  44.288941 ns;

  signal clk, resetn               : std_logic;
  signal mclki, sclki, lrcki, din  : std_logic;
  signal mclko, sclko, lrcko, dout : std_logic;

begin

  axi_i2s_loop : entity work.i2s_loop port map (
      resetn=>resetn, clk=>clk,
      mclko=>mclko, sclko=>sclko, lrcko=>lrcko, din=>din,
      mclki=>mclki, sclki=>sclki, lrcki=>lrcki, dout=>dout
  );

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

  data_p : process(resetn, sclki) begin
    if rising_edge(resetn) then
        din <= '1';
    else
        if rising_edge(sclki) then
          din <= not(din);
        end if;
    end if;
  end process;

end architecture;
