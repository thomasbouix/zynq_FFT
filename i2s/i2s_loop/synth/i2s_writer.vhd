-- I2S Reader en mode esclave + receiver
-- Lit la sortie de l'ADC et la formatte sur DATA_LENGTH bits

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_writer is 
	generic(
		DATA_LENGTH	: INTEGER := 16	-- taille des données
	);
	port(
		reset_n	: in	std_logic;
		clk		: in	std_logic;
		data		: in	std_logic_vector((DATA_LENGTH-1) downto 0);
		
		mclk		: out	std_logic;	-- clock du systeme
		sclk		: out 	std_logic;	-- frequence din
		lrclk		: out 	std_logic;	-- left / right
		dout		: out 	std_logic	-- sortie de l'ADC
	);
end entity i2s_writer;

architecture arc_i2s_writer of i2s_writer is 

type Etat is (Etat0, Etat1, Etat2);
signal EtatPresent : Etat;
signal EtatFutur   : Etat;

signal counter		: integer range 0 to DATA_LENGTH; 
signal counter_clk	: unsigned (7 downto 0);

signal sclk_old	: std_logic;
signal sclk_cur	: std_logic;
signal lrclk_old   	: std_logic;
signal lrclk_cur   	: std_logic;

signal reg_data	: std_logic_vector((DATA_LENGTH - 1) downto 0);

begin 

 -- Process synchrone -- 
process (clk, reset_n)
begin
  	if reset_n = '0' then 
    		EtatPresent <= Etat0;
    
      		counter_clk <= (others => '0');
  
    		sclk_old    <= '0';
    		sclk_cur    <= '0';
    		lrclk_old   <= '0';
    		lrclk_cur   <= '0';
    		
  	elsif clk'event and clk='1' then 
    		EtatPresent <= EtatFutur;
    		
    		counter_clk <= counter_clk + 1;
    		
    		sclk_old    <= sclk_cur;
      		sclk_cur    <= not(counter_clk(1));
      		lrclk_old   <= lrclk_cur;
      		lrclk_cur   <= counter_clk(7);
    		
  	end if; 
end process; 


process (EtatPresent, sclk_old, sclk_cur, lrclk_old, lrclk_cur, data)
begin
	case EtatPresent is 
		when Etat0 =>
			reg_data <= data;
			counter  <= 0;
			dout     <= '0';
			
			if(lrclk_old = '1' and lrclk_cur = '0') then
				EtatFutur <= Etat1;
			else
				EtatFutur <= Etat0;
			end if;
		
		when Etat1 =>
			if(sclk_old = '0' and sclk_cur = '1') then
				dout     <= reg_data(reg_data'length - 1);
				reg_data <= reg_data(reg_data'length-2 downto 0) & '0';
				counter  <= counter + 1;
				
				if( counter = (DATA_LENGTH - 1) )  then
					counter <= 0;
					EtatFutur <= Etat2;
				else
					EtatFutur <= Etat1;
				end if;
			else end if;
		
		when Etat2 =>
			if(sclk_old = '0' and sclk_cur = '1') then
				dout    <= '0';
				EtatFutur <= Etat0;
			else
				EtatFutur <= Etat2;
			end if;
 	end case;
end process;

mclk   <= clk;
sclk   <= sclk_cur;
lrclk  <= lrclk_cur;

end arc_i2s_writer;
