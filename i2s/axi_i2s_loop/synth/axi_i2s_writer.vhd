-- I2S Writer en mode esclave + receiver

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_i2s_writer is
	generic(
		DATA_LEN         : INTEGER := 32;
		LEN_PKT          : INTEGER := 16;
		SAMPLE_LEN       : INTEGER := 16
	);
	port(
		aresetn	         : in	std_logic;
		aclk		         : in	std_logic;
		i2s_clk          : in  std_logic;

		-- AXI Interface
		s_axis_tdata  	 : in   std_logic_vector((DATA_LEN - 1) downto 0);
		s_axis_tkeep 	   : in   std_logic_vector(((DATA_LEN / 8) - 1) downto 0);
		s_axis_tlast 	   : in   std_logic;
		s_axis_tready 	 : out  std_logic;
		s_axis_tvalid 	 : in   std_logic;

		-- I2S Interface
		mclk		         : out	std_logic;	-- clock du systeme
		sclk		         : out 	std_logic;	-- frequence din
		lrclk		         : out 	std_logic;	-- left / right
		dout		         : out 	std_logic 	-- sortie de l'ADC
	);
end entity axi_i2s_writer;

architecture arc_axi_i2s_writer of axi_i2s_writer is

-- Signals for I2S Interface
type t_i2s_state is (WAITDATA, WAITFOR, TRANSFERT, DONE);
signal i2s_state : t_i2s_state;

signal counter_bit	  : integer range 0 to SAMPLE_LEN;
signal counter_sample : integer range 0 to LEN_PKT;
signal counter_clk	  : unsigned (7 downto 0);

signal sclk_old	      : std_logic;
signal sclk_cur	      : std_logic;
signal lrclk_old   	  : std_logic;
signal lrclk_cur   	  : std_logic;

signal reg_sample	    : std_logic_vector((SAMPLE_LEN - 1) downto 0);
signal reg_dout	      : std_logic;
signal transfert_done : std_logic;

-- Signals for AXI Interface
type t_axi_state is (WAITREADY, WAITVALID, ACQUIRE, TREAT);
signal axi_state : t_axi_state;

type t_samples is array ((LEN_PKT-1) downto 0) of std_logic_vector((SAMPLE_LEN- 1) downto 0);
-- DEBUT FONCTION D'INITIALISATION
function init_samples return t_samples is
variable tmp_samples : t_samples;
begin
  for i in (LEN_PKT - 1) downto 0 loop
    tmp_samples(i) := (others => '0');
  end loop;
  return tmp_samples;
end init_samples;
-- FIN FONCTION D'INITIALISATION

signal samples : t_samples := init_samples;
signal counter_data	: integer range 0 to LEN_PKT;

signal reg_data : std_logic_vector((DATA_LEN - 1) downto 0);
signal data_ready     : std_logic;

begin

-- Process I2S Interface
process (i2s_clk, aresetn)
begin
  	if aresetn = '0' then
    	i2s_state      <= WAITDATA;
			transfert_done <= '0';

			counter_clk    <= (others => '0');
			counter_bit    <= 0;
			counter_sample <= 0;

    	reg_sample     <= (others => '0');
			reg_dout       <= '0';

  		sclk_old       <= '0';
  		sclk_cur       <= '0';
  		lrclk_old      <= '0';
  		lrclk_cur      <= '0';

  	elsif i2s_clk'event and i2s_clk='1' then
    		counter_clk <= counter_clk + 1;

    		sclk_old    <= sclk_cur;
    		sclk_cur    <= not(counter_clk(1));
    		lrclk_old   <= lrclk_cur;
    		lrclk_cur   <= counter_clk(7);

		case i2s_state is
			when WAITDATA =>
				transfert_done <= '0';
				if(data_ready = '1') then
					i2s_state <= WAITFOR;
				else
					i2s_state <= WAITDATA;
				end if;

			when WAITFOR =>
				reg_sample  <= samples(counter_sample);
				reg_dout    <= '0';

				counter_bit <= 0;

				if(lrclk_old = '1' and lrclk_cur = '0') then
					i2s_state      <= TRANSFERT;
				else
					i2s_state      <= WAITFOR;
				end if;

			when TRANSFERT =>
				if(sclk_old = '0' and sclk_cur = '1') then
					reg_dout      <= reg_sample(reg_sample'length - 1);
					reg_sample    <= reg_sample(reg_sample'length-2 downto 0) & '0';

					if( counter_bit = (SAMPLE_LEN - 1) )  then
						counter_bit <= 0;
						i2s_state   <= DONE;
					else
						counter_bit <= counter_bit + 1;
						i2s_state   <= TRANSFERT;
					end if;
				else
					reg_dout      <= reg_dout;
					reg_sample    <= reg_sample;
					counter_bit   <= counter_bit;
					i2s_state     <= TRANSFERT;
				end if;

			when DONE =>
				counter_bit  <= 0;
				reg_sample <= reg_sample;

				if(sclk_old = '0' and sclk_cur = '1') then
					if(counter_sample = (LEN_PKT - 1)) then
						transfert_done <= '0';
						reg_dout  <= '0';
						i2s_state <= WAITDATA;
					else
						counter_sample <= counter_sample + 1;
						reg_dout  <= '0';
						i2s_state <= WAITFOR;
					end if;
				else
					reg_dout  <= reg_dout;
					i2s_state <= DONE;
				end if;

			when others =>
				i2s_state <= WAITDATA;
	 	end case;

 	end if;
end process;

-- Process AXI Interface
process(aclk, aresetn)
begin
	if aresetn = '0' then
		axi_state     <= WAITREADY;

		data_ready    <= '0';
		s_axis_tready <= '0';

	elsif aclk'event and aclk='1' then
		case axi_state is
			when WAITREADY =>
				counter_data <= 0;
				reg_data     <= s_axis_tdata;

				if(transfert_done = '0') then
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
					s_axis_tready         <= '0';
					data_ready            <= '1';

					reg_data              <= (others => '0');
					counter_data          <= 0;

					axi_state             <= WAITREADY;
				else
					s_axis_tready         <= '1';

					reg_data              <= s_axis_tdata;
					samples(counter_data) <= reg_data((SAMPLE_LEN - 1) downto 0);
					counter_data          <= counter_data + 1;

					axi_state             <= ACQUIRE;
				end if;
			when others =>
				axi_state <= WAITREADY;
		end case;
	else end if;
end process;

mclk   <= i2s_clk;
sclk   <= sclk_old;
lrclk  <= lrclk_old;

dout   <= reg_dout;

end arc_axi_i2s_writer;
