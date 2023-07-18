library iEEE;
use iEEE.STD_LOGiC_1164.ALL;
use ieee.std_logic_arith.all;

entity Multiplier is
    Generic (W_A : natural := 16;
        W_B : natural := 12;
        DV_D   : natural := 5);
    Port ( clk : in std_logic;
        dv_in : in  std_logic;
        a_i  : in  std_logic_vector(W_A - 1 downto 0);
        a_q  : in  std_logic_vector(W_A - 1 downto 0);
        b_i : in  std_logic_vector(W_B - 1 downto 0);
        b_q : in  std_logic_vector(W_B - 1 downto 0);
        dout_i : out std_logic_vector(W_A+W_B - 1 downto 0);
        dout_q : out std_logic_vector(W_A+W_B - 1 downto 0);
        dv_out : out std_logic);
end Multiplier;

architecture Behavioral of Multiplier is
    signal dv_out_d : std_logic_vector (DV_D - 1 downto 0) := (others => '0');

    signal a_i_d, a_q_d, a_q_dd
    : std_logic_vector(W_A - 1 downto 0) := (others => '0');
    signal b_i_d, b_i_dd, b_q_d, b_q_dd
    : std_logic_vector(W_B - 1 downto 0) := (others => '0');
    signal mult_ii, mult_qq, mult_iq, mult_qi, mult_ii_d, mult_iq_d
    : std_logic_vector (W_A+W_B-1 downto 0) := (others => '0');
    signal diff_ii_qq , add_iq_qi, diff_ii_qq_d, add_iq_qi_d
    : std_logic_vector (W_A+W_B-1 downto 0) := (others => '0');

begin

    MAC : process(clk) begin
        if rising_edge(clk) then
            dv_out_d <= dv_in & dv_out_d(DV_D-1 downto 1);

            a_i_d   <= a_i;
            b_i_d  <= b_i;
            b_i_dd <= b_i_d;
            a_q_d   <= a_q;
            a_q_dd  <= a_q_d;
            b_q_d  <= b_q;
            b_q_dd <= b_q_d;

            mult_ii    <= signed(a_i_d) * signed(b_i_d);
            mult_ii_d  <= mult_ii;
            mult_qq    <= signed(a_q_dd) * signed(b_q_dd);
            diff_ii_qq     <= signed(mult_ii_d) - signed(mult_qq);
            diff_ii_qq_d   <= diff_ii_qq;

            mult_iq    <= signed(a_i_d) * signed(b_q_d);
            mult_iq_d  <= mult_iq;
            mult_qi    <= signed(a_q_dd) * signed(b_i_dd);
            add_iq_qi      <= signed(mult_iq_d) + signed(mult_qi);
            add_iq_qi_d    <= add_iq_qi;
        end if;
    end process;

    dv_out <= dv_out_d(0);

    dout_i <= diff_ii_qq_d;
    dout_q <= add_iq_qi_d;

end Behavioral;