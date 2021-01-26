library ieee;
use ieee.std_logic_1164.all;

entity axi_fft_config_tb is
end axi_fft_config_tb;

architecture arc_axi_fft_config_tb of axi_fft_config_tb is

  signal aresetn, aclk : std_logic;
  signal m_axis_tdata  : std_logic_vector(23 downto 0);
  signal m_axis_tvalid : std_logic;
  signal m_axis_tready : std_logic;

  constant clock_axi : time :=  2 ns;

begin

  axi_fft_config : entity work.axi_fft_config port map (	aresetn       => aresetn,
                                    	  									aclk          => aclk,
                                    	  									m_axis_tdata  => m_axis_tdata,
                                    	  									m_axis_tready => m_axis_tready,
                                    	  									m_axis_tvalid => m_axis_tvalid
	      						 	 	                               );

  clock_axi_p : process begin
      aclk <= '0';
      wait for clock_axi;
      aclk <= '1';
      wait for clock_axi;
  end process;

  aresetn_p : process begin
      aresetn <= '0';
      wait for 10*clock_axi;
      aresetn <= '1';
      wait for 50 us;
      wait;
  end process;

  tready_p : process begin
      m_axis_tready <= '0';
      wait for 2000*clock_axi;
      m_axis_tready <= '1';
      wait;
  end process;

end arc_axi_fft_config_tb;
