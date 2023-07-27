library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity Absolute_square is
    Generic (W_IN : natural := 16;
        DV_D : natural := 4);
    Port ( clk : in std_logic;
        dv_in  : in  std_logic;
        din_i  : in  std_logic_vector (W_IN - 1 downto 0);
        din_q  : in  std_logic_vector (W_IN - 1 downto 0);
        dv_out : out std_logic;
        dout   : out std_logic_vector (2*W_IN - 1 downto 0));
end Absolute_square;

architecture Behavioral of Absolute_square is
    signal dv_out_d : std_logic_vector (DV_D - 1 downto 0) := (others => '0');

    signal din_i_d, din_q_d, din_q_dd
    : std_logic_vector(W_IN - 1 downto 0) := (others => '0');
    signal mult_ii, mult_ii_d, mult_qq
    : std_logic_vector (2*W_IN - 1 downto 0) := (others => '0');
    signal add_ii_qq
    : std_logic_vector (2*W_IN - 1 downto 0) := (others => '0');

begin
    process(clk) begin
        if rising_edge(clk) then
            dv_out_d <= dv_in & dv_out_d(DV_D-1 downto 1);

            din_i_d  <= din_i;
            din_q_d  <= din_q;
            din_q_dd <= din_q_d;

            mult_ii     <= signed(din_i_d) * signed(din_i_d);
            mult_ii_d   <= mult_ii;
            mult_qq     <= signed(din_q_dd) * signed(din_q_dd);
            add_ii_qq   <= signed(mult_ii_d) + signed(mult_qq);
        end if;
    end process;

    dv_out <= dv_out_d(0);
    dout   <= add_ii_qq;

end Behavioral;
