-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_interface_send_pkt is
   generic(
      MAX_PKT_LEN      : INTEGER := 32
   );
   port(
      aclk             : in    std_logic;
      aresetn          : in    std_logic;
      
      -- AXI Interface
      m_axis_tdata  	: out   std_logic_vector(31 downto 0);
      m_axis_tlast 	: out   std_logic;
      m_axis_tvalid 	: out   std_logic;
      m_axis_tready 	: in    std_logic
   );
end entity axi_interface_send_pkt;

architecture arc_axi_interface_send_pkt of axi_interface_send_pkt is

type t_axi_state is (WAITFOR, ACQUIRE, SEND, AFTER_SEND);
signal axi_state : t_axi_state;

type t_datas is array ((MAX_PKT_LEN-1) downto 0) of std_logic_vector(31 downto 0);
signal datas : t_datas;

signal reg_data	: std_logic_vector(31 downto 0);

constant WAIT_NB_CLOCK : integer := 20;

signal counter_wait	: integer range 0 to WAIT_NB_CLOCK;
signal counter_data	: integer range 0 to MAX_PKT_LEN;

begin

process(aclk, aresetn)
begin
	if aresetn = '0' then
		axi_state <= WAITFOR;
		
		m_axis_tdata  <= (others => '0');
		m_axis_tvalid <= '0';
		m_axis_tlast  <= '0';
		
		reg_data <= x"00000009";
		
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
				if(counter_data = MAX_PKT_LEN) then
					counter_data <= 0;
					axi_state     <= SEND;
				else
					datas(counter_data) <= reg_data;
					counter_data  <= counter_data + 1;
					axi_state     <= WAITFOR;
				end if;
			when SEND =>
				if(m_axis_tready = '1') then
					m_axis_tdata  <= datas(counter_data); 
					m_axis_tvalid <= '1';
					
					if(counter_data = (MAX_PKT_LEN - 1)) then
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
					
					axi_state     <= SEND;
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

end arc_axi_interface_send_pkt;
