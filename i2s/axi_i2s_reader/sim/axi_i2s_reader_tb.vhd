library ieee;
use ieee.std_logic_1164.all;

entity axi_i2s_reader_tb is
end axi_i2s_reader_tb;

architecture arc of axi_i2s_reader_tb is

  signal reset, clk : std_logic;
  signal mclk, sclk, din : std_logic;
  signal tvalid, tready : std_logic;
  signal tdata : std_logic_vector(15 downto 0);

begin

  axi_i2s_reader : entity work.i2s_reader port map (
                      reset=>reset, clk=>clk,
                      mclk=>mclk, sclk=>sclk, lrck=>lrck, din=>din,
                      tvalid=>tvalid, tready=>tready,
                      tdata=>tdata);
end arc;
