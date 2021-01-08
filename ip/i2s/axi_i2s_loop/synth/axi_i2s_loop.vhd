library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_loop is
  generic(
    DATA_LEN         : INTEGER := 32;
    LEN_PKT          : INTEGER := 16;
    SAMPLE_LEN       : INTEGER := 32
  );
  port (
      -- AXI Clock
      aresetn          : in std_logic;
      aclk             : in std_logic;

      -- Master AXI Interface
      m_axis_tdata  	 : out  std_logic_vector((DATA_LEN - 1) downto 0);
      m_axis_tkeep 	   : out  std_logic_vector(((DATA_LEN / 8) - 1) downto 0);
      m_axis_tlast 	   : out  std_logic;
      m_axis_tready 	 : in   std_logic;
      m_axis_tvalid 	 : out  std_logic;

      -- Slave AXI Interface
      s_axis_tdata  	 : in   std_logic_vector((DATA_LEN - 1) downto 0);
      s_axis_tkeep 	   : in   std_logic_vector(((DATA_LEN / 8) - 1) downto 0);
      s_axis_tlast 	   : in   std_logic;
      s_axis_tready 	 : out  std_logic;
      s_axis_tvalid 	 : in   std_logic;

      -- I2S Clock
      i2s_clk          : in std_logic;

      -- PMOD OUT : entrée de l'i2s reader
      mclko            : out std_logic;
      sclko            : out std_logic;
      lrclko           : out std_logic;
      din              : in  std_logic;

      -- PMOD IN : sortie de l'i2s writer
      mclki            : out std_logic;
      sclki            : out std_logic;
      lrclki           : out std_logic;
      dout             : out std_logic
  );

end entity axi_i2s_loop;

architecture arc_axi_i2s_loop of axi_i2s_loop is

begin

    axi_i2s_reader : entity work.axi_i2s_reader
    generic map(
    		DATA_LEN      => DATA_LEN,
    		LEN_PKT       => LEN_PKT,
    		SAMPLE_LEN    => SAMPLE_LEN
    	)
      port map (
        aresetn       => aresetn,
        aclk          => aclk,
        i2s_clk       => i2s_clk,
        m_axis_tdata  => m_axis_tdata,
        m_axis_tkeep  => m_axis_tkeep,
        m_axis_tlast  => m_axis_tlast,
        m_axis_tready => m_axis_tready,
        m_axis_tvalid => m_axis_tvalid,
        mclk          => mclko,
        sclk          => sclko,
        lrclk         => lrclko,
        din           => din
      );

    axi_i2s_writer : entity work.axi_i2s_writer
    	generic map(
    		DATA_LEN      => DATA_LEN,
    		LEN_PKT       => LEN_PKT,
    		SAMPLE_LEN    => SAMPLE_LEN
    	)
      port map (
        aresetn       => aresetn,
        aclk          => aclk,
        i2s_clk       => i2s_clk,
        s_axis_tdata  => s_axis_tdata,
        s_axis_tkeep  => s_axis_tkeep,
        s_axis_tlast  => s_axis_tlast,
        s_axis_tready => s_axis_tready,
        s_axis_tvalid => s_axis_tvalid,
        mclk          => mclki,
        sclk          => sclki,
        lrclk         => lrclki,
        dout          => dout
      );

end architecture arc_axi_i2s_loop;
