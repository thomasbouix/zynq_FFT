library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
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
   --signal reg_hor_sync : std_logic;
   --signal reg_ver_sync : std_logic;

begin

  process(clk,reset_n)
  begin

    if reset_n = '1'  then
		count_v <= 0;
		count_h <= 0;
		--reg_hor_sync <= '1';
		--reg_ver_sync <= '1';
		hor_sync <= '0';
		ver_sync <= '0';

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

		if (count_h <= (HOR_VA + HOR_FP + HOR_SP)) and (count_h >= (HOR_VA + HOR_FP)) then
			--reg_hor_sync <= '1';
			hor_sync <= '1';
		else
			--reg_hor_sync <= '0';
			hor_sync <= '0';
		end if;

		if (count_v <= (VER_VA + VER_FP + VER_SP)) and (count_v >= (VER_VA + VER_FP)) then
			--reg_ver_sync <= '1';
			ver_sync <= '1';
		else
			--reg_ver_sync <= '0';
			ver_sync <= '0';
		end if;
    end if;
  end process;

  	U0_COLOURS : entity work.colours  port map(reset_n => reset_n,clk => clk,count_v => count_v,count_h => count_h,red => red,green => green, blue => blue);
	--ver_sync <= reg_ver_sync;
	--hor_sync <= reg_hor_sync;

end architecture;
