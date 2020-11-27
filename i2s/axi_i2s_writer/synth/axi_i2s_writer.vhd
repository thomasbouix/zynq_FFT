-- reçoit les données via AXI par i2s_reader
-- les ecrits sur le PMOD via i2s

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_writer is
	generic(
		DATA_LENGTH	:	INTEGER	:= 16	-- taille des données envoyés par i2s_writer
	);
	port(
		-- SYSTEM
		resetn	:	in	std_logic;		-- RESET ACTIVE LOW
		clk			:	in	std_logic;

		-- AXI
		tvalid	: in   std_logic;  	-- master prêt à transmettre
		tlast		: in   std_logic;		-- 1 après 2048 transferts => 4096 octets == 1 page
                                -- sortie sur 2 octets envoyé quand (READY&VALID)
		tdata		:	in	 std_logic_vector((DATA_LENGTH-1) downto 0);
    tready	: out  std_logic;		-- slave prêt à recevoir

		-- I2S
		mclk	:	out		std_logic;		-- clock du systeme ==> fréquence d'échantillonage
		sclk	:	out 	std_logic;		-- bit clock : frequence des bits de DIN
		lrck	:	out 	std_logic;		-- left / right : change tout les (DATA_LENGTH+2) * SCLK
                                -- entrée du PMOD
		dout	:	out 	std_logic_vector((DATA_LENGTH-1) downto 0)
	);
end entity i2s_writer;

architecture arc_i2s_writer of i2s_writer is

    signal reg_tready : std_logic;
    signal cpt_sclk		:	unsigned(1 downto 0);		-- divise par 4 mclk
    signal cpt_lrck		:	unsigned(5 downto 0);		-- divise par 64 mclk

    signal reg_sclk		:	std_logic;
    signal reg_lrck		:	std_logic;

begin

	-- Generation des clocks i2s SCLK, LRCK
	i2s_p : process(clk, resetn) begin
			if(resetn = '0') then
						cpt_sclk  <= (others => '0');
						cpt_lrck 	<= (others => '0');
						reg_sclk	<= '0';
						reg_lrck	<= '0';
			elsif rising_edge(clk) then
						cpt_lrck <= cpt_lrck + 1;
						cpt_sclk <= cpt_sclk + 1;
						reg_sclk <= cpt_sclk(1);
						reg_lrck <= cpt_lrck(5);
			end if;
	end process i2s_p;

	mclk <= clk;
	sclk <= reg_sclk;
	lrck <= reg_lrck;

  -- generation dout, tready
  data_p : process(clk, resetn) begin

    if (resetn = '0') then
        reg_tready <= '0';
        dout <= (others => '0');
    else
        reg_tready <= '1';

        if (reg_tready = '1') and (tvalid = '1') then
            dout <= tdata;
        else end if;
    end if;

  end process;

  tready <= reg_tready;

end architecture arc_i2s_writer;
