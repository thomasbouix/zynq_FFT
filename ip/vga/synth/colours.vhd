library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colours is
	generic(
		DATA_LENGTH	: INTEGER := 4;
		HOR_VA		: INTEGER := 640;
		VER_VA		: INTEGER := 480
	);
	port(
		reset_n	: in  std_logic;
		clk		: in  std_logic;
		
		va_state	: in  std_logic;

		red		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		green		: out std_logic_vector((DATA_LENGTH-1) downto 0);
		blue     	: out std_logic_vector((DATA_LENGTH-1) downto 0)
	);

end entity colours;


architecture arc_colours of colours is

constant n_mire	: integer := HOR_VA / 8;
signal count		: integer range 0 to (HOR_VA - 1);
   
begin
    process(clk, reset_n)
    begin

    if reset_n = '0' then
    	count <= 0;
    
        red   <= x"0"; 
        green <= x"0"; 
        blue  <= x"0"; 

    elsif rising_edge(clk) then
    
	if( va_state = '1' ) then
		count <= count + 1;
		
		-- NOIR
		if( count >= 0*n_mire and count < 1*n_mire ) then 
			red 	<= x"0";
			green 	<= x"0";
			blue 	<= x"0"; 
		-- ROUGE
		elsif( count >= 1*n_mire and count < 2*n_mire )then 
			red 	<= x"F";
			green 	<= x"0";
			blue 	<= x"0"; 
		-- VERT
		elsif( count >= 2*n_mire and count < 3*n_mire )then 
			red 	<= x"0";
			green 	<= x"F";
			blue 	<= x"0"; 
		-- JAUNE
		elsif( count >= 3*n_mire and count < 4*n_mire )then 
			red 	<= x"F";
			green 	<= x"F";
			blue 	<= x"0"; 
		-- BLEU
		elsif( count >= 4*n_mire and count < 5*n_mire )then 
			red 	<= x"0";
			green	<= x"0";
			blue 	<= x"F"; 
		-- ROSE
		elsif( count >= 5*n_mire and count < 6*n_mire )then 
			red 	<= x"F";
			green 	<= x"B";
			blue 	<= x"C"; 
		-- BLEU CIEL
		elsif( count >= 6*n_mire and count < 7*n_mire )then 
			red 	<= x"8";
			green 	<= x"F";
			blue 	<= x"E"; 
		-- BLANC
		elsif( count >= 7*n_mire and count < 8*n_mire )then 
			red 	<= x"F";
			green 	<= x"F";
			blue 	<= x"F"; 

		else end if;
	else
		count <= 0;
	
	    	red   <= x"0"; 
	    	green <= x"0"; 
	    	blue  <= x"0"; 
	end if;
    else end if;
    
    end process;
end architecture;
