library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
	generic(
		-- VGA Signal 640 x 480 @ 60 Hz Industry standard timing

		FREQ_CLK	: INTEGER := 25175000;	-- Frequency
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

		ver_sync	: out std_logic;
		hor_sync	: out std_logic;

		red		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		green		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		blue		: out std_logic_vector((DATA_LENGTH-1) downto 0)
	);
end entity;


architecture arc_vga_controller of vga_controller is

   constant h_period	: integer := HOR_VA + HOR_FP + HOR_SP + HOR_BP;
   constant v_period   : integer := VER_VA + VER_FP + VER_SP + VER_BP;

   signal count_h	: integer range 0 to (h_period - 1);
   signal count_v	: integer range 0 to (v_period - 1);
   signal va_state	: std_logic;

begin

  process(clk, reset_n)
  begin

  	if reset_n = '0'  then
		count_v  <= 0;
		count_h  <= 0;
		va_state <= '0';
		hor_sync <= '1';
		ver_sync <= '1';

 	elsif rising_edge(clk)then

		if(count_h = (h_period - 1)) then
			count_h <= 0;
			if(count_v = (v_period - 1)) then
				count_v <= 0;
			else
				count_v <= count_v + 1;
			end if;
		else
			count_h <= count_h + 1;
		end if;

		if ( (count_h > (HOR_FP + HOR_VA)) and (count_h < (HOR_FP + HOR_VA + HOR_SP)) ) then
			hor_sync <= '0';
		else
			hor_sync <= '1';
		end if;

		if ( (count_v > (VER_FP + VER_VA)) and (count_v < (VER_FP + VER_VA + VER_SP)) ) then
			ver_sync <= '0';
		else
			ver_sync <= '1';
		end if;
		
		if( (count_h > HOR_FP) and (count_h < (HOR_FP + HOR_VA)) and (count_v > VER_FP) and (count_v < (VER_FP + VER_VA)) ) then
			va_state <= '1';
		else
			va_state <= '0';
		end if;
    	end if;
  end process;

  	U0_COLOURS : entity work.colours port map(reset_n => reset_n, clk => clk, va_state => va_state, red => red,green => green, blue => blue);

end architecture;
