-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_interface_receive_pkt is
   generic(
      DATA_SIZE        : INTEGER := 32;
      LEN_PKT          : INTEGER := 16
   );
   port(
      aclk             : in    std_logic;
      aresetn          : in    std_logic;

      -- AXI Interface
      s_axis_tdata  	: in   std_logic_vector((DATA_SIZE - 1) downto 0);
      s_axis_tkeep 	: in   std_logic_vector(((DATA_SIZE / 8) - 1) downto 0);
      s_axis_tlast 	: in   std_logic;
      s_axis_tready 	: out  std_logic;
      s_axis_tvalid 	: in   std_logic;
      
      -- Output
      data_out         : out  std_logic_vector(7 downto 0)
   );
end entity axi_interface_receive_pkt;

architecture arc_axi_interface_receive_pkt of axi_interface_receive_pkt is

type t_axi_state is (WAITREADY, WAITVALID, ACQUIRE, TREAT);
signal axi_state : t_axi_state;

type t_datas is array ((LEN_PKT-1) downto 0) of std_logic_vector(31 downto 0);
signal datas : t_datas;

signal reg_data        : std_logic_vector((DATA_SIZE - 1) downto 0);

constant WAIT_NB_CLOCK : integer := 20;

signal counter_wait	: integer range 0 to WAIT_NB_CLOCK;
signal counter_data	: integer range 0 to LEN_PKT;

begin

process(aclk, aresetn)
begin
	if aresetn = '0' then
		axi_state <= WAITREADY;
		
		s_axis_tready <= '0';
		
	elsif aclk'event and aclk='1' then
	        if(counter_wait = WAIT_NB_CLOCK) then
	        	counter_wait <= 0;
	        else
	        	counter_wait <= counter_wait + 1;
	        end if;
	        
		case axi_state is
			when WAITREADY =>
				counter_data <= 0;
				reg_data     <= s_axis_tdata;
				
				if(counter_wait = WAIT_NB_CLOCK) then
					s_axis_tready <= '1';
					
					if(s_axis_tvalid = '1') then
						axi_state <= ACQUIRE;
					else
						axi_state <= WAITVALID;
					end if;
				else
					s_axis_tready <= '0';
					axi_state     <= WAITREADY;
				end if;
			when WAITVALID =>
				reg_data <= s_axis_tdata;
				
				if(s_axis_tvalid = '1') then
					axi_state           <= ACQUIRE;
				else
					axi_state           <= WAITVALID;
				end if;
			when ACQUIRE =>
				if(counter_data = LEN_PKT) then
					s_axis_tready       <= '0';
					reg_data            <= (others => '0');
					
					counter_data        <= 0;
					axi_state           <= WAITREADY;
				else
					s_axis_tready       <= '1';
					reg_data            <= s_axis_tdata; 
					datas(counter_data) <= reg_data;
					counter_data        <= counter_data + 1;
					axi_state           <= ACQUIRE;
				end if;
			when others =>
				axi_state <= WAITREADY;
		end case;
	else end if;
end process;

data_out <= datas(LEN_PKT - 1)(7 downto 0);

end arc_axi_interface_receive_pkt;
