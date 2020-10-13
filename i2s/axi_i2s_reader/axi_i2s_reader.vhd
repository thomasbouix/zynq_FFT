library ieee;
use ieee.std_logic_1164.all;

entity i2s_reader is 
	generic(
		MCLK_FREQ		:	INTEGER := 22579200;
		SCLK_FREQ		:	INTEGER := 2822400;
		LRCK_FREQ		:	INTEGER	:= 44100;
		DATA_LENGTH		:	INTEGER	:= 16
	);
	port(
		aclk    		: in std_logic; 
        aresetn 		: in std_logic;

		m_axis_tdata  	: out std_logic_vector(31 downto 0);
        m_axis_tvalid 	: out std_logic;
        m_axis_tready 	: in  std_logic;

		mclk			: inout	std_logic;
		sclk			: out 	std_logic;
		lrck			: out 	std_logic;
		din				: in 	std_logic
	);
end entity i2s_reader;

architecture arc_i2s_reader of i2s_reader is
	
	type t_state is (WAITFOR,SEND);
	signal state : t_state;

	signal reg_data		:	std_logic_vector((DATA_LENGTH-1) downto 0);
	signal count_data	: 	integer range 0 to DATA_LENGTH;

	signal cmp_sclk		:	integer; -- range 0 to (CLK_FREQ/SCLK_FREQ);
	signal cmp_lrck		:	integer; -- range 0 to (CLK_FREQ/LRCK_FREQ);
	
	signal reg_sclk		:	std_logic;
	signal reg_lrck		:	std_logic;


begin

	process(aclk,aresetn)
	begin
		if(aresetn = '1') then
			reg_data 	<= (others => '0');
			count_data 	<= 0;
			cmp_sclk  	<= 0;
			cmp_lrck 	<= 0;
			reg_sclk	<= '0';
			reg_lrck	<= '0';
			
		elsif rising_edge(aclk) then
		
			if(cmp_sclk > ((MCLK_FREQ/SCLK_FREQ)/2)-2 ) then
				reg_sclk <= not(reg_sclk);
				cmp_sclk <= 0;
			else
				cmp_sclk <= cmp_sclk + 1;
			end if;
			
			if(cmp_lrck > ((MCLK_FREQ/LRCK_FREQ)/2)-2 ) then
				reg_lrck <= not(reg_lrck);
				cmp_lrck <= 0;
			else
				cmp_lrck <= cmp_lrck + 1;
			end if;
			
			if(reg_lrck = '1') then
				if(count_data < 16) then
					reg_data(count_data) <= din;
					count_data <= count_data + 1;
				end if;
			else
				count_data <= 0;
			end if;
				
		end if;
	
	end process;

	
	process(aclk,aresetn)
	begin
		if(state = WAITFOR) then
			if(count = 15) then
				state = SEND;
			else
				state = WAITFOR;
			end if,
		elsif(state = SEND) then
			if(m_axis_tready = '1')
				m_axis_tdata <= "000000000000000" & reg_data; 
				m_axis_tvalid <= '1';
				state = WAITFOR;
			else
				m_axis_tdata <= (others => '0');
				m_axis_tvalid <= '0';
				state = SEND;
			end if;
		else
			
		end if;
	end process;
	
	data <= reg_data;
	
	sclk <= reg_sclk;
	lrck <= reg_lrck;


end architecture arc_i2s_reader;