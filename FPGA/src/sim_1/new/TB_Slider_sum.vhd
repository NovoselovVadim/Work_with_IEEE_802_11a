library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;

entity TB_Slider_sum is
    Generic (W_IN : natural := 16;
        W_OUT  : natural := 32;
        WINDOW : natural := 16;
        TB_NUM : natural := 1);
--  Port ( );
end TB_Slider_sum;

architecture Behavioral of TB_Slider_sum is
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

    -- Slider_sum signals
    signal din, r_din              : std_logic_vector(W_IN - 1 downto 0) := (others => '0');
    signal dout             : std_logic_vector(W_OUT - 1 downto 0);
    signal enable, r_enable : STD_LOGiC := '0';
    signal dv_out           : STD_LOGiC := '0';
    signal reset            : STD_LOGiC := '0';

    -- Components
    Component Slider_sum is
        generic (W_IN : natural;
            W_OUT  : natural;
            WINDOW : natural);
        port ( clk : in std_logic;
            reset  : in  std_logic;
            enable : in  std_logic;
            dv_out : out std_logic;
            din    : in  std_logic_vector (W_IN - 1 downto 0);
            dout   : out std_logic_vector (W_OUT - 1 downto 0));
    end component;

begin

    process(clk) begin
        if rising_edge(clk) then
            r_enable <= enable;
            r_din  <= din;
        end if;
    end process;

    -- Components connecting
    Slider_sum_connect : Slider_sum
        generic map(W_IN => W_IN,
            W_OUT  => W_OUT,
            WINDOW => WINDOW)
        port map ( clk => clk,
            reset => reset,
            enable => r_enable,
            dv_out => dv_out,
            din  => r_din,
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

    reset_gen : process begin
        wait_clk;
        reset <= '0';
        wait_clk;
        reset <= '1';
        wait_clk;
        reset <= '0';
        wait;
    end process;

    data_gen : process begin
        wait_clk(2);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
        wait_clk(1);
        din  <= sxt(X"1",W_IN);
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
