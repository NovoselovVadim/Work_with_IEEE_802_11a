library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.math_real.all;

entity Norm_cross_corr is
    Generic (W_IN : natural := 16;
        W_ENERG     : natural := 32;
        WINDOW      : natural := 16;
        W_ENERG_SQR : natural := 64;
        W_DIV_OUT   : natural := 80;
        W_OUT       : natural := 16);
    Port ( clk : in std_logic;
        reset      : in  std_logic;
        enable     : in  std_logic;
        coef_energ : in  std_logic_vector (W_ENERG - 1 downto 0);
        din_i      : in  std_logic_vector (W_IN - 1 downto 0);
        din_q      : in  std_logic_vector (W_IN - 1 downto 0);
        dv_out     : out std_logic;
        dout       : out std_logic_vector(W_IN - 1 downto 0));
end Norm_cross_corr;

architecture Behavioral of Norm_cross_corr is
    -- Signals
    signal dv_corr, dv_corr_energ : std_logic                                   := '0';
    signal corr_i, corr_q         : std_logic_vector (W_ENERG - 1 downto 0)     := (others => '0');
    signal corr_energ             : std_logic_vector (W_ENERG_SQR - 1 downto 0) := (others => '0');

    signal dv_din_sqr : std_logic                               := '0';
    signal din_sqr    : std_logic_vector (W_ENERG - 1 downto 0) := (others => '0');

    signal dv_sum      : std_logic                               := '0';
    signal din_energ   : std_logic_vector (W_ENERG + 3 downto 0) := (others => '0');
    signal din_energ_x : std_logic_vector (W_ENERG - 1 downto 0) := (others => '0');

    signal dv_mult_energ   : std_logic;
    signal dv_mult_energ_d : std_logic_vector (3 downto 0)              := (others => '0');
    signal mult_energ      : std_logic_vector(W_ENERG_SQR - 1 downto 0) := (others => '0');

    signal divisor_tready, dividend_tready : std_logic                                 := '1'; --
    signal norm_corr                       : std_logic_vector (W_DIV_OUT - 1 downto 0) := (others => '0');
    signal dv_divider                      : std_logic;

    -- Arrays
    type mult_delay is array (3 downto 0) of std_logic_vector(W_ENERG_SQR -1 downto 0);
    signal mult_energ_d : mult_delay := (others => (others => '0'));

    -- Components
    Component STS_filter is
        generic (W_IN : natural;
            W_OUT : natural);
        port ( clk : in std_logic;
            enable : in  std_logic;
            dv_out : out std_logic;
            din_i  : in  std_logic_vector(W_IN - 1 downto 0);
            din_q  : in  std_logic_vector(W_IN - 1 downto 0);
            dout_i : out std_logic_vector (W_OUT - 1 downto 0);
            dout_q : out std_logic_vector (W_OUT - 1 downto 0));
    end component;

    Component Absolute_square is
        Generic (W_IN :    natural);
        Port ( clk    : in std_logic;
            dv_in  : in  std_logic;
            din_i  : in  std_logic_vector(W_IN - 1 downto 0);
            din_q  : in  std_logic_vector(W_IN - 1 downto 0);
            dv_out : out std_logic;
            dout   : out std_logic_vector(2*W_IN - 1 downto 0));
    end component;

    Component Slider_sum is
        generic (W_OUT : natural;
            W_IN   : natural;
            WINDOW : natural);
        Port ( clk : in STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            dv_out : out STD_LOGIC;
            din    : in  STD_LOGIC_VECTOR (W_IN - 1 downto 0);
            dout   : out STD_LOGIC_VECTOR (W_OUT - 1 downto 0));
    end component;

    Component div_gen_0 is
        PORT (aclk : IN STD_LOGIC;
            s_axis_divisor_tvalid  : IN  STD_LOGIC;
            s_axis_divisor_tready  : OUT STD_LOGIC; --
            s_axis_divisor_tdata   : IN  STD_LOGIC_VECTOR(W_ENERG_SQR - 1 DOWNTO 0);
            s_axis_dividend_tvalid : IN  STD_LOGIC;
            s_axis_dividend_tready : OUT STD_LOGIC; --
            s_axis_dividend_tdata  : IN  STD_LOGIC_VECTOR(W_ENERG_SQR - 1 DOWNTO 0);
            m_axis_dout_tvalid     : OUT STD_LOGIC;
            m_axis_dout_tdata      : OUT STD_LOGIC_VECTOR(W_DIV_OUT - 1 DOWNTO 0));
    end component;

begin

    -- Components connecting
    STS_filter_connect : STS_filter
        Generic map (W_IN => W_IN,
            W_OUT => W_ENERG)
        Port map ( clk => clk,
            enable => enable,
            dv_out => dv_corr,
            din_i  => din_i,
            din_q  => din_q,
            dout_i => corr_i,
            dout_q => corr_q);

    Corr_energ_connect : Absolute_square
        generic map(W_IN => W_ENERG)
        port map ( clk   => clk,
            dv_in  => dv_corr,
            din_i  => corr_i,
            din_q  => corr_q,
            dv_out => dv_corr_energ,
            dout   => corr_energ);

    Din_sqr_connect : Absolute_square
        generic map(W_IN => W_IN)
        port map ( clk   => clk,
            dv_in  => enable,
            din_i  => din_i,
            din_q  => din_q,
            dv_out => dv_din_sqr,
            dout   => din_sqr);

    Din_energ_connect : Slider_sum
        generic map(W_OUT => W_ENERG+4,
            W_IN   => W_ENERG,
            WINDOW => WINDOW)
        port map (clk => clk,
            reset  => reset,
            enable => dv_din_sqr,
            dv_out => dv_sum,
            din    => din_sqr,
            dout   => din_energ);

    din_energ_x <= sxt(din_energ, W_ENERG);

    process(clk) begin
        if rising_edge(clk) then

            if dv_sum = '1' then
                mult_energ    <= signed(din_energ_x) * signed(coef_energ);
                dv_mult_energ <= '1';
            else
                dv_mult_energ <= '0';
            end if;

            mult_energ_d    <= mult_energ & mult_energ_d(3 downto 1);
            dv_mult_energ_d <= dv_mult_energ & dv_mult_energ_d(3 downto 1);

        end if;
    end process ;

    Divider_connect : div_gen_0
        PORT MAP (aclk => clk,
            s_axis_divisor_tvalid  => dv_mult_energ_d(0),
            s_axis_divisor_tready  => divisor_tready,--
            s_axis_divisor_tdata   => std_logic_vector(unsigned(mult_energ_d(0))),
            s_axis_dividend_tvalid => dv_corr_energ,
            s_axis_dividend_tready => dividend_tready,--
            s_axis_dividend_tdata  => std_logic_vector(unsigned(corr_energ)),
            m_axis_dout_tvalid     => dv_divider,
            m_axis_dout_tdata      => norm_corr);

    dv_out <= dv_divider;
    dout   <= ext(norm_corr, W_OUT);

end Behavioral;
