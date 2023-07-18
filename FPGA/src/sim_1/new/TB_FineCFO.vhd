library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FineCFO is
    Generic (W_IN : natural := 16;
        W_OUT : natural := 16;
        TB_NUM     : natural := 1);
--  Port ( );
end TB_FineCFO;

architecture Behavioral of TB_FineCFO is
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

    -- Read signals
    signal rfd   : std_logic := '1';
    signal rst   : std_logic := '0';
    signal r_dv  : std_logic := '0';
    signal reset : STD_LOGiC := '0';

    -- FineCFO signals
    signal din_i, r_din_i, din_q, r_din_q : STD_LOGiC_VECTOR (W_IN - 1 downto 0) := (others => '0');
    signal dout_i, dout_q                 : STD_LOGiC_VECTOR (W_OUT - 1 downto 0);
    signal enable, r_enable               : STD_LOGiC := '0';
    signal start_pckt                     : STD_LOGiC_VECTOR := "0";
    signal out_dv                         : STD_LOGiC := '0';

    -- Components
    Component FineCFO is
        generic (W_IN : natural;
            W_OUT : natural);
        port ( clk : in std_logic;
            enable     : in std_logic;
            din_i      : in std_logic_vector (W_IN - 1 downto 0);
            din_q      : in std_logic_vector (W_IN - 1 downto 0);
            start_pckt : in std_logic_vector;
            out_dv : out std_logic;
            dout_i : out std_logic_vector (W_OUT - 1 downto 0);
            dout_q : out std_logic_vector (W_OUT - 1 downto 0));
    end component;

    Component ReadFile
        generic( numOfBits : natural;
            file_name : string);
        port( data : out std_logic_vector ((numOfBits-1) downto 0);
            dv  : out std_logic;
            rst : in  std_logic;
            rfd : in  std_logic;
            clk : in  std_logic );
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
    FineCFO_connect : FineCFO
        generic map(W_IN => W_IN,
            W_OUT => W_OUT )
        port map ( clk => clk,
            enable     => r_dv,
            din_i      => r_din_i,
            din_q      => r_din_q,
            start_pckt => start_pckt,
            out_dv     => out_dv,
            dout_i     => dout_i,
            dout_q     => dout_q);

    Read_input_datai : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NIR\WIFI\Signals\data2fpgaI.dat" )
        port map( data => din_i,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    Read_input_dataq : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NIR\WIFI\Signals\data2fpgaQ.dat" )
        port map( data => din_q,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    Read_input_start_pckt : ReadFile
        generic map( numOfBits => 1,
            file_name => "D:\NIR\WIFI\Signals\PacketStart.dat" )
        port map( data => start_pckt,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    -- Signals generate
    clk_gen : process begin
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

    enable_gen : process begin
        case(TB_NUM) is
            when 1 =>
                wait_clk(2);
                loop
                    enable <= '1';
                    wait_clk(16);
                    enable <= '0';
                    wait_clk(1);
                end loop ;
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
