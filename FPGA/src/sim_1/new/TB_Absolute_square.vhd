library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity TB_Absolute_square is
    Generic (W_IN : natural := 16;
        TB_NUM : natural := 1);
--  Port ( );
end TB_Absolute_square;

architecture Behavioral of TB_Absolute_square is
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

    -- Absolute_square signals
    signal din_i, r_din_i   : std_logic_vector(W_IN - 1 downto 0)   := (others => '0');
    signal din_q, r_din_q   : std_logic_vector(W_IN - 1 downto 0)   := (others => '0');
    signal dout           : std_logic_vector(2*W_IN - 1 downto 0);
    signal enable, r_enable : STD_LOGiC := '0';
    signal dv_out           : STD_LOGiC := '0';

    -- Components
    Component Absolute_square is
        Generic (W_IN : natural);
    Port ( clk : in std_logic;
        dv_in : in  std_logic;
        din_i  : in  std_logic_vector(W_IN - 1 downto 0);
        din_q  : in  std_logic_vector(W_IN - 1 downto 0);
        dv_out : out std_logic;
        dout : out std_logic_vector(2*W_IN - 1 downto 0));
    end component;
begin

    process(clk) begin
        if rising_edge(clk) then
            r_enable <= enable;
            r_din_i  <= din_i;
            r_din_q  <= din_q;
        end if;
    end process;

    -- Components connecting
    Absolute_square_connect : Absolute_square
        generic map(W_IN => W_IN)
        port map ( clk => clk,
            dv_in => r_enable,
            din_i  => r_din_i,
            din_q  => r_din_q,
            dv_out => dv_out,
            dout => dout);

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
        din_i  <= sxt(X"2",W_IN);
        din_q  <= sxt(X"1",W_IN);
        wait_clk(1);
        din_i  <= sxt(X"0",W_IN);
        din_q  <= sxt(X"1",W_IN);
        wait_clk(1);
        din_i  <= sxt(X"0",W_IN);
        din_q  <= sxt(X"1",W_IN);
        wait_clk(1);
        din_i  <= sxt(X"1",W_IN);
        din_q  <= sxt(X"2",W_IN);
        wait_clk(1);
        din_i  <= sxt(not X"1",W_IN);
        din_q  <= sxt(X"1",W_IN);
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
