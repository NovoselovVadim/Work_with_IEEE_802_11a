library iEEE;
use iEEE.STD_LOGiC_1164.ALL;
use ieee.std_logic_arith.all;

entity TB_mult is
    Generic (W_A : natural := 16;
        W_B  : natural := 12;
        TB_NUM : natural := 1);
--  Port ( );
end TB_mult;

architecture Behavioral of TB_mult is
    -- Clock signals
    signal clk        : STD_LOGiC;
    signal clk_period : time := 10 ns;

    procedure wait_clk (
            num_clk : natural := 1
        ) is
    begin
        for i in 0 to num_clk - 1 loop
            wait on clk until clk = '1';
        end loop ;
    end procedure;

    -- Multiplier signals
    signal din_i, r_din_i   : std_logic_vector(W_A - 1 downto 0)   := (others => '0');
    signal din_q, r_din_q   : std_logic_vector(W_A - 1 downto 0)   := (others => '0');
    signal coef_i, r_coef_i : std_logic_vector(W_B - 1 downto 0) := (others => '0');
    signal coef_q, r_coef_q : std_logic_vector(W_B - 1 downto 0) := (others => '0');
    signal dout_i           : std_logic_vector(W_A+W_B - 1 downto 0);
    signal dout_q           : std_logic_vector(W_A+W_B - 1 downto 0);
    signal enable, r_enable : STD_LOGiC := '0';
    signal dv_out           : STD_LOGiC := '0';

    -- Components
    Component Multiplier is
        Generic (W_A : natural;
            W_B  : natural);
    Port ( clk : in std_logic;
        dv_in : in  std_logic;
        a_i  : in  std_logic_vector(W_A - 1 downto 0);
        a_q  : in  std_logic_vector(W_A - 1 downto 0);
        b_i : in  std_logic_vector(W_B - 1 downto 0);
        b_q : in  std_logic_vector(W_B - 1 downto 0);
        dout_i : out std_logic_vector(W_A+W_B - 1 downto 0);
        dout_q : out std_logic_vector(W_A+W_B - 1 downto 0);
        dv_out : out std_logic);
    end component;
--
begin

    process(clk) begin
        if rising_edge(clk) then
            r_enable <= enable;
            r_din_i  <= din_i;
            r_din_q  <= din_q;
            r_coef_i <= coef_i;
            r_coef_q <= coef_q;
        end if;
    end process;

    -- Components connecting
    Multiplier_connect : Multiplier
        generic map(W_A => W_A,
            W_B  => W_B)
        port map ( clk => clk,
            dv_in => r_enable,
            a_i  => r_din_i,
            a_q  => r_din_q,
            b_i => r_coef_i,
            b_q => r_coef_q,
            dout_i => dout_i,
            dout_q => dout_q,
            dv_out => dv_out);

    -- Signals generate
    clk_gen : process begin
        clk <= '0';
        wait for clk_period/2;
        loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
    end process;

    data_gen : process begin
        wait_clk(2);
        din_i  <= sxt(X"2",W_A);
        din_q  <= sxt(X"1",W_A);
        coef_i <= sxt(X"1",W_B);
        coef_q <= sxt(X"1",W_B);
        wait_clk(1);
        din_i  <= sxt(X"0",W_A);
        din_q  <= sxt(X"1",W_A);
        coef_i <= sxt(X"0",W_B);
        coef_q <= sxt(X"1",W_B);
        wait_clk(1);
        din_i  <= sxt(X"0",W_A);
        din_q  <= sxt(X"1",W_A);
        coef_i <= sxt(X"1",W_B);
        coef_q <= sxt(X"0",W_B);
        wait_clk(1);
        din_i  <= sxt(X"1",W_A);
        din_q  <= sxt(X"2",W_A);
        coef_i <= sxt(X"3",W_B);
        coef_q <= sxt(X"4",W_B);
        wait_clk(1);
        din_i  <= sxt(not X"1",W_A);
        din_q  <= sxt(X"1",W_A);
        coef_i <= sxt(not X"1",W_B);
        coef_q <= sxt(X"1",W_B);
    end process;

    enable_gen : process begin
        case(TB_NUM) is
            when 1 =>
                wait_clk(2);
                enable <= '1';
            when 2 =>
                wait_clk(2);
                loop
                    enable <= '1';
                    wait_clk(1);
                    enable <= '0';
                    wait_clk(2);
                end loop ;
            when 3 =>
                wait_clk(2);
                loop
                    enable <= '1';
                    wait_clk(1);
                    enable <= '0';
                    wait_clk(1);
                end loop ;
            when 4 =>
                wait_clk(2);
                loop
                    enable <= '1';
                    wait_clk(1);
                    enable <= '0';
                    wait_clk(11);
                end loop ;
            when 5 =>
                wait_clk(2);
                loop
                    enable <= '1';
                    wait_clk(2);
                    enable <= '0';
                    wait_clk(10);
                end loop ;
            when others =>
                enable <= '0';
                wait;
        end case;
    end process;
end Behavioral;
