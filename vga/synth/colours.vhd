library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colours is
	generic(
		-- VGA Signal 640 x 480 @ 60 Hz Industry standard timing

		FREQ_CLK	: INTEGER := 25000000;	-- Frequency
		DATA_LENGTH	: INTEGER := 4;	-- Data length

		HOR_VA		: INTEGER := 640;	-- Horizontal visible area
		HOR_FP		: INTEGER := 16; 	-- Horizontal front porch
		HOR_SP		: INTEGER := 96;	-- Horizontal sync pulse
		HOR_BP		: INTEGER := 48;	-- Horizontal back porch

		VER_VA		: INTEGER := 480;	-- Vertical visible area
		VER_FP		: INTEGER := 10;	-- Vertical front porch
		VER_SP		: INTEGER := 2;	-- Vertical sync pulse
		VER_BP		: INTEGER := 33	-- Vertical back porch
	);
	port(
		reset_n	: in  std_logic;
		clk		: in  std_logic;

		count_v	: in integer range 0 to 1023;
		count_h   	: in integer range 0 to 1023;

		red		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		green		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		blue     	: out std_logic_vector((DATA_LENGTH-1) downto 0)
	);

end entity colours;


architecture arc_colours of colours is

constant n_mire : integer := HOR_VA/8;

begin
    process(clk,reset_n)
    begin

    if reset_n = '1' then
        red   <= (others=>'0');
        green <= (others=>'0');
        blue  <= (others=>'0');

    elsif rising_edge(clk)then

	if( (count_h < HOR_VA) and (count_v < VER_VA) ) then
	    red   <= (others=>'1');
	    green <= (others=>'1');
	    blue  <= (others=>'1');
	else
	    red   <= (others=>'0');
	    green <= (others=>'0');
	    blue  <= (others=>'0');
	end if;

    end if;
    end process;
end architecture;
