library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_loop is

  generic (
      DATA_LENGTH : integer := 16
  );

  port (
      resetn : in std_logic;
      clk    : in std_logic;

      -- PMOD OUT : entrée de l'i2s reader
      mclko  : out std_logic;
      sclko  : out std_logic;
      lrcko  : out std_logic;
      din    : in  std_logic;

      -- PMOD IN : sortie de l'i2s writer
      mclki  : out std_logic;
      sclki  : out std_logic;
      lrcki  : out std_logic;
      dout   : out std_logic
  );

end entity;

architecture arch of i2s_loop is

  signal tvalid, tready, tlast : std_logic;
  signal tdata : std_logic_vector(DATA_LENGTH-1 downto 0);

begin

    i2s_reader : entity work.axi_i2s_reader
    generic map (
        DATA_LENGTH=>DATA_LENGTH
    )
    port map (
        resetn=>resetn, clk=>clk,
        mclk=>mclko, sclk=>sclko, lrck=>lrcko, din=>din,
        tvalid=>tvalid, tready=>tready, tlast=>tlast,
        tdata=>tdata
    );

    i2s_writer : entity work.axi_i2s_writer
    generic map (
        DATA_LENGTH=>DATA_LENGTH
    )
    port map (
        resetn=>resetn, clk=>clk,
        mclk=>mclki, sclk=>sclki, lrck=>lrcki, dout=>dout,
        tvalid=>tvalid, tready=>tready, tlast=>tlast,
        tdata=>tdata
    );

end architecture; 
