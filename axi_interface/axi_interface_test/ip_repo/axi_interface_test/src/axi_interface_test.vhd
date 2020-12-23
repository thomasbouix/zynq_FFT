-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_interface_test is
   generic(
      DATA_LENGTH	: INTEGER := 16
   );
   port(
      aclk             : in    std_logic;
      aresetn          : in    std_logic;
      
      -- Interface AXI
      m_axis_tdata  	: out   std_logic_vector(31 downto 0);
      m_axis_tlast 	: out   std_logic;
      m_axis_tready 	: in    std_logic;
      m_axis_tvalid 	: out   std_logic
   );
end entity axi_interface_test;

architecture arc_axi_interface_test of axi_interface_test is

type t_axi_state is (WAITFOR, SEND, AFTER_SEND);
signal axi_state : t_axi_state;

signal counter		: integer range 0 to DATA_LENGTH;

signal reg_data	: std_logic_vector(31 downto 0);

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
	        if(counter = DATA_LENGTH) then
	        	counter <= 0;
	        else
	        	counter <= counter + 1;
	        end if;
	        
		case axi_state is
			when WAITFOR =>
				if(counter = DATA_LENGTH) then
					axi_state <= SEND;
				else
					axi_state <= WAITFOR;
				end if;
			when SEND =>
				if(m_axis_tready = '1') then
					m_axis_tdata  <= reg_data; 
					m_axis_tvalid <= '1';
					m_axis_tlast  <= '1';
					axi_state     <= AFTER_SEND;
				else
					m_axis_tdata  <= (others => '0');
					m_axis_tvalid <= '0';
					m_axis_tlast  <= '0';
					axi_state     <= WAITFOR;
				end if;	
			when AFTER_SEND =>
				m_axis_tdata  <= (others => '0');
				m_axis_tvalid <= '0';
				m_axis_tlast  <= '0';
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

end arc_axi_interface_test;
