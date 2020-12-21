library ieee;
use ieee.std_logic_1164.all;

entity axi_i2s_reader_tb is
end axi_i2s_reader_tb;

architecture arc_axi_i2s_reader_tb of axi_i2s_reader_tb is

  signal aresetn, aclk                : std_logic;
  signal m_axis_tdata                 : std_logic_vector(31 downto 0);
  signal m_axis_tvalid, m_axis_tready : std_logic;
  
  signal mclk, sclk, lrck, din        : std_logic;

  constant clock_i2s : time :=  44.288941 ns;
  constant clock_axi : time :=  2 ns;

begin 

  axi_i2s_reader : entity work.axi_i2s_reader port map (	aresetn       => aresetn,
	  							aclk          => aclk,
	  							m_axis_tdata  => m_axis_tdata,
	  							m_axis_tvalid => m_axis_tvalid,
	  							m_axis_tready => m_axis_tready,
	      							mclk          => mclk,
	      							sclk          => sclk,
	      							lrck          => lrck,
	      							din           => din
	      						 );

  clock_i2s_p : process begin
      mclk <= '0';
      wait for clock_i2s;
      mclk <= '1';
      wait for clock_i2s;
  end process;
  
  clock_axi_p : process begin
      aclk <= '0';
      wait for clock_axi;
      aclk <= '1';
      wait for clock_axi;
  end process;

  aresetn_p : process begin
      aresetn <= '0';
      wait for clock_i2s;
      aresetn <= '1';
      wait for 50 us;
      wait;
  end process;
  
  tready_p : process begin
      m_axis_tready <= '0';
      wait for clock_i2s;
      m_axis_tready <= '1';
      wait;
  end process;
  
  din_p : process begin
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
  end process;

end arc_axi_i2s_reader_tb;
