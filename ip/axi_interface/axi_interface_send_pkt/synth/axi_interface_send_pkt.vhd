-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_interface_send_pkt is
  generic(
    DATA_SIZE        : INTEGER := 32;
    LEN_PKT          : INTEGER := 16
  );
  port(
    aclk             : in    std_logic;
    aresetn          : in    std_logic;

    -- AXI Interface
    m_axis_tdata  	: out   std_logic_vector((DATA_SIZE - 1) downto 0);
    m_axis_tkeep 	  : out   std_logic_vector(((DATA_SIZE / 8) - 1) downto 0);
    m_axis_tlast 	  : out   std_logic;
    m_axis_tready 	: in    std_logic;
    m_axis_tvalid 	: out   std_logic
  );
end entity axi_interface_send_pkt;

architecture arc_axi_interface_send_pkt of axi_interface_send_pkt is

type t_axi_state is (WAITFOR, ACQUIRE, SEND, AFTER_SEND);
signal axi_state : t_axi_state;

type t_datas is array ((LEN_PKT-1) downto 0) of std_logic_vector(31 downto 0);

-- DEBUT FONCTION D'INITIALISATION
function init_datas return t_datas is
variable tmp_datas : t_datas;
begin
  for i in (LEN_PKT - 1) downto 0 loop
    tmp_datas(i) := std_logic_vector(to_unsigned(i, tmp_datas(i)'length));
  end loop;
  return tmp_datas;
end init_datas;
-- FIN FONCTION D'INITIALISATION

signal datas : t_datas := init_datas;

constant WAIT_NB_CLOCK : integer := 20;

signal counter_wait	: integer range 0 to WAIT_NB_CLOCK;
signal counter_data	: integer range 0 to LEN_PKT;

begin

process(aclk, aresetn)
begin
  if aresetn = '0' then
    axi_state <= WAITFOR;

    m_axis_tdata  <= (others => '0');
    m_axis_tvalid <= '0';
    m_axis_tlast  <= '0';

	elsif aclk'event and aclk='1' then
	        if(counter_wait = WAIT_NB_CLOCK) then
	        	counter_wait <= 0;
	        else
	        	counter_wait <= counter_wait + 1;
	        end if;

		case axi_state is
		when WAITFOR =>
				if(counter_wait = WAIT_NB_CLOCK) then
					axi_state <= ACQUIRE;
				else
					axi_state <= WAITFOR;
				end if;
			when ACQUIRE =>
				if(counter_data = LEN_PKT) then
					counter_data        <= 0;
					axi_state           <= SEND;
				else
					--datas(counter_data) <= ;
					counter_data        <= counter_data + 1;
					axi_state           <= WAITFOR;
				end if;
			when SEND =>
				if(m_axis_tready = '1') then
					m_axis_tvalid <= '1';
					m_axis_tdata  <= datas(counter_data);

					if(counter_data = (LEN_PKT - 1)) then
						counter_data  <= 0;
						m_axis_tlast  <= '1';

						axi_state     <= AFTER_SEND;
					else
						counter_data  <= counter_data + 1;
						m_axis_tlast  <= '0';

						axi_state     <= SEND;
					end if;
				else
					counter_data  <= counter_data;
					m_axis_tdata  <= (others => '0');
					m_axis_tvalid <= '0';
					m_axis_tlast  <= '0';

					axi_state     <= WAITFOR;
				end if;
			when AFTER_SEND =>
				m_axis_tdata  <= (others => '0');
				m_axis_tvalid <= '0';
				m_axis_tlast  <= '0';

				axi_state <= WAITFOR;
			when others =>
				axi_state <= WAITFOR;
		end case;
	else end if;
end process;

m_axis_tkeep <= (others => '1');

end arc_axi_interface_send_pkt;
