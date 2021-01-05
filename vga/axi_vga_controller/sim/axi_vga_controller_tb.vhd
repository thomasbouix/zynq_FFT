library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_vga_controller_tb is

end entity;

architecture arc_axi_vga_controller_tb of axi_vga_controller_tb is
  signal aresetn, aclk  : std_logic;
  signal s_axis_tdata   : std_logic_vector(31 downto 0);
  signal s_axis_tkeep  	: std_logic_vector(3  downto 0);
  signal s_axis_tvalid	: std_logic;
  signal s_axis_tready  : std_logic;
  signal s_axis_tlast   : std_logic;

  signal vga_clk        : std_logic;
  signal ver_sync       : std_logic;
  signal hor_sync       : std_logic;
  signal red            : std_logic_vector(3 downto 0);
  signal green          : std_logic_vector(3 downto 0);
  signal blue           : std_logic_vector(3 downto 0);

  constant clock_axi    : time :=  0.000002 ns;
  constant clock_vga    : time :=  0.00001986 ns;

  constant pkt_len      : integer := 640;

begin

    axi_vga_controller : entity work.axi_vga_controller port map (
                                                                    aresetn       => aresetn,
                                                                    aclk          => aclk,
                                                                    s_axis_tdata  => s_axis_tdata,
                                                                    s_axis_tkeep  => s_axis_tkeep,
                                                                    s_axis_tlast  => s_axis_tlast,
                                                                    s_axis_tready => s_axis_tready,
                                                                    s_axis_tvalid => s_axis_tvalid,
                                                                    vga_clk       => vga_clk,
                                                                    ver_sync      => ver_sync,
                                                                    hor_sync      => hor_sync,
                                                                    red           => red,
                                                                    green         => green,
                                                                    blue          => blue
                                                                 );


  clock_vga_p : process
  begin
     vga_clk <= '0';
     wait for clock_vga;
     vga_clk <= '1';
     wait for clock_vga;
  end process clock_vga_p;

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

  transaction_p : process
  --variable index : integer := 0;
  begin
      wait for 3000*clock_axi;
      s_axis_tdata  <= x"00000000";
      s_axis_tkeep  <= x"F";
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '1';

      wait until s_axis_tready = '1';

      for index in 1 to (pkt_len - 1) loop
        wait for 2*clock_axi;
        s_axis_tdata  <= std_logic_vector(to_unsigned(index, s_axis_tdata'length));
      end loop;

      wait for 2*clock_axi;
      s_axis_tdata  <= std_logic_vector(to_unsigned((pkt_len - 1), s_axis_tdata'length));
      s_axis_tlast  <= '1';

      wait for 2*clock_axi;
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '0';
      s_axis_tdata  <= x"00000000";

      wait for 40*clock_axi;

      s_axis_tdata  <= x"00000040";
      s_axis_tkeep  <= x"F";
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '1';

      wait until s_axis_tready = '1';

      for index in 1 to (pkt_len - 1) loop
        wait for 2*clock_axi;
        s_axis_tdata  <= std_logic_vector(to_unsigned(40 + index, s_axis_tdata'length));
      end loop;

      wait for 2*clock_axi;
      s_axis_tdata  <= std_logic_vector(to_unsigned(40 + (pkt_len - 1), s_axis_tdata'length));
      s_axis_tlast  <= '1';

      wait for 2*clock_axi;
      s_axis_tlast  <= '0';
      s_axis_tvalid <= '0';
      s_axis_tdata  <= x"00000000";

      wait for 40*clock_axi;
  end process;

end arc_axi_vga_controller_tb;
