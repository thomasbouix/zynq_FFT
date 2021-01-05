-- I2S Reader en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_reader is
   generic(
      DATA_LEN      : INTEGER := 32;
      LEN_PKT       : INTEGER := 16;
			SAMPLE_LEN    : INTEGER := 16
   );
	port(
		aresetn        	: in  std_logic;
		aclk		        : in  std_logic;
		i2s_clk         : in  std_logic;

		-- AXI Interface
    m_axis_tdata  	: out std_logic_vector((DATA_LEN - 1) downto 0);
    m_axis_tkeep 	  : out std_logic_vector(((DATA_LEN / 8) - 1) downto 0);
    m_axis_tlast 	  : out std_logic;
    m_axis_tready 	: in  std_logic;
    m_axis_tvalid 	: out std_logic;

		-- I2S Interface
		mclk		        : out	std_logic;	  -- systeme clock
		sclk		        : out std_logic;	  -- din frequency
		lrclk		        : out std_logic;	  -- left / right
		din		          : in 	std_logic	    -- ADC output
	);
end entity axi_i2s_reader;

architecture arc_axi_i2s_reader of axi_i2s_reader is

-- Signals for I2S Interface
type t_i2s_state is (WAITFOR, WAITDATA, ACQUIRE, TRANSFERT, DONE);
signal i2s_state : t_i2s_state;

signal counter_bit  : integer range 0 to SAMPLE_LEN;
signal counter_clk	: unsigned (7 downto 0);

signal sclk_old	    : std_logic;
signal sclk_cur	    : std_logic;
signal lrclk_old   	: std_logic;
signal lrclk_cur   	: std_logic;

signal reg_data	    : std_logic_vector((SAMPLE_LEN - 1) downto 0);
signal data_ready   : std_logic;

-- Signals for AXI Interface
type t_axi_state is (WAITDATA, WAITFOR, ACQUIRE, SEND, AFTER_SEND);
signal axi_state : t_axi_state;

type t_datas is array ((LEN_PKT-1) downto 0) of std_logic_vector((DATA_LEN- 1) downto 0);
-- DEBUT FONCTION D'INITIALISATION
function init_datas return t_datas is
variable tmp_datas : t_datas;
begin
  for i in (LEN_PKT - 1) downto 0 loop
    tmp_datas(i) := (others => '0');
  end loop;
  return tmp_datas;
end init_datas;
-- FIN FONCTION D'INITIALISATION

signal datas : t_datas := init_datas;
signal counter_data	: integer range 0 to LEN_PKT;

signal transfert_done : std_logic;
begin

-- Process I2S Interface
process (i2s_clk, aresetn)
begin
  	if aresetn = '0' then
    		i2s_state   <= WAITFOR;

      	counter_clk <= (others => '0');
				counter_bit <= 0;

				reg_data    <= (others => '0');
				data_ready  <= '0';

    		sclk_old    <= '0';
    		sclk_cur    <= '0';
    		lrclk_old   <= '0';
    		lrclk_cur   <= '0';

  	elsif i2s_clk'event and i2s_clk='1' then
    		counter_clk        <= counter_clk + 1;

    		sclk_old           <= sclk_cur;
				sclk_cur           <= not(counter_clk(1));
      	lrclk_old          <= lrclk_cur;
      	lrclk_cur          <= counter_clk(7);

	    	case i2s_state is
					when WAITFOR =>
						reg_data       <= (others => '0');
						counter_bit    <= 0;
						if(lrclk_old = '1' and lrclk_cur = '0') then
							i2s_state    <= WAITDATA;
						else
							i2s_state    <= WAITFOR;
						end if;
					when WAITDATA =>
						if(sclk_old = '0' and sclk_cur = '1') then
							i2s_state    <= ACQUIRE;
						else
							i2s_state    <= WAITDATA;
						end if;
					when ACQUIRE =>
						if(sclk_old = '0' and sclk_cur = '1') then
							reg_data     <= reg_data(reg_data'length-2 downto 0) & din;
							counter_bit  <= counter_bit + 1;
						else end if;
						if(counter_bit = SAMPLE_LEN)  then
							counter_bit  <= 0;
							i2s_state    <= TRANSFERT;
						else
							i2s_state    <= ACQUIRE;
						end if;
					when TRANSFERT =>
						data_ready     <= '1';
						if(sclk_old = '0' and sclk_cur = '1') then
							i2s_state    <= DONE;
						else
							i2s_state    <= TRANSFERT;
						end if;
					when DONE =>
						if(transfert_done = '1') then
							data_ready   <= '0';
							i2s_state    <= WAITFOR;
						else
							data_ready   <= data_ready;
							i2s_state    <= DONE;
						end if;
					when others =>
						i2s_state    <= WAITFOR;
			 	end case;
  	end if;
end process;

-- Process AXI Interface
process(aclk, aresetn)
begin
  if aresetn = '0' then
    axi_state <= WAITFOR;

		transfert_done <= '0';

    m_axis_tdata  <= (others => '0');
    m_axis_tvalid <= '0';
    m_axis_tlast  <= '0';

	elsif aclk'event and aclk='1' then
		case axi_state is
			when WAITDATA =>
				if(data_ready = '0') then
					axi_state      <= WAITFOR;
				else
					axi_state      <= WAITDATA;
				end if;
			when WAITFOR =>
					if(data_ready = '1') then
						transfert_done <= '0';
						axi_state      <= ACQUIRE;
					else
						transfert_done <= transfert_done;
						axi_state      <= WAITFOR;
					end if;

				when ACQUIRE =>
					transfert_done <= '1';
					if(counter_data = LEN_PKT) then
						counter_data        <= 0;
						axi_state           <= SEND;
					else
						datas(counter_data)((SAMPLE_LEN - 1) downto 0) <= reg_data;
						counter_data        <= counter_data + 1;
						axi_state           <= WAITDATA;
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

mclk   <= i2s_clk;
sclk   <= sclk_old;
lrclk  <= lrclk_old;

end arc_axi_i2s_reader;
