library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_vga_controller is
	generic(
		-- AXI Stream
	  DATA_LEN     : INTEGER := 32;
		PKT_LEN      : INTEGER := 640;

		-- VGA Signal 640 x 480 @ 60 Hz Industry standard timing
		FREQ_CLK	   : INTEGER := 25175000;	  -- Frequency
		PIXEL_LEN    : INTEGER := 4;	        -- Data length

		HOR_VA		   : INTEGER := 640;	      -- Horizontal visible area
		HOR_FP		   : INTEGER := 16; 	      -- Horizontal front porch
		HOR_SP		   : INTEGER := 96;	        -- Horizontal sync pulse
		HOR_BP		   : INTEGER := 48;	        -- Horizontal back porch

		VER_VA		   : INTEGER := 480;	      -- Vertical visible area
		VER_FP		   : INTEGER := 10;	        -- Vertical front porch
		VER_SP		   : INTEGER := 2;	        -- Vertical sync pulse
		VER_BP		   : INTEGER := 33	        -- Vertical back porch
	);
	port(
		-- AXI signals
		aresetn	        : in  std_logic;
		aclk		        : in  std_logic;

		s_axis_tdata  	: in   std_logic_vector((DATA_LEN - 1) downto 0);
		s_axis_tkeep 	  : in   std_logic_vector(((DATA_LEN / 8) - 1) downto 0);
		s_axis_tlast 	  : in   std_logic;
		s_axis_tready 	: out  std_logic;
		s_axis_tvalid 	: in   std_logic;

		-- VGA signals
		vga_clk		      : in  std_logic;

		ver_sync	      : out std_logic;
		hor_sync	      : out std_logic;

		red		          : out std_logic_vector((PIXEL_LEN-1) downto 0);
		green		        : out std_logic_vector((PIXEL_LEN-1) downto 0);
		blue		        : out std_logic_vector((PIXEL_LEN-1) downto 0)
	);
end entity axi_vga_controller;


architecture arc_axi_vga_controller of axi_vga_controller is

	constant h_period	   : integer := HOR_VA + HOR_FP + HOR_SP + HOR_BP;
	signal count_h	     : integer range 0 to (h_period - 1);

	constant v_period    : integer := VER_VA + VER_FP + VER_SP + VER_BP;
	signal count_v	     : integer range 0 to (v_period - 1);

	signal va_state	     : std_logic;
	signal va_state_old	 : std_logic;
	signal va_state_cur	 : std_logic;

	signal reg_hor_sync	 : std_logic;
	signal reg_ver_sync	 : std_logic;
	signal ver_sync_old	 : std_logic;
	signal ver_sync_cur	 : std_logic;

	signal counter_pixel : integer range 0 to PKT_LEN;

	type t_axi_state is (WAITFLINE, WAITREADY, WAITVALID, ACQUIRE, TREAT);
	signal axi_state : t_axi_state;

	type t_datas is array ((PKT_LEN-1) downto 0) of std_logic_vector(31 downto 0);
	-- DEBUT FONCTION D'INITIALISATION
	function init_datas return t_datas is
	variable tmp_datas : t_datas;
	begin
	  for i in (PKT_LEN - 1) downto 0 loop
	    tmp_datas(i) := (others => '1');
	  end loop;
	  return tmp_datas;
	end init_datas;
	-- FIN FONCTION D'INITIALISATION

	signal datas : t_datas := init_datas;

	signal counter_data	 : integer range 0 to PKT_LEN;
	signal counter_line  : integer range 0 to VER_VA;
	signal reg_data      : std_logic_vector((DATA_LEN-1) downto 0);

begin

  process(vga_clk, aresetn)
  begin
  	if aresetn = '0'  then
		count_v       <= 0;
		count_h       <= 0;
		counter_pixel <= 0;

		va_state      <= '0';
		va_state_old  <= '0';
    va_state_cur  <= '0';

		reg_hor_sync  <= '1';
		reg_ver_sync  <= '1';

		ver_sync_old  <= '1';
		ver_sync_cur  <= '1';

 		elsif rising_edge(vga_clk)then

			va_state_old <= va_state_cur;
      va_state_cur <= va_state;

			ver_sync_old <= ver_sync_cur;
      ver_sync_cur <= reg_ver_sync;

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
				reg_hor_sync <= '0';
			else
				reg_hor_sync <= '1';
			end if;

			if ( (count_v > (VER_FP + VER_VA)) and (count_v < (VER_FP + VER_VA + VER_SP)) ) then
				reg_ver_sync <= '0';
			else
				reg_ver_sync <= '1';
			end if;

			if( (count_h >= HOR_FP) and (count_h < (HOR_FP + HOR_VA)) and (count_v >= VER_FP) and (count_v < (VER_FP + VER_VA)) ) then
				va_state      <= '1';

				red           <= datas(counter_pixel)(2*PIXEL_LEN + (PIXEL_LEN-1) downto 2*PIXEL_LEN);
				green         <= datas(counter_pixel)(PIXEL_LEN   + (PIXEL_LEN-1) downto PIXEL_LEN);
				blue          <= datas(counter_pixel)(              (PIXEL_LEN-1) downto 0);

				counter_pixel <= counter_pixel + 1;
			else
				va_state      <= '0';

				red           <= (others => '0');
				green         <= (others => '0');
				blue          <= (others => '0');

				counter_pixel <= 0;
			end if;
		end if;
  end process;

	process(aclk, aresetn)
	begin
		if aresetn = '0' then
			counter_data  <= 0;
			s_axis_tready <= '0';

			axi_state     <= WAITFLINE;
		elsif aclk'event and aclk='1' then
			case axi_state is
        when WAITFLINE =>
					counter_data <= 0;
					counter_line <= 0;
					reg_data     <= s_axis_tdata;

					s_axis_tready <= '0';

          if(ver_sync_old = '1' and ver_sync_cur = '0') then
						s_axis_tready <= '1';
						if(s_axis_tvalid = '1') then
							axi_state <= ACQUIRE;
						else
							axi_state <= WAITVALID;
						end if;
					else
						s_axis_tready <= '0';
						axi_state <= WAITFLINE;
					end if;

				when WAITREADY =>
					counter_data <= 0;
					reg_data     <= s_axis_tdata;

					if(va_state_old = '1' and va_state_cur = '0') then
						s_axis_tready <= '1';
						if(s_axis_tvalid = '1') then
							axi_state <= ACQUIRE;
						else
							axi_state <= WAITVALID;
						end if;
					else
						s_axis_tready <= '0';
						axi_state     <= WAITREADY;
					end if;

					if(counter_line = VER_VA) then
						axi_state     <= WAITFLINE;
					else
						axi_state     <= WAITREADY;
					end if;
				when WAITVALID =>
					reg_data <= s_axis_tdata;

					if(s_axis_tvalid = '1') then
						axi_state           <= ACQUIRE;
					else
						axi_state           <= WAITVALID;
					end if;
				when ACQUIRE =>
					if(counter_data = PKT_LEN) then
						reg_data            <= (others => '0');

						counter_data        <= 0;
						counter_line        <= counter_line + 1;

						s_axis_tready       <= '0';
						axi_state           <= WAITREADY;
					else
						reg_data            <= s_axis_tdata;

						datas(counter_data) <= reg_data;
						counter_data        <= counter_data + 1;

						s_axis_tready       <= '1';
						axi_state           <= ACQUIRE;
					end if;
				when others =>
					axi_state <= WAITREADY;
			end case;
		else end if;
	end process;

	ver_sync <= reg_ver_sync;
	hor_sync <= reg_hor_sync;

end architecture arc_axi_vga_controller;
