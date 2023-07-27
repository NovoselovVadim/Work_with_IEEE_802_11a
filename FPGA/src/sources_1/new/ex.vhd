library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity ex is
    Generic (W_IN : natural := 16;
        TRESHOLD : natural := 39322); --0100110011001101 (2^16*0.6)
    Port (clk : in std_logic;
        reset      : in  std_logic;
        enable     : in  std_logic;
        din        : in  std_logic_vector (W_IN - 1 downto 0);
        start_pckt : out std_logic);
end ex;

architecture Behavioral of ex is

    signal exceeding : std_logic_vector (W_IN - 1 downto 0);
    signal peak_cntr   : std_logic_vector (1 downto 0) := (others => '0');
    signal distance    : std_logic_vector(6 downto 0)  := (others => '0');
    signal switch      : std_logic                     := '0';
    signal switch_cntr : std_logic_vector (6 downto 0) := (others => '0');

begin

    Decision_making : process(clk) begin
        if rising_edge(clk) then

            exceeding <= signed(din) - TRESHOLD;

            if reset = '1' then
                peak_cntr <= (others => '0');
            elsif unsigned(peak_cntr) = 3 then
                peak_cntr <= (others => '0');
            elsif unsigned(distance) = 127 then
                peak_cntr <= (others => '0');
            elsif enable = '1' then
                if switch = '0' then
                    if unsigned(exceeding) >= 0 then
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
            elsif unsigned(exceeding) >= 0 then
                distance <= (others => '0');
            elsif enable = '1' then
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
            elsif enable = '1' then
                switch_cntr <= unsigned(switch_cntr) + 1;
            end if;

        end if;
    end process;

end Behavioral;
