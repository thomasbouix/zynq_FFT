-- I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_reader is
	generic(
		DATA_LENGTH	: INTEGER := 25	-- taille des données
	);
	port(
		reset_n	: in	std_logic;
		clk	  	: in	std_logic;

		data		: out	std_logic_vector((DATA_LENGTH-1) downto 0);

		mclk		: out	std_logic;	  -- clock du systeme
		sclk		: out std_logic;	-- frequence din
		lrclk		: out std_logic;	-- left / right
		din	  	: in 	std_logic	    -- sortie de l'ADC
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is

type t_etat is (etat0, etat1, etat2, etat3);
signal etat : t_etat;

signal counter		  : integer range 0 to DATA_LENGTH;
signal counter_clk	: unsigned (7 downto 0);

signal sclk_old	    : std_logic;
signal sclk_cur	    : std_logic;
signal lrclk_old   	: std_logic;
signal lrclk_cur   	: std_logic;

signal reg_data	: std_logic_vector((DATA_LENGTH - 1) downto 0);

begin

 -- Process synchrone --
process (clk, reset_n)
begin
  	if reset_n = '0' then
    	etat <= etat0;

			counter_clk <= (others => '0');
			counter     <= 0;

			reg_data    <= (others => '0');
			data        <= (others => '0');

    	sclk_old    <= '0';
    	sclk_cur    <= '0';
    	lrclk_old   <= '0';
    	lrclk_cur   <= '0';

  	elsif clk'event and clk='1' then
    		counter_clk <= counter_clk + 1;

    		sclk_old    <= sclk_cur;
      	sclk_cur    <= not(counter_clk(1));
      	lrclk_old   <= lrclk_cur;
      	lrclk_cur   <= counter_clk(7);

	    	case etat is
					when etat0 =>
						reg_data <= (others => '0');
						counter  <= 0;
						if(lrclk_old = '1' and lrclk_cur = '0') then
							etat <= etat1;
						else
							etat <= etat0;
						end if;
					when etat1 =>
						if(sclk_old = '0' and sclk_cur = '1') then
							etat <= etat2;
						else
							etat <= etat1;
						end if;
					when etat2 =>
						if(sclk_old = '0' and sclk_cur = '1') then
							reg_data <= reg_data(reg_data'length-2 downto 0) & din;
							if( counter = DATA_LENGTH)  then
								counter <= 0;
								etat    <= etat3;
							else
								counter <= counter + 1;
								etat    <= etat2;
							end if;
						else
							etat <= etat2;
						end if;

					when etat3 =>
						data <= reg_data;
						if(sclk_old = '0' and sclk_cur = '1') then
							etat <= etat0;
						else
							etat <= etat3;
						end if;
		 	end case;
  	end if;
end process;

mclk   <= clk;
sclk   <= sclk_old;
lrclk  <= lrclk_old;

end arc_i2s_reader;
