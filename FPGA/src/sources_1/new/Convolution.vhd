library iEEE;
use iEEE.STD_LOGiC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

entity Convolution is
    Generic (W_IN : natural := 16;
        W_OUT  : natural := 32;
        W_COEF : natural := 12;
        WINDOW : natural := 16);

    Port ( clk : in std_logic;
        enable : in  std_logic;
        reset  : in  std_logic;
        din_i  : in  std_logic_vector (W_IN - 1 downto 0);
        din_q  : in  std_logic_vector (W_IN - 1 downto 0);
        dout_i : out std_logic_vector (W_OUT - 1 downto 0);
        dout_q : out std_logic_vector (W_OUT - 1 downto 0);
        out_dv : out std_logic;
        ready  : out std_logic);
end Convolution;

architecture Behavioral of Convolution is

    -- Constants
    constant W_COUNT : integer := integer(log2(real(WINDOW)) + 0.5);

    -- Signals
    signal accum_ready : std_logic := '0';
    signal accum_ena   : std_logic := '0';
    signal accum_reset : std_logic := '0';

    signal coef_count : std_logic_vector (W_COUNT - 1 downto 0) := (others => '0');

    signal mult_i : std_logic_vector (W_IN+W_COEF - 1 downto 0) := (others => '0');
    signal mult_q : std_logic_vector (W_IN+W_COEF - 1 downto 0) := (others => '0');

    signal accum_dout_i : std_logic_vector (W_OUT - 1 downto 0) := (others => '0');
    signal accum_dout_q : std_logic_vector (W_OUT - 1 downto 0) := (others => '0');

    -- Arrays
    type ROM_COEF is array (0 to WINDOW - 1) of std_logic_vector(W_COEF - 1 downto 0);
    signal coef_i : ROM_COEF := (15 => "000101111001", 7 => "000101111001",
                                 14 => "101111000011", 6 => "000000010011",
                                 13 => "111110010010", 5 => "110101111101",
                                 12 => "010010010001", 4 => "111110011000",
                                 11 => "001011110010", 3 => "000000000000",
                                 10 => "010010010001", 2 => "111110011000",
                                 9  => "111110010010", 1 => "110101111101",
                                 8  => "101111000011", 0 => "000000010011");

    signal coef_q : ROM_COEF := (15 => "000101111001", 7 => "000101111001",
                                 14 => "000000010011", 6 => "101111000011",
                                 13 => "110101111101", 5 => "111110010010",
                                 12 => "111110011000", 4 => "010010010001",
                                 11 => "000000000000", 3 => "001011110010",
                                 10 => "111110011000", 2 => "010010010001",
                                 9  => "110101111101", 1 => "111110010010",
                                 8  => "000000010011", 0 => "101111000011");

    -- Components
    Component Multiplier is
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

    Component Accumulator is
        generic (W_OUT : natural;
            W_IN   : natural;
            WINDOW : natural);
        Port ( clk : in std_logic;
            enable     : in  std_logic;
            reset      : in  std_logic;
            din_i      : in  std_logic_vector(W_IN - 1 downto 0);
            din_q      : in  std_logic_vector(W_IN - 1 downto 0);
            calc_ready : out std_logic;
            dv         : out std_logic;
            dout_i     : out std_logic_vector(W_OUT - 1 downto 0);
            dout_q     : out std_logic_vector(W_OUT - 1 downto 0));
    end component;

begin

    Choice_coef : process(clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                coef_count <= (others => '0');
            elsif unsigned(coef_count) = WINDOW-1 then
                coef_count <= (others => '0');
            elsif enable = '1' then
                coef_count <= unsigned(coef_count) + 1;
            end if;
        end if;
    end process;

    Mult_connect : Multiplier
        generic map(W_A => W_IN,
            W_B => W_COEF)
        port map ( clk => clk,
            dv_in  => enable,
            a_i    => din_i,
            a_q    => din_q,
            b_i    => coef_i(conv_integer(unsigned(coef_count))),
            b_q    => coef_q(conv_integer(unsigned(coef_count))),
            dout_i => mult_i,
            dout_q => mult_q,
            dv_out => accum_ena);

    Accum_connect : Accumulator
        generic map(W_OUT => W_OUT,
            W_IN   => W_IN+W_COEF,
            WINDOW => WINDOW)
        port map (clk => clk,
            enable     => accum_ena,
            reset      => accum_reset,
            din_i      => mult_i,
            din_q      => mult_q,
            calc_ready => accum_ready,
            dv         => out_dv,
            dout_i     => accum_dout_i,
            dout_q     => accum_dout_q);

    accum_reset <= reset or accum_ready;

    ready  <= accum_ready;
    dout_i <= accum_dout_i;
    dout_q <= accum_dout_q;
end Behavioral;
