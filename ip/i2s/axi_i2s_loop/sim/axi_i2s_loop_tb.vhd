library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_loop_tb is
end entity;

architecture arc_axi_i2s_loop_tb of axi_i2s_loop_tb is

  constant clock_axi : time :=  5 ns;
  constant clock_i2s : time :=  20.3450521 ns;

  signal aclk, i2s_clk, aresetn     : std_logic;
  signal mclki, sclki, lrclki, din  : std_logic;
  signal mclko, sclko, lrclko, dout : std_logic;
  signal cpt : integer := 0;

  signal m_axis_tdata  : std_logic_vector(31 downto 0);
  signal m_axis_tkeep  : std_logic_vector(3 downto 0);
  signal m_axis_tvalid : std_logic;
  signal m_axis_tready : std_logic;
  signal m_axis_tlast  : std_logic;

  signal s_axis_tdata  : std_logic_vector(31 downto 0);
  signal s_axis_tkeep  : std_logic_vector(3 downto 0);
  signal s_axis_tvalid : std_logic;
  signal s_axis_tready : std_logic;
  signal s_axis_tlast  : std_logic;

begin

  axi_i2s_loop : entity work.axi_i2s_loop port map (
      aresetn       => aresetn,
      aclk          => aclk,
      m_axis_tdata  => m_axis_tdata,
      m_axis_tkeep  => m_axis_tkeep,
      m_axis_tlast  => m_axis_tlast,
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      s_axis_tdata  => s_axis_tdata,
      s_axis_tkeep  => s_axis_tkeep,
      s_axis_tlast  => s_axis_tlast,
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid,
      i2s_clk       => i2s_clk,
      mclko         => mclko,
      sclko         => sclko,
      lrclko        => lrclko,
      din           => din,
      mclki         => mclki,
      sclki         => sclki,
      lrclki        => lrclki,
      dout          => dout
  );

  clock_axi_p : process begin
      aclk <= '0';
      wait for clock_axi;
      aclk <= '1';
      wait for clock_axi;
  end process clock_axi_p;

  clock_i2s_p : process begin
      i2s_clk <= '0';
      wait for clock_i2s;
      i2s_clk <= '1';
      wait for clock_i2s;
  end process clock_i2s_p;

  rst_p : process begin
      aresetn <= '0';
      wait for clock_i2s;
      aresetn <= '1';
      wait for 50 us;
      wait;
  end process;

  data_p : process(aresetn, sclki)
  begin
    if rising_edge(sclki) then
        if (cpt = 0) then
          din <= '1';
          cpt <= cpt + 1;
        elsif (cpt = 1) then
          din <= '1';
          cpt <= cpt + 1;
        elsif (cpt = 2) then
          din <= '0';
          cpt <= 0;
        else end if;
    else end if;
  end process;

  s_axis_tdata  <= m_axis_tdata;
  s_axis_tkeep  <= m_axis_tkeep;
  s_axis_tlast  <= m_axis_tlast;
  m_axis_tready <= s_axis_tready;
  s_axis_tvalid <= m_axis_tvalid;

end architecture arc_axi_i2s_loop_tb;
