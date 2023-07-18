library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity TB_Detector is
    Generic (W_IN : natural := 16;
        Treshold : natural := 19661;
        TB_NUM   : natural := 1);
--  Port ( );
end TB_Detector;

architecture Behavioral of TB_Detector is
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

    -- Write signals
    signal sign : std_logic := '1';
    -- Read signals
    signal rfd   : std_logic := '1';
    signal rst   : std_logic := '0';
    signal r_dv  : std_logic := '0';
    signal reset : std_logic := '0';

    -- Detector's signals
    signal din_i, din_q     : STD_LOGiC_VECTOR (W_IN - 1 downto 0) := (others => '0');
    signal enable, r_enable : STD_LOGiC                            := '0';
    signal start_pckt       : STD_LOGiC                            := '0';

    signal start_pckt_x : std_logic_vector(1 downto 0) := (others => '0');
    signal dv_out : std_logic_vector (97 downto 0) := (others => '0');

    -- Components
    Component Detector is
        generic (W_IN : natural;
            Treshold : natural);
        port ( clk : in std_logic;
            enable     : in  std_logic;
            din_i      : in  std_logic_vector (W_IN - 1 downto 0);
            din_q      : in  std_logic_vector (W_IN - 1 downto 0);
            start_pckt : out std_logic);
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

    Component WriteFile
        generic( numOfBits : natural;
            file_name : string);
        port( clk,dv,sign : in std_logic;
            Datain : in std_logic_vector ((numOfBits-1) downto 0) );
    end component;

begin

    process(clk) begin
        if rising_edge(clk) then
            r_enable <= enable;
            dv_out <= r_dv & dv_out(97 downto 1);
        end if;
    end process;

    -- Components connecting
    Detector_connect : Detector
        generic map(W_IN => W_IN,
            Treshold => Treshold )
        port map ( clk => clk,
            enable     => r_dv,
            din_i      => din_i,
            din_q      => din_q,
            start_pckt => start_pckt);

    Read_input_datai : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NIR\WIFI\Signals\WIFI2fpgaI.dat" )
        port map( data => din_i,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    Read_input_dataq : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NIR\WIFI\Signals\WIFI2fpgaQ.dat" )
        port map( data => din_q,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    start_pckt_x <= '0' & start_pckt;

    Write_output_data : WriteFile
        generic map( numOfBits => 2,
            file_name => "D:\NiR\WiFi\Signals\Start_pckt_from_fpga.dat" )
        port map( clk => clk,
            dv     => dv_out(0),
            sign   => sign,
            Datain => start_pckt_x);

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
