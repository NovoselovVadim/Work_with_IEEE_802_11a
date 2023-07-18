library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Norm_cross_corr is
    Generic (W_IN : natural := 16;
        WINDOW : natural := 16;
        TB_NUM : natural := 1);
--    Port ( );
end TB_Norm_cross_corr;

architecture Behavioral of TB_Norm_cross_corr is

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
    -- Read-Write signal
    signal r_dv  : std_logic := '0';
    signal w_dv  : std_logic := '0';
    signal reset : std_logic := '0';

    -- Norm_cross_corr signals
    signal din_i            : STD_LOGiC_VECTOR (W_IN - 1 downto 0)  := (others => '0');
    signal din_q            : STD_LOGiC_VECTOR (W_IN - 1 downto 0)  := (others => '0');
    signal coef_energ       : std_logic_vector(2*W_IN - 1 downto 0) := "00000000110011111111000011001100";
    signal dout             : STD_LOGiC_VECTOR (W_IN - 1 downto 0);
    signal enable, r_enable : STD_LOGiC := '0';

    -- Components
    Component Norm_cross_corr is
        generic (W_IN : natural;
            WINDOW : natural);
        port ( clk : in std_logic;
            enable     : in  std_logic;
            coef_energ : in  std_logic_vector (2*W_IN - 1 downto 0);
            din_i      : in  std_logic_vector (W_IN - 1 downto 0);
            din_q      : in  std_logic_vector (W_IN - 1 downto 0);
            dv_out     : out std_logic;
            dout       : out std_logic_vector (W_IN - 1 downto 0));
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
    -- 
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
        end if;
    end process;

    -- Components connecting
    Norm_cross_corr_connect : Norm_cross_corr
        generic map(W_IN => W_IN,
            WINDOW => WINDOW)
        port map ( clk => clk,
            enable     => r_dv,
            coef_energ => coef_energ,
            din_i      => din_i,
            din_q      => din_q,
            dout       => dout,
            dv_out     => w_dv);

    Read_input_datai : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NiR\WiFi\Signals\WIFI2fpgaI.dat" )
        port map( data => din_i,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    Read_input_dataq : ReadFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NiR\WiFi\Signals\WIFI2fpgaQ.dat" )
        port map( data => din_q,
            dv  => r_dv,
            rst => reset,
            rfd => r_enable,
            clk => clk);

    Write_output_data : WriteFile
        generic map( numOfBits => W_IN,
            file_name => "D:\NiR\WiFi\Signals\Norm_cross_from_fpga.dat" )
        port map( clk => clk,
            dv     => w_dv,
            sign   => sign,
            Datain => dout);

    -- Signals generate
    clk_gen : process begin
        loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
    end process;

    enable_gen : process begin
        case(TB_NUM) is
            when 1 =>
                wait_clk(2);
--                loop
                enable <= '1';
--                    wait_clk(1);
--                    enable <= '0';
--                    wait_clk(6);
--                end loop;
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
