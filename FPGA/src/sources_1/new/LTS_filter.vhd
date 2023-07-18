library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity LTS_filter is
    Generic (tapLineLength : integer := 64;
             lengthPartSum : integer := 32);
    Port ( clk : in std_logic;
           enable : in std_logic;
           din_I : in std_logic_vector (15 downto 0);
           din_Q : in std_logic_vector (15 downto 0);
           dout_I : out std_logic_vector (lengthPartSum - 1 downto 0);
           dout_Q : out std_logic_vector (lengthPartSum - 1 downto 0));
end LTS_filter;

architecture Behavioral of LTS_filter is
    type result_array is array (tapLineLength downto 0) of std_logic_vector(lengthPartSum - 1 downto 0);
    signal resultI : result_array := (others => (others => '0'));
    signal resultQ : result_array := (others => (others => '0'));
--
    signal din_I_d : std_logic_vector (15 downto 0) := (others => '0');
    signal din_Q_d : std_logic_vector (15 downto 0) := (others => '0');
    
    signal dout_I_d : std_logic_vector (lengthPartSum - 1 downto 0) := (others => '0');
    signal dout_Q_d : std_logic_vector (lengthPartSum - 1 downto 0) := (others => '0');
--
    type MY_ROM is array (0 to tapLineLength - 1) of std_logic_vector(11 downto 0);
    signal S_I : MY_ROM := (0 =>  "011000011011", 8 =>   "001111001111", 16 =>  "001001110001", 24 =>  "111010100010", 32 =>  "100111100101", 40 =>  "111010100010", 48 =>  "001001110001", 56 =>  "001111001111",
                            1 =>  "111111001101", 9 =>   "001000010101", 17 =>  "000101110001", 25 =>  "101100111101", 33 =>  "000001111011", 41 =>  "110111001011", 49 =>  "010010101000", 57 =>  "111010000001",
                            2 =>  "000110001101", 10 =>  "000000001010", 18 =>  "110111000100", 26 =>  "101100000111", 34 =>  "001110010101", 42 =>  "110110100101", 50 =>  "111100011111", 58 =>  "101110000001",
                            3 =>  "001111001000", 11 =>  "101010101000", 19 =>  "101011011111", 27 =>  "001011101111", 35 =>  "110001101001", 43 =>  "001010111000", 51 =>  "001001001011", 59 =>  "001001010110",
                            4 =>  "000011010011", 12 =>  "000011110101", 20 =>  "001100110110", 28 =>  "111111100100", 36 =>  "111111100100", 44 =>  "001100110110", 52 =>  "000011110101", 60 =>  "000011010011",
                            5 =>  "001001010110", 13 =>  "001001001011", 21 =>  "001010111000", 29 =>  "110001101001", 37 =>  "001011101111", 45 =>  "101011011111", 53 =>  "101010101000", 61 =>  "001111001000",
                            6 =>  "101110000001", 14 =>  "111100011111", 22 =>  "110110100101", 30 =>  "001110010101", 38 =>  "101100000111", 46 =>  "110111000100", 54 =>  "000000001010", 62 =>  "000110001101",
                            7 =>  "111010000001", 15 =>  "010010101000", 23 =>  "110111001011", 31 =>  "000001111011", 39 =>  "101100111101", 47 =>  "000101110001", 55 =>  "001000010101", 63 =>  "111111001101");
              
    signal S_Q : MY_ROM := (0 =>  "000000000000", 8 =>   "111011111101", 16 =>  "110110001111", 24 =>  "101000011011", 32 =>  "000000000000", 40 =>  "010111100101", 48 =>  "001001110001", 56 =>  "000100000011",
                            1 =>  "101101001101", 9 =>   "000000101001", 17 =>  "001111010111", 25 =>  "111101011010", 33 =>  "110000110000", 41 =>  "000011011010", 49 =>  "000000101001", 57 =>  "010000100110",
                            2 =>  "101110101000", 10 =>  "101110000010", 18 =>  "000110001001", 26 =>  "111100110011", 34 =>  "101111011101", 42 =>  "110011010011", 50 =>  "100110111001", 58 =>  "001000101000",
                            3 =>  "001100111100", 11 =>  "111000100110", 19 =>  "001010001100", 27 =>  "110100011100", 35 =>  "101110000001", 43 =>  "111101110011", 51 =>  "000010010101", 59 =>  "001101101101",
                            4 =>  "000100010111", 12 =>  "110110110111", 20 =>  "001110011100", 28 =>  "001000011010", 36 =>  "110111100110", 44 =>  "110001100100", 52 =>  "001001001001", 60 =>  "111011101001",
                            5 =>  "110010010011", 13 =>  "111101101011", 21 =>  "000010001101", 29 =>  "010001111111", 37 =>  "001011100100", 45 =>  "110101110100", 53 =>  "000111011010", 61 =>  "110011000100",
                            6 =>  "110111011000", 14 =>  "011001000111", 22 =>  "001100101101", 30 =>  "010000100011", 38 =>  "000011001101", 46 =>  "111001110111", 54 =>  "010001111110", 62 =>  "010001011000",
                            7 =>  "101111011010", 15 =>  "111111010111", 23 =>  "111100100110", 31 =>  "001111010000", 39 =>  "000010100110", 47 =>  "110000101001", 55 =>  "111111010111", 63 =>  "010010110011");

--
    Component cell_filter is
        generic( lengthPartSum : integer );
        port (
            clk : in std_logic;
            dv_in : in std_logic;
            bitIn_I : in std_logic_vector(15 downto 0);
            bitIn_Q : in std_logic_vector(15 downto 0);
            coef_I : in std_logic_vector(11 downto 0);
            coef_Q : in std_logic_vector(11 downto 0);
            prevTapI : in std_logic_vector(lengthPartSum - 1 downto 0);
            nextTapI : out std_logic_vector(lengthPartSum - 1 downto 0);
            prevTapQ : in std_logic_vector(lengthPartSum - 1 downto 0);
            nextTapQ : out std_logic_vector(lengthPartSum - 1 downto 0));
    end component;
--
begin
-- Задержка входных сигналов для анализа максимальных тактовых частот
    Delay_din_I : process(clk) begin
        if rising_edge(clk) then
            din_I_d <= din_I;
        end if;
    end process;

    Delay_din_Q : process(clk) begin
        if rising_edge(clk) then
            din_Q_d <= din_Q;
        end if;
    end process;

-- Подключение ячеек фильтра
    Cell : for I in 1 to tapLineLength generate 
        Cells : cell_filter
            generic map( lengthPartSum => lengthPartSum)
            port map (
                clk => clk,
                dv_in => enable,
                bitIn_I => din_I_d,
                bitIn_Q => din_Q_d,
                coef_I => S_I(tapLineLength - I),
                coef_Q => S_Q(tapLineLength - I),
                prevTapI => resultI(I-1),
                nextTapI => resultI(I),
                prevTapQ => resultQ(I-1),
                nextTapQ => resultQ(I)); 
    end generate Cell;
    
-- Задержка выходных сигналов для анализа максимальных тактовых частот
    Delay_dout_I : process(clk) begin
        if rising_edge(clk) then
            dout_I_d <= resultI(tapLineLength);
        end if;
    end process;

    Delay_dout_Q : process(clk) begin
        if rising_edge(clk) then
            dout_Q_d <= resultQ(tapLineLength);
        end if;
    end process;
    
-- Выход фильтра
    dout_I <= dout_I_d;
    dout_Q <= dout_Q_d;
end Behavioral;
