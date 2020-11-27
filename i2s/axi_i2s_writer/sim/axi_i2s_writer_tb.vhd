library ieee;
use ieee.std_logic_1164.all;

entity axi_i2s_writer_tb is
end axi_i2s_writer_tb;

architecture arc of axi_i2s_writer_tb is

  signal resetn, clk            : std_logic;
  signal mclk, sclk, lrck       : std_logic;
  signal tvalid, tready, tlast  : std_logic;
  signal tdata, dout            : std_logic_vector(15 downto 0);

  constant clock_t  : time :=  44.288941 ns;
  signal compteur   : integer;

begin

  axi_i2s_writer : entity work.i2s_writer port map (
      resetn=>resetn, clk=>clk,
      mclk=>mclk, sclk=>sclk, lrck=>lrck, dout=>dout,
      tvalid=>tvalid, tready=>tready, tlast=>tlast,
      tdata=>tdata);

  tvalid <= '1';
  tlast <= '0';

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

  -- data envoyée par le i2s reader
  data_in : process (clk, resetn) begin
    if (resetn = '0') then
        compteur <= 0;
    else
        if rising_edge(clk) then
            if (compteur = 15) then
              tdata <= x"ffff";
              compteur <= compteur + 1;
            elsif (compteur = 31) then
              tdata <= x"aaaa";
              compteur <= 0;
            else
              compteur <= compteur + 1;
            end if;
        end if;
    end if;
  end process;

end arc;
