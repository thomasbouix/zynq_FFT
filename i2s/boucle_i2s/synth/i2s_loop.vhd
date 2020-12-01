library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_loop is

  resetn : in std_logic;
  clk    : in std_logic;

  -- PMOD OUT : entrée de l'i2s reader
  mclko  : in std_logic;
  sclko  : in std_logic;
  lrcko  : in std_logic;
  din    : in std_logic;

  -- PMOD IN : sortie de l'i2s writer
  mclko  : in std_logic;
  sclko  : in std_logic;
  lrcko  : in std_logic;
  din    : in std_logic;


end entity;
