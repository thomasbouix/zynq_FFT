library ieee;
use ieee.std_logic_1164.all;

entity axi_interface_test_tb is
end axi_interface_test_tb;

architecture arc_axi_interface_test_tb of axi_interface_test_tb is

  signal aresetn, aclk : std_logic;
  signal m_axis_tdata  : std_logic_vector(31 downto 0);
  signal m_axis_tvalid	: std_logic;
  signal m_axis_tready : std_logic;
  signal m_axis_tlast  : std_logic;

  constant clock_axi : time :=  2 ns;

begin 

  axi_interface_test : entity work.axi_interface_test port map (	aresetn       => aresetn,
	  								aclk          => aclk,
	  								m_axis_tdata  => m_axis_tdata,
	  								m_axis_tlast  => m_axis_tlast,
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
      wait for 52*clock_axi;
      m_axis_tready <= '1';
      wait;
  end process;
  
end arc_axi_interface_test_tb;
