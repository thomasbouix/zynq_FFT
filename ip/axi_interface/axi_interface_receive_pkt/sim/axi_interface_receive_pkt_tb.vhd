library ieee;
use ieee.std_logic_1164.all;

entity axi_interface_receive_pkt_tb is
end axi_interface_receive_pkt_tb;

architecture arc_axi_interface_receive_pkt_tb of axi_interface_receive_pkt_tb is

  signal aresetn, aclk : std_logic;
  signal s_axis_tdata  : std_logic_vector(31 downto 0);
  signal s_axis_tvalid	: std_logic;
  signal s_axis_tready : std_logic;
  signal s_axis_tlast  : std_logic;
  signal s_axis_tkeep  : std_logic_vector(3 downto 0);
  signal data_out      : std_logic_vector(7 downto 0);

  constant clock_axi : time :=  2 ns;

begin

  axi_interface_receive_pkt : entity work.axi_interface_receive_pkt port map (	aresetn       => aresetn,
	  										aclk          => aclk,
	  										s_axis_tdata  => s_axis_tdata,
	  										s_axis_tkeep  => s_axis_tkeep,
	  										s_axis_tlast  => s_axis_tlast,
	  										s_axis_tready => s_axis_tready,
	  										s_axis_tvalid => s_axis_tvalid,
	  										data_out      => data_out
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

  transaction_p : process begin
      wait for 40*clock_axi;
      s_axis_tdata  <= x"00000001";
      s_axis_tkeep  <= x"F";
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '1';

      wait until s_axis_tready = '1';

      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000002";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000003";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000004";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000005";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000006";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000007";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000008";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"00000009";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000A";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000B";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000C";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000D";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000E";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000000F";
      wait for 2*clock_axi;
      s_axis_tdata  <= x"0000001F";
      s_axis_tlast  <= '1';
      wait for 2*clock_axi;
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '0';
      s_axis_tdata  <= x"00000000";

      wait for 40*clock_axi;
  end process;

end arc_axi_interface_receive_pkt_tb;
