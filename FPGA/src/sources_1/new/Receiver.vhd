library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Receiver is
    Generic (W_IN : natural := 16;
        W_OUT : natural := 16;
        Treshold : natural := 6);
    Port ( clk : in std_logic;
        enable : in  std_logic;
        reset  : in  std_logic;
        din_i  : in  std_logic_vector (W_IN - 1 downto 0);
        din_q  : in  std_logic_vector (W_IN - 1 downto 0);
        out_dv : out std_logic;
        dout_i : out std_logic_vector (W_OUT - 1 downto 0);
        dout_q : out std_logic_vector (W_OUT - 1 downto 0));
end Receiver;

architecture Behavioral of Receiver is
    -- Signals
    signal start_pckt : std_logic_vector := "0";

    -- Components
    Component Detector is
        generic (W_IN : natural;
            Treshold : natural);
        port ( clk : in std_logic;
            enable     : in std_logic;
            din_i      : in std_logic_vector (W_IN - 1 downto 0);
            din_q      : in std_logic_vector (W_IN - 1 downto 0);
            start_pckt : out std_logic_vector);
    end component;

--    Component AGC is
--        generic (W_IN : natural;
--            W_OUT : natural);
--        port ( clk : in std_logic;
--            enable     : in std_logic;
--            reset      : in std_logic;
--            din_i      : in std_logic_vector (W_IN - 1 downto 0);
--            din_q      : in std_logic_vector (W_IN - 1 downto 0);
--            start_pckt : in std_logic_vector;
--            out_dv : out std_logic;
--            dout_i : out std_logic_vector (W_OUT - 1 downto 0);
--            dout_q : out std_logic_vector (W_OUT - 1 downto 0));
--    end component;

--    Component CoarseCFO is
--        generic (W_IN : natural;
--            W_OUT : natural);
--        port ( clk : in std_logic;
--            enable     : in  std_logic;
--            din_i      : in  std_logic_vector (W_IN - 1 downto 0);
--            din_q      : in  std_logic_vector (W_IN - 1 downto 0);
--            start_pckt : in  std_logic_vector;
--            out_dv     : out std_logic;
--            dout_i     : out std_logic_vector (W_OUT - 1 downto 0);
--            dout_q     : out std_logic_vector (W_OUT - 1 downto 0));
--    end component;

--    Component FineCFO is
--        generic (W_IN : natural;
--            W_OUT : natural);
--        port ( clk : in std_logic;
--            enable     : in std_logic;
--            din_i      : in std_logic_vector (W_IN - 1 downto 0);
--            din_q      : in std_logic_vector (W_IN - 1 downto 0);
--            start_pckt : in std_logic_vector;
--            out_dv : out std_logic;
--            dout_i : out std_logic_vector (W_OUT - 1 downto 0);
--            dout_q : out std_logic_vector (W_OUT - 1 downto 0));
--    end component;

begin

    -- Components connecting
    Detector_connect : Detector
        generic map(W_IN => W_IN,
            Treshold => Treshold )
        port map ( clk        => clk,
            enable     => enable,
            din_i      => din_i,
            din_q      => din_q,
            start_pckt => start_pckt);

    --AGC_connect : AGC 
    --    generic map(W_IN => W_IN,
    --        W_OUT => W_OUT )
    --    port map ( clk => clk,
    --        enable     => r_dv,
    --        reset      => reset,
    --        din_i      => r_din_i,
    --        din_q      => r_din_q,
    --        start_pckt => start_pckt,
    --        out_dv     => out_dv,
    --        dout_i     => dout_i,
    --        dout_q     => dout_q);

    --CoarseCFO_connect : CoarseCFO
    --    generic map(W_IN => W_IN,
    --        W_OUT => W_OUT )
    --    port map ( clk => clk,
    --        enable     => r_dv,
    --        din_i      => r_din_i,
    --        din_q      => r_din_q,
    --        start_pckt => start_pckt,
    --        out_dv     => out_dv,
    --        dout_i     => dout_i,
    --        dout_q     => dout_q);

    --FineCFO_connect : FineCFO
    --    generic map(W_IN => W_IN,
    --        W_OUT => W_OUT )
    --    port map ( clk => clk,
    --        enable     => r_dv,
    --        din_i      => r_din_i,
    --        din_q      => r_din_q,
    --        start_pckt => start_pckt,
    --        out_dv     => out_dv,
    --        dout_i     => dout_i,
    --        dout_q     => dout_q);

end Behavioral;
