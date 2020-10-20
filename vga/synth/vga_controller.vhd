library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is 
	generic(
		FREQ_CLK	:	INTEGER := 50000000;
		DATA_LENGTH	:	INTEGER := 4
	);
	port(
		reset_n		: in  std_logic;
		clk		: in  std_logic;   
		
		ver_sync	: out std_logic;
		hor_sync	: out std_logic;
	
		red		: out std_logic_vector((DATA_LENGTH-1) downto 0);  
		green		: out std_logic_vector((DATA_LENGTH-1) downto 0); 
		blue		: out std_logic_vector((DATA_LENGTH-1) downto 0)
	);
end entity vga_controller;


architecture arc_vga_controller of vga_controller is
   signal count_v, count_h 	: integer range 0 to 1023;
   signal reg_hor_sync, reg_ver_sync : std_logic;

begin

  process(clk,reset_n)
  begin  
    
    if reset_n = '0'  then
      count_v <= 0;
      count_h <= 0;
      reg_hor_sync <= '1';
      reg_ver_sync <= '1';
            
 	elsif rising_edge(clk)then
     
		if(count_h = 799 ) then 
			count_h <= 0;
			count_v <= count_v + 1;
			if(count_v = 524) then
				count_v <= 0;
			end if;
		else 
			count_h <= count_h + 1;
		end if;
		
		if( count_h < 8 )then
			reg_hor_sync <= '1';
		elsif ( (count_h >= 8  ) and (count_h < 104) ) then
			reg_hor_sync <= '0';
		elsif ( (count_h >= 104) and (count_h < 800) ) then
			reg_hor_sync <= '1';
		end if;
		
		if( count_v < 2 )then
			reg_ver_sync <= '1';
		elsif ( (count_v >= 2  ) and (count_v < 4  ) ) then
			reg_ver_sync <= '0';
		elsif ( (count_v >= 4  ) and (count_v < 525) ) then
			reg_ver_sync <= '1';
		end if;
      
    end if;
  end process;
  
  	U0_COLOURS : entity work.colours  port map(reset_n => reset_n,clk => clk,count_v => count_v,count_h => count_h,red => red,green => green, blue => blue);
	ver_sync <= reg_ver_sync;
	hor_sync <= reg_hor_sync;
	 
end architecture arc_vga_controller;
