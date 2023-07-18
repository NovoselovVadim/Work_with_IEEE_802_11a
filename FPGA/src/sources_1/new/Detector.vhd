library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

entity Detector is
    Generic (W_IN : natural := 16;
        WINDOW   : natural := 16;
        TRESHOLD : natural := 19661); --0100110011001101
    Port ( clk : in std_logic;
        enable     : in  std_logic;
        din_i      : in  std_logic_vector (W_IN - 1 downto 0);
        din_q      : in  std_logic_vector (W_IN - 1 downto 0);
        start_pckt : out std_logic);
end Detector;

architecture Behavioral of Detector is
    -- Constants
    constant W_ENERG : natural := natural(W_IN*2);

    -- Signals
    signal dv_norm_corr : std_logic;
    signal norm_corr    : std_logic_vector (W_IN - 1 downto 0) := (others => '0');

    signal peak_cntr : std_logic_vector (1 downto 0) := (others => '0');
    signal distance  : std_logic_vector(6 downto 0)  := (others => '0');

    signal switch      : std_logic                     := '0';
    signal switch_cntr : std_logic_vector (6 downto 0) := (others => '0');

    -- Arrays
    signal coef_energ : std_logic_vector(W_ENERG - 1 downto 0) := "00000000110011111111000011001100";

    -- Components
    Component Norm_cross_corr is
        generic (W_IN :    natural);
        port ( clk    : in std_logic;
            enable     : in  std_logic;
            coef_energ : in  std_logic_vector (W_ENERG - 1 downto 0);
            din_i      : in  std_logic_vector (W_IN - 1 downto 0);
            din_q      : in  std_logic_vector (W_IN - 1 downto 0);
            dv_out     : out std_logic;
            dout       : out std_logic_vector (W_IN - 1 downto 0));
    end component;

begin

    -- Components connecting
    Norm_cross_corr_connect : Norm_cross_corr
        generic map(W_IN => W_IN)
        port map ( clk   => clk,
            enable     => enable,
            coef_energ => coef_energ,
            din_i      => din_i,
            din_q      => din_q,
            dout       => norm_corr,
            dv_out     => dv_norm_corr);

    Decision_making : process(clk) begin
        if rising_edge(clk) then
            if dv_norm_corr = '1' then
                if switch = '0' then

                    if unsigned(norm_corr) >= TRESHOLD then
                        peak_cntr <= unsigned(peak_cntr) + 1;
                        distance <= (others => '0');
                    end if;

                    if unsigned(peak_cntr) = 3 then
                        peak_cntr  <= (others => '0');
                        switch     <= '1';
                        start_pckt <= '1';
--                    else
--                        switch     <= '0';
--                        start_pckt <= '0';
                    end if;

                else

                    if unsigned(switch_cntr) = 127 then
                        switch_cntr <= (others => '0');
                        switch      <= '0';
                    else
                        switch_cntr <= unsigned(switch_cntr) + 1;
                        switch      <= '1';
                        start_pckt  <= '0';
                    end if;

                end if;

            if unsigned(peak_cntr) >= 1 then
                if unsigned(distance) = 127 then
                    distance <= (others => '0');
                    peak_cntr  <= (others => '0');
                else
                    distance <= unsigned(distance) + 1;
                end if;
            end if;

            end if;
        end if;
    end process;

end Behavioral;
