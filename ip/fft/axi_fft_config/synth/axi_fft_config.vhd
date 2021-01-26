-- AXI I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_fft_config is
  generic(
    CONFIG_SIZE     : integer := 24;
    CONFIG_DATA     : integer := 262153
  );
  port(
    aclk            : in    std_logic;
    aresetn         : in    std_logic;

    -- AXI Interface
    m_axis_tdata  	: out   std_logic_vector((CONFIG_SIZE - 1) downto 0);
    m_axis_tready 	: in    std_logic;
    m_axis_tvalid 	: out   std_logic
  );
end entity axi_fft_config;

architecture arc_axi_fft_config of axi_fft_config is

type t_axi_state is (SEND, AFTER_SEND);
signal axi_state : t_axi_state;

signal data_reg  : std_logic_vector((CONFIG_SIZE - 1) downto 0);

begin

process(aclk, aresetn)
begin
  if aresetn = '0' then
    m_axis_tdata  <= (others => '0');
    m_axis_tvalid <= '0';
    data_reg      <= std_logic_vector(to_unsigned(CONFIG_DATA, data_reg'length));

    axi_state     <= SEND;
	elsif aclk'event and aclk='1' then
		case axi_state is
			when SEND =>
				if(m_axis_tready = '1') then
					m_axis_tvalid <= '1';
					m_axis_tdata  <= data_reg;

					axi_state     <= AFTER_SEND;
        else
    		  m_axis_tvalid <= '0';
    			m_axis_tdata  <= (others => '0');

					axi_state     <= SEND;
				end if;
			when AFTER_SEND =>
				m_axis_tdata  <= (others => '0');
				m_axis_tvalid <= '0';

				axi_state <= SEND;
			when others =>
				axi_state <= SEND;
		end case;
	else end if;
end process;

end arc_axi_fft_config;
