-- I2S Writer en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_writer is
	generic(
		DATA_LENGTH	: INTEGER := 32	-- taille des données
	);
	port(
		reset_n	: in	std_logic;
		clk		: in	std_logic;

		data		: in	std_logic_vector((DATA_LENGTH-1) downto 0);

		mclk		: out	std_logic;	-- clock du systeme
		sclk		: out std_logic;	-- frequence din
		lrclk		: out std_logic;	-- left / right
		dout		: out std_logic	-- sortie de l'ADC
	);
end entity i2s_writer;

architecture arc_i2s_writer of i2s_writer is

type t_etat is (etat0, etat1, etat2);
signal etat : t_etat;

signal counter		 : integer range 0 to DATA_LENGTH;
signal counter_clk : unsigned (7 downto 0);

signal sclk_old	: std_logic;
signal sclk_cur	: std_logic;
signal lrclk_old   	: std_logic;
signal lrclk_cur   	: std_logic;

signal reg_dout	: std_logic;
signal reg_data	: std_logic_vector((DATA_LENGTH - 1) downto 0);

begin


process (clk, reset_n)
begin
  	if reset_n = '0' then
    		etat <= etat0;

      		counter_clk <= (others => '0');
      		counter     <= 0;

      		reg_data    <= (others => '0');
      		reg_dout    <= '0';

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
				reg_data <= data;
				reg_dout <= '0';

				counter  <= 0;

				if(lrclk_old = '1' and lrclk_cur = '0') then
					etat <= etat1;
				else
					etat <= etat0;
				end if;

			when etat1 =>
				if(sclk_old = '0' and sclk_cur = '1') then
					reg_dout <= reg_data(reg_data'length - 1);
					reg_data <= reg_data(reg_data'length-2 downto 0) & '0';

					if( counter = (DATA_LENGTH - 1) )  then
						counter <= 0;
						etat <= etat2;
					else
						counter  <= counter + 1;
						etat <= etat1;
					end if;
				else
					reg_dout  <= reg_dout;
					reg_data  <= reg_data;
					counter   <= counter;
					etat <= etat1;
				end if;

			when etat2 =>
				counter  <= 0;
				reg_data <= reg_data;
				if(sclk_old = '0' and sclk_cur = '1') then
					reg_dout  <= '0';
					etat <= etat0;
				else
					reg_dout  <= reg_dout;
					etat <= etat2;
				end if;
			when others =>
				etat <= etat0;
	 	end case;

 	end if;
end process;

mclk   <= clk;
sclk   <= sclk_old;
lrclk  <= lrclk_old;

dout   <= reg_dout;

end arc_i2s_writer;
