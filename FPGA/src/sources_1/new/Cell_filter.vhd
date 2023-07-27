library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

entity Cell_filter is
    Generic (W_IN : natural := 16;
        W_OUT  : natural := 32;
        W_COEF : natural := 12);
    Port ( clk : in std_logic;
        enable      : in  std_logic;
        dv_out      : out std_logic;
        din_i       : in  std_logic_vector(W_IN - 1 downto 0);
        din_q       : in  std_logic_vector(W_IN - 1 downto 0);
        coef_i      : in  std_logic_vector(W_COEF - 1 downto 0);
        coef_q      : in  std_logic_vector(W_COEF - 1 downto 0);
        prev_cell_i : in  std_logic_vector(W_OUT - 1 downto 0);
        next_cell_i : out std_logic_vector(W_OUT - 1 downto 0);
        prev_cell_q : in  std_logic_vector(W_OUT - 1 downto 0);
        next_cell_q : out std_logic_vector(W_OUT - 1 downto 0));
end Cell_filter;

architecture Behavioral of Cell_filter is
    -- Signals
    signal mult_ena : std_logic                                   := '0';
    signal mult_i   : std_logic_vector (W_IN+W_COEF - 1 downto 0) := (others => '0');
    signal mult_q   : std_logic_vector (W_IN+W_COEF - 1 downto 0) := (others => '0');

    signal next_cell_i_d : std_logic_vector(W_OUT - 1 downto 0) := (others => '0');
    signal next_cell_q_d : std_logic_vector(W_OUT - 1 downto 0) := (others => '0');

    -- Components
    Component Multiplier_3dsp is
        Generic (W_A : natural;
            W_B : natural);
        Port ( clk : in std_logic;
            dv_in  : in  std_logic;
            a_i    : in  std_logic_vector(W_A - 1 downto 0);
            a_q    : in  std_logic_vector(W_A - 1 downto 0);
            b_i    : in  std_logic_vector(W_B - 1 downto 0);
            b_q    : in  std_logic_vector(W_B - 1 downto 0);
            dout_i : out std_logic_vector(W_A+W_B - 1 downto 0);
            dout_q : out std_logic_vector(W_A+W_B - 1 downto 0);
            dv_out : out std_logic);
    end component;
begin

    Mult_connect : Multiplier_3dsp
        generic map(W_A => W_IN,
            W_B => W_COEF)
        port map ( clk => clk,
            dv_in  => enable,
            a_i    => din_i,
            a_q    => din_q,
            b_i    => coef_i,
            b_q    => coef_q,
            dout_i => mult_i,
            dout_q => mult_q,
            dv_out => mult_ena);

    process(clk) begin
        if rising_edge(clk) then
            if mult_ena = '1' then
                next_cell_i_d <= signed(prev_cell_i) + signed(mult_i);
                next_cell_q_d <= signed(prev_cell_q) + signed(mult_q);
            end if;
            if mult_ena = '1' then
                dv_out <= '1';
            else
                dv_out <= '0';
            end if;
        end if;
    end process;

    next_cell_i <= next_cell_i_d;
    next_cell_q <= next_cell_q_d;
--
end Behavioral;
