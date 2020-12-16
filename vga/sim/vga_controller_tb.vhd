library ieee;
use ieee.std_logic_1164.all;

entity vga_controller_tb is 

end entity;

architecture arc_vga_controller_tb of vga_controller_tb is
    signal reset_n, clk, ver_sync, hor_sync : std_logic;
    signal red, green, blue : std_logic_vector(3 downto 0);
    
begin

    U : entity work.vga_controller port map (reset_n => reset_n, clk => clk, ver_sync => ver_sync, hor_sync => hor_sync, red => red, green => green, blue => blue);

    process
    begin
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait for 100 us;
        wait;
    end process;
	
    process
    begin
        clk <= '0';
        wait for 19.86 ns;
        clk <= '1';
        wait for 19.86 ns;
   end process;

end arc_vga_controller_tb;

