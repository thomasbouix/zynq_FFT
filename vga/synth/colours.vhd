library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colours is
	generic(
		DATA_LENGTH	: integer := 4
	);
	port(
		reset_n		: in  std_logic;
		clk		: in  std_logic;
		
		count_v		: in integer range 0 to 1023;        
		count_h   	: in integer range 0 to 1023;
		
		red		: out std_logic_vector((DATA_LENGTH-1) downto 0); 
		green		: out std_logic_vector((DATA_LENGTH-1) downto 0); 
		blue     	: out std_logic_vector((DATA_LENGTH-1) downto 0)
	);        
		
end entity colours;


architecture arc_colours of colours is
begin
	process(clk,reset_n)
	begin  
    
		if reset_n = '1' then
		  red 	<= x"0";
		  green <= x"0";
		  blue 	<= x"0"; 
		elsif rising_edge(clk)then
			
			if( ((count_v >= 0 and count_v < 8) and (count_v > 791 and count_v <= 799 )) or ((count_h >= 0 and count_h < 2) and (count_h > 516 and count_h <= 524 )) ) then
				red 	<= x"0";
				green 	<= x"0";
				blue	<= x"0"; 
			elsif( (count_h >= 104 and count_h < 152)  and (not(count_v >= 2 and count_v < 4   )) ) then 
				red 	<= x"0";
				green 	<= x"0";
				blue 	<= x"0"; 
			elsif( (count_v >= 4   and count_v < 37 )  and (not(count_h >= 8 and count_h < 104 )) ) then 
				red 	<= x"0";
				green 	<= x"0";
				blue 	<= x"0"; 
			elsif( (count_v >= 37  and count_v < 517)  and (count_h >= 152 and count_h < 791) ) then 
			
				-- NOIR
				if( (count_v >= 152 and count_v < 232) ) then 
					red 	<= x"0";
					green 	<= x"0";
					blue 	<= x"0"; 
				-- ROUGE
				elsif( (count_v >= 232 and count_v < 312) )then 
					red 	<= x"F";
					green 	<= x"0";
					blue 	<= x"0"; 
				-- VERT
				elsif( (count_v >= 312 and count_v < 392) ) then 
					red 	<= x"0";
					green 	<= x"F";
					blue 	<= x"0"; 
				-- JAUNE
				elsif( (count_v >= 392 and count_v < 472) )then 
					red 	<= x"F";
					green 	<= x"F";
					blue 	<= x"0"; 
				-- BLEU
				elsif( (count_v >= 472 and count_v < 552) ) then 
					red 	<= x"0";
					green	<= x"0";
					blue 	<= x"F"; 
				-- ROSE
				elsif( (count_v >= 552 and count_v < 632) )then 
					red 	<= x"F";
					green 	<= x"B";
					blue 	<= x"C"; 
				-- BLEU CLAIR
				elsif( (count_v >= 632 and count_v < 712) )then 
					red 	<= x"0";
					green 	<= x"0";
					blue 	<= x"0"; 
				-- BLANC
				elsif( (count_v >= 712 and count_v < 792) )then 
					red 	<= x"8";
					green 	<= x"F";
					blue 	<= x"E"; 
				
				end if;
				
			end if;
				
		end if;
	end process;
end architecture;
