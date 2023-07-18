library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;

entity Slider_sum is
    Generic (W_IN : natural := 16;
        W_OUT  : natural := 32;
        WINDOW : natural := 16);
    Port ( clk : in STD_LOGIC;
        reset  : in  STD_LOGIC;
        enable : in  STD_LOGIC;
        dv_out : out STD_LOGIC;
        din    : in  STD_LOGIC_VECTOR (W_IN - 1 downto 0);
        dout   : out STD_LOGIC_VECTOR (W_OUT - 1 downto 0));

end Slider_sum;

architecture Behavioral of Slider_sum is
    --Signals
    signal dv_out_d : std_logic_vector (1 downto 0) := (others => '0');

    signal res  : std_logic_vector(W_OUT - 1 downto 0) := (others => '0');
    signal diff : std_logic_vector(W_OUT - 1 downto 0) := (others => '0');

    -- Arrays
    type tdelay is array (0 to WINDOW - 1) of std_logic_vector(W_IN -1 downto 0);
    signal sdelay : tdelay := (others => (others => '0'));

begin

    process(clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                res      <= (others => '0');
                diff     <= (others => '0');
                dv_out_d <= (others => '0');
                sdelay   <= (others => (others => '0'));
            else
                if enable = '1' then
                    sdelay <= din & sdelay(0 to WINDOW - 2);
                    diff   <= signed(sxt(din, W_OUT)) - signed(sxt(sdelay(WINDOW - 1), W_OUT));
                    res    <= signed(res) + signed(diff);
                end if;
                dv_out_d <= enable & dv_out_d(1);
            end if;
        end if;
    end process;

    dv_out   <= dv_out_d(0);
    dout <= res;

end Behavioral;
