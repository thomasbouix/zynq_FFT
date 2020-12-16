library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_loop is

  generic (
      DATA_LENGTH : integer := 16
  );

  port (
      reset_n : in std_logic;
      clk    : in std_logic;

      -- PMOD OUT : entrée de l'i2s reader
      mclko  : out std_logic;
      sclko  : out std_logic;
      lrclko : out std_logic;
      din    : in  std_logic;

      -- PMOD IN : sortie de l'i2s writer
      mclki  : out std_logic;
      sclki  : out std_logic;
      lrclki : out std_logic;
      dout   : out std_logic
  );

end entity;

architecture arch of i2s_loop is

  signal data : std_logic_vector(DATA_LENGTH-1 downto 0);

begin

    i2s_reader : entity work.i2s_reader
    generic map (
    	DATA_LENGTH => DATA_LENGTH
    )
    port map (
        reset_n => reset_n,
        clk     => clk,
        data    => data,
        mclk    => mclko,
        sclk    => sclko,
        lrclk   => lrclko, 
        din     => din
    );

    i2s_writer : entity work.i2s_writer
    generic map (
        DATA_LENGTH => DATA_LENGTH
    )
    port map (
        reset_n => reset_n,
        clk     => clk,
        data    => data,
        mclk    => mclki,
        sclk    => sclki,
        lrclk   => lrclki, 
        dout    => dout
    );

end architecture;
