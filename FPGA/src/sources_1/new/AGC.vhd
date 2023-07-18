library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AGC is
    Generic (W_IN : natural;
        W_OUT : natural);
    Port ( clk : in std_logic;
        enable     : in std_logic;
        reset      : in std_logic;
        din_i      : in std_logic_vector (W_IN - 1 downto 0);
        din_q      : in std_logic_vector (W_IN - 1 downto 0);
        start_pckt : in std_logic_vector;
        out_dv : out std_logic;
        dout_i : out std_logic_vector (W_OUT - 1 downto 0);
        dout_q : out std_logic_vector (W_OUT - 1 downto 0));
end AGC;

architecture Behavioral of AGC is

begin


end Behavioral;
