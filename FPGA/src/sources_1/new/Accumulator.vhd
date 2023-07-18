library iEEE;
use iEEE.STD_LOGiC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

entity Accumulator is
    Generic (W_OUT : natural := 32;
        W_IN   : natural := 28;
        WINDOW : natural := 16);
    Port ( clk : in std_logic;
        enable     : in  std_logic;
        reset      : in  std_logic;
        din_i      : in  std_logic_vector(W_IN - 1 downto 0);
        din_q      : in  std_logic_vector(W_IN - 1 downto 0);
        calc_ready : out std_logic := '0';
        dv         : out std_logic := '0';
        dout_i     : out std_logic_vector(W_OUT - 1 downto 0);
        dout_q     : out std_logic_vector(W_OUT - 1 downto 0));
end Accumulator;

architecture Behavioral of Accumulator is
    -- Constant
    constant W_COUNT : integer := integer(log2(real(WINDOW+1)) + 0.5);

    -- Signals
    signal sum_i   : std_logic_vector (W_OUT - 1 downto 0)   := (others => '0');
    signal sum_q   : std_logic_vector (W_OUT - 1 downto 0)   := (others => '0');
    signal counter : std_logic_vector (W_COUNT - 1 downto 0) := (others => '0');

begin

    process(clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                sum_i      <= (others => '0');
                sum_q      <= (others => '0');
                counter    <= (others => '0');
                dv         <= '0';
                calc_ready <= '0';
            else
                if enable = '1' then
                    if unsigned(counter) = WINDOW-1 then
                        calc_ready <= '1';
                    else
                        calc_ready <= '0';
                    end if;

                    sum_i   <= signed(sum_i) + signed(din_i);
                    sum_q   <= signed(sum_q) + signed(din_q);
                    counter <= unsigned(counter) + 1;
                    dv      <= '1';
                else
                    dv <= '0';
                end if;
            end if;
        end if;
    end process;

    dout_i <= sum_i;
    dout_q <= sum_q;

end Behavioral;