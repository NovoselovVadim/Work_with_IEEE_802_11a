library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplier_3dsp is
    generic (W_A : natural := 16;
        W_B  : natural := 12;
        DV_D : natural := 6);
    port (clk : in std_logic;
        dv_in  : in  std_logic;
        a_i    : in  std_logic_vector(W_A-1 downto 0);
        a_q    : in  std_logic_vector(W_A-1 downto 0);
        b_i    : in  std_logic_vector(W_B-1 downto 0);
        b_q    : in  std_logic_vector(W_B-1 downto 0);
        dout_i : out std_logic_vector(W_A+W_B-1 downto 0);
        dout_q : out std_logic_vector(W_A+W_B-1 downto 0);
        dv_out : out std_logic);
end Multiplier_3dsp;

architecture Behavioral of Multiplier_3dsp is
    signal dv_out_d : std_logic_vector (DV_D - 1 downto 0) := (others => '0');

    signal a_i_d, a_i_dd, a_i_ddd, a_i_dddd               : signed(W_A-1 downto 0)   := (others => '0');
    signal a_q_d, a_q_dd, a_q_ddd, a_q_dddd               : signed(W_A-1 downto 0)   := (others => '0');
    signal b_q_d, b_q_dd, b_q_ddd, b_i_d, b_i_dd, b_i_ddd : signed(W_B-1 downto 0)   := (others => '0');
    signal addcommon                                      : signed(W_A downto 0)     := (others => '0');
    signal addr, addi                                     : signed(W_B downto 0)     := (others => '0');
    signal mult0, multr, multi, dout_i_int, dout_q_int    : signed(W_A+W_B downto 0) := (others => '0');
    signal common, commonr1, commonr2                     : signed(W_A+W_B downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            dv_out_d <= dv_in & dv_out_d(DV_D-1 downto 1);

            a_i_d   <= signed(a_i);
            a_i_dd  <= signed(a_i_d);
            a_q_d   <= signed(a_q);
            a_q_dd  <= signed(a_q_d);
            b_i_d   <= signed(b_i);
            b_i_dd  <= signed(b_i_d);
            b_i_ddd <= signed(b_i_dd);
            b_q_d   <= signed(b_q);
            b_q_dd  <= signed(b_q_d);
            b_q_ddd <= signed(b_q_dd);

            addcommon <= resize(a_i_d, W_A+1) - resize(a_q_d, W_A+1);
            mult0     <= addcommon * b_q_dd;
            common    <= mult0;

            a_i_ddd    <= a_i_dd;
            a_i_dddd   <= a_i_ddd;
            addr       <= resize(b_i_ddd, W_B+1) - resize(b_q_ddd, W_B+1);
            multr      <= addr * a_i_dddd;
            commonr1   <= common;
            dout_i_int <= multr + commonr1;

            a_q_ddd    <= a_q_dd;
            a_q_dddd   <= a_q_ddd;
            addi       <= resize(b_i_ddd, W_B+1) + resize(b_q_ddd, W_B+1);
            multi      <= addi * a_q_dddd;
            commonr2   <= common;
            dout_q_int <= multi + commonr2;
        end if;
    end process;

    dv_out <= dv_out_d(0);

    dout_i <= std_logic_vector(resize(dout_i_int,W_A+W_B));
    dout_q <= std_logic_vector(resize(dout_q_int,W_A+W_B));

end Behavioral;
