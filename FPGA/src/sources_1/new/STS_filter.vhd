library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity STS_filter is
    Generic (W_IN : natural := 16;
        W_OUT    : natural := 32;
        CELL_NUM : natural := 16;
        W_COEF   : natural := 12);
    Port ( clk : in std_logic;
        enable : in  std_logic;
        dv_out : out std_logic;
        din_i  : in  std_logic_vector (W_IN - 1 downto 0);
        din_q  : in  std_logic_vector (W_IN - 1 downto 0);
        dout_i : out std_logic_vector (W_OUT - 1 downto 0);
        dout_q : out std_logic_vector (W_OUT - 1 downto 0));
end STS_filter;

architecture Behavioral of STS_filter is

    -- Arrays
    type RES_ARRAY is array (CELL_NUM downto 0) of std_logic_vector(W_OUT - 1 downto 0);
    signal res_i : RES_ARRAY := (others => (others => '0'));
    signal res_q : RES_ARRAY := (others => (others => '0'));

    type ROM_COEF is array (0 to CELL_NUM - 1) of std_logic_vector(W_COEF - 1 downto 0);
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
    Component Cell_filter is
        generic (W_IN : natural;
            W_OUT  : natural;
            W_COEF : natural);
        port ( clk : in std_logic;
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
    end component;

begin

    -- Components connecting
    Cell : for I in 1 to CELL_NUM generate
        Cells : Cell_filter
            generic map( W_IN => W_IN,
                W_OUT  => W_OUT,
                W_COEF => W_COEF)
            port map (
                clk         => clk,
                enable      => enable,
                dv_out      => dv_out,
                din_i       => din_i,
                din_q       => din_q,
                coef_i      => coef_i(I-1),
                coef_q      => coef_q(I-1),
                prev_cell_i => res_i(I-1),
                next_cell_i => res_i(I),
                prev_cell_q => res_q(I-1),
                next_cell_q => res_q(I));
    end generate Cell;

    dout_i <= res_i(CELL_NUM);
    dout_q <= res_q(CELL_NUM);
end Behavioral;
