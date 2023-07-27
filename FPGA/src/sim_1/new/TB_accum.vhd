library iEEE;
use iEEE.STD_LOGiC_1164.ALL;
use ieee.std_logic_arith.all;

entity TB_accum is
    Generic (lengthPartSum : natural := 32;
        W_MULT : natural := 28;
        Window     : natural := 16);
--  Port ( );
end TB_accum;

architecture Behavioral of TB_accum is
    -- Clock signals
    signal clk        : STD_LOGiC;
    signal clk_period : time := 10 ns;
    -- Accumulator signals
    signal din_i,din_q,r_din_i,r_din_q : std_logic_vector(W_MULT - 1 downto 0);
    signal calc_ready                  : std_logic := '0';
    signal dout_i                      : STD_LOGiC_VECTOR (lengthPartSum - 1 downto 0);
    signal dout_q                      : STD_LOGiC_VECTOR (lengthPartSum - 1 downto 0);
    signal enable,r_enable             : STD_LOGiC := '0';
    signal reset                       : STD_LOGiC := '0';
    signal reset_accum,r_reset_accum   : STD_LOGiC := '0';

    procedure wait_clk (
            num_clk : natural := 1
        ) is
    begin
        for i in 0 to num_clk - 1 loop
            wait on clk until clk = '1';
        end loop ;
    end procedure;

    -- Components
    Component Accumulator is
        Generic (lengthPartSum : natural;
            W_MULT : natural;
            Window     : natural);
        Port ( clk : in std_logic;
            enable     : in  std_logic;
            reset      : in  std_logic;
            din_i      : in  std_logic_vector(W_MULT - 1 downto 0);
            din_q      : in  std_logic_vector(W_MULT - 1 downto 0);
            calc_ready : out std_logic;
            dout_i     : out std_logic_vector(lengthPartSum - 1 downto 0);
            dout_q     : out std_logic_vector(lengthPartSum - 1 downto 0));
    end component;

begin

    process(clk) begin
        if rising_edge(clk) then
            r_enable      <= enable;
            r_reset_accum <= reset_accum;
            r_din_i       <= din_i;
            r_din_q       <= din_q;
        end if;
    end process;

    -- Components connecting
    Accumulator_connect : Accumulator
        generic map(lengthPartSum => lengthPartSum,
            W_MULT => W_MULT,
            Window     => Window)
        port map ( clk => clk,
            enable     => r_enable,
            reset      => reset_accum,
            din_i      => r_din_i,
            din_q      => r_din_q,
            calc_ready => calc_ready,
            dout_i     => dout_i,
            dout_q     => dout_q);

    reset_accum <= calc_ready or reset;

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
    --
    enable_gen : process begin
        enable <= '0';
        wait_clk;
        enable <= '1';
        wait;
    end process;
    --
    reset_gen : process begin
        wait_clk;
        reset <= '0';
        wait_clk;
        reset <= '1';
        wait_clk;
        reset <= '0';
        wait;
    end process;
    --
    data_gen : process begin
        wait_clk(1);
        din_i <= sxt(X"00", W_MULT);
        din_q <= sxt(X"00", W_MULT);
        wait_clk(1);
        loop
            din_i <= sxt(X"01", W_MULT);
            din_q <= sxt(X"01", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"02", W_MULT);
            din_q <= sxt(X"02", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"03", W_MULT);
            din_q <= sxt(X"03", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"04", W_MULT);
            din_q <= sxt(X"04", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"05", W_MULT);
            din_q <= sxt(X"05", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"06", W_MULT);
            din_q <= sxt(X"06", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"07", W_MULT);
            din_q <= sxt(X"07", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"08", W_MULT);
            din_q <= sxt(X"08", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"09", W_MULT);
            din_q <= sxt(X"09", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0A", W_MULT);
            din_q <= sxt(X"0A", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0B", W_MULT);
            din_q <= sxt(X"0B", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0C", W_MULT);
            din_q <= sxt(X"0C", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0D", W_MULT);
            din_q <= sxt(X"0D", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0E", W_MULT);
            din_q <= sxt(X"0E", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"0F", W_MULT);
            din_q <= sxt(X"0F", W_MULT);
            wait_clk(1);
            din_i <= sxt(X"10", W_MULT);
            din_q <= sxt(X"10", W_MULT);
            wait_clk(1);
        end loop;
    end process;
--
end Behavioral;