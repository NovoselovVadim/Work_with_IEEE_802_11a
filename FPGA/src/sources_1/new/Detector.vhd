library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity Detector is
    Generic (W_IN : natural := 16;
        W_ENERG     : natural := 32;
        WINDOW      : natural := 16;
        W_ENERG_SQR : natural := 64;
        W_DIV_OUT   : natural := 80;
        W_OUT       : natural := 16;
        TRESHOLD    : natural := 39322); -- (2^16*0.6)
    Port ( clk : in std_logic;
        reset      : in  std_logic;
        enable     : in  std_logic;
        din_i      : in  std_logic_vector (W_IN - 1 downto 0);
        din_q      : in  std_logic_vector (W_IN - 1 downto 0);
        start_pckt : out std_logic);
end Detector;

architecture Behavioral of Detector is

    -- Signals
    signal dv_norm_corr : std_logic;
    signal norm_corr    : std_logic_vector (W_IN - 1 downto 0) := (others => '0');

    signal peak_cntr   : std_logic_vector (1 downto 0)        := (others => '0');
    signal distance    : std_logic_vector(6 downto 0)         := (others => '0');
    signal switch      : std_logic                            := '0';
    signal switch_cntr : std_logic_vector (6 downto 0)        := (others => '0');
    --signal exceeding   : std_logic_vector (W_IN - 1 downto 0) := (others => '0');

    -- Arrays
    signal coef_energ : std_logic_vector(W_ENERG - 1 downto 0) := "00000000110011111111111111111111";

    -- Components
    Component Norm_cross_corr is
        generic (W_IN : natural;
            W_ENERG     : natural;
            WINDOW      : natural;
            W_ENERG_SQR : natural;
            W_DIV_OUT   : natural;
            W_OUT       : natural);
        port ( clk : in std_logic;
            reset      : in  std_logic;
            enable     : in  std_logic;
            coef_energ : in  std_logic_vector (W_ENERG - 1 downto 0);
            din_i      : in  std_logic_vector (W_IN - 1 downto 0);
            din_q      : in  std_logic_vector (W_IN - 1 downto 0);
            dv_out     : out std_logic;
            dout       : out std_logic_vector (W_OUT - 1 downto 0));
    end component;

begin

    -- Components connecting
    Norm_cross_corr_connect : Norm_cross_corr
        generic map(W_IN => W_IN,
            W_ENERG     => W_ENERG,
            WINDOW      => WINDOW,
            W_ENERG_SQR => W_ENERG_SQR,
            W_DIV_OUT   => W_DIV_OUT,
            W_OUT       => W_OUT)
        port map ( clk => clk,
            reset      => reset,
            enable     => enable,
            coef_energ => coef_energ,
            din_i      => din_i,
            din_q      => din_q,
            dout       => norm_corr,
            dv_out     => dv_norm_corr);

    Decision_making : process(clk) begin
        if rising_edge(clk) then

            --exceeding <= unsigned(norm_corr) - TRESHOLD;

            if reset = '1' then
                peak_cntr <= (others => '0');
            elsif unsigned(peak_cntr) = 3 then
                peak_cntr <= (others => '0');
            elsif unsigned(distance) = 127 then
                peak_cntr <= (others => '0');
            elsif dv_norm_corr = '1' then
                if switch = '0' then 
                    if unsigned(norm_corr) >= TRESHOLD then
                        peak_cntr <= unsigned(peak_cntr) + 1;
                    end if;
                end if;
            end if;

            if unsigned(peak_cntr) = 3 then
                start_pckt <= '1';
            else
                start_pckt <= '0';
            end if;

            if reset = '1' then
                distance <= (others => '0');
            elsif unsigned(norm_corr) >= TRESHOLD then
                distance <= (others => '0');
            elsif dv_norm_corr = '1' then
                if unsigned(peak_cntr) > 0 then
                    distance <= unsigned(distance) + 1;
                end if;
            end if;

            if reset = '1' then
                switch <= '0';
            elsif unsigned(peak_cntr) = 3 then
                switch <= '1';
            elsif unsigned(switch_cntr) = 127 then
                switch <= '0';
            end if;

            if reset = '1' then
                switch_cntr <= (others => '0');
            elsif switch = '0' then
                switch_cntr <= (others => '0');
            elsif dv_norm_corr = '1' then
                switch_cntr <= unsigned(switch_cntr) + 1;
            end if;

        end if;
    end process;

end Behavioral;
