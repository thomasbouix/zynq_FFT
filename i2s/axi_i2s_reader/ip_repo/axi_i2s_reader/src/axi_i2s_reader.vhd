-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_reader is
   generic(
      DATA_LENGTH	: INTEGER := 16
   );
   port(
      aclk             : in    std_logic;
      aresetn          : in    std_logic;
      
      -- Interface AXI
      m_axis_tdata  	: out   std_logic_vector(31 downto 0);
      m_axis_tvalid 	: out   std_logic;
      m_axis_tready 	: in    std_logic;

      -- Interface I2S
      mclk             : inout std_logic;
      sclk             : out 	std_logic;
      lrck             : out 	std_logic;
      din              : in 	std_logic
   );
end entity axi_i2s_reader;

architecture arc_axi_i2s_reader of axi_i2s_reader is

type t_i2s_state is (WAITFOR, BEFORE_AC, ACQUIRE, AFTER_AC);
signal i2s_state : t_i2s_state;

type t_axi_state is (WAITFOR, SEND, AFTER_SEND);
signal axi_state : t_axi_state;

signal counter		: integer range 0 to DATA_LENGTH;
signal counter_clk	: unsigned (7 downto 0);

signal sclk_old	: std_logic;
signal sclk_cur	: std_logic;
signal lrck_old   	: std_logic;
signal lrck_cur   	: std_logic;

signal reg_data	: std_logic_vector((DATA_LENGTH - 1) downto 0);

begin

 -- Process synchrone --
process (mclk, aresetn)
begin
  	if aresetn = '0' then
    		i2s_state <= WAITFOR;

      		counter_clk <= (others => '0');
		counter     <= 0;

		reg_data    <= (others => '0');
	
    		sclk_old    <= '0';
    		sclk_cur    <= '0';
    		lrck_old    <= '0';
    		lrck_cur    <= '0';

  	elsif mclk'event and mclk='1' then
    		counter_clk <= counter_clk + 1;

    		sclk_old    <= sclk_cur;
      		sclk_cur    <= not(counter_clk(1));
      		lrck_old   <= lrck_cur;
      		lrck_cur   <= counter_clk(7);

	    	case i2s_state is
			when WAITFOR =>
				--reg_data <= (others => '0');
				--counter  <= 0;
				if(lrck_old = '1' and lrck_cur = '0') then
					i2s_state <= BEFORE_AC;
				else
					i2s_state <= WAITFOR;
				end if;
			when BEFORE_AC =>
				reg_data <= (others => '0');
				counter  <= 0;
				if(sclk_old = '0' and sclk_cur = '1') then
					i2s_state <= ACQUIRE;
				else
					i2s_state <= BEFORE_AC;
				end if;
			when ACQUIRE =>
				if(sclk_old = '0' and sclk_cur = '1') then
					reg_data <= reg_data(reg_data'length-2 downto 0) & din;
					counter  <= counter + 1;
				else end if;
				if( counter = DATA_LENGTH)  then
					counter <= 0;
					i2s_state <= AFTER_AC;
				else
					i2s_state <= ACQUIRE;
				end if;
			when AFTER_AC =>
				if(sclk_old = '0' and sclk_cur = '1') then
					i2s_state <= WAITFOR;
				else
					i2s_state <= AFTER_AC;
				end if;
			when others =>
				i2s_state <= WAITFOR;
	 	end case;
  	else end if;
end process;

process(aclk, aresetn)
begin
	if aresetn = '0' then
		axi_state <= WAITFOR;
		
		m_axis_tdata  <= (others => '0');
		m_axis_tvalid <= '0';
		
	elsif aclk'event and aclk='1' then
		case axi_state is
			when WAITFOR =>
				if(counter = DATA_LENGTH) then
					axi_state <= SEND;
				else
					axi_state <= WAITFOR;
				end if;
			when SEND =>
				if(m_axis_tready = '1') then
					m_axis_tdata  <= x"0000" & reg_data; 
					m_axis_tvalid <= '1';
					axi_state     <= AFTER_SEND;
				else
					m_axis_tdata  <= (others => '0');
					m_axis_tvalid <= '0';
					axi_state     <= SEND;
				end if;	
			when AFTER_SEND =>
				m_axis_tvalid <= '0';
				if(counter = 0) then
					axi_state <= WAITFOR;
				else
					axi_state <= AFTER_SEND;
				end if;
			when others =>
				axi_state <= WAITFOR;
		end case;
	else end if;
end process;

sclk   <= sclk_old;
lrck   <= lrck_old;

end arc_axi_i2s_reader;
