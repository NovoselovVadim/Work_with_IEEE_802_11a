library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_LTS is
    Generic (numOfBits : integer := 32;
             lengthPartSum : integer := 32;
             tapLineLength : integer := 64);
--  Port ( );
end TB_LTS;

architecture Behavioral of TB_LTS is
-- Clock signals
    signal clk : STD_LOGIC;
    signal clk_period : time := 10 ns;
-- Filter signals
    signal din_I : STD_LOGIC_VECTOR (15 downto 0);
    signal din_Q : STD_LOGIC_VECTOR (15 downto 0);
    signal dout_I : STD_LOGIC_VECTOR (lengthPartSum - 1 downto 0);
    signal dout_Q : STD_LOGIC_VECTOR (lengthPartSum - 1 downto 0);
    signal enable : STD_LOGIC := '1';
-- Write signals
    signal sign : std_logic := '1';
-- Read signals
    signal rst : std_logic := '0';
    signal rfd : std_logic := '1';
-- Read-Write signal
    signal dv : std_logic := '0';                                  
--
    Component LTS_filter
        Generic (tapLineLength : integer := tapLineLength;
                 lengthPartSum : integer := lengthPartSum);
        Port ( clk : in std_logic;
               enable : in std_logic;
               din_I : in std_logic_vector (15 downto 0);
               din_Q : in std_logic_vector (15 downto 0);
               dout_I : out std_logic_vector (lengthPartSum - 1 downto 0);
               dout_Q : out std_logic_vector (lengthPartSum - 1 downto 0));
    end component;
--
    Component ReadFile
        generic( numOfBits : integer;
                 file_name : string);
        port( data : out std_logic_vector ((numOfBits-1) downto 0);
              dv: out std_logic;
              rst : in std_logic;
              rfd : in std_logic;
              clk : in std_logic );
    end component;
-- 
    Component WriteFile
        generic( numOfBits : integer;
                 file_name : string);
        port( clk,dv,sign : in std_logic;
              DataIn : in std_logic_vector ((numOfBits-1) downto 0) );
    end component;
--
begin
    LTS_filter_connect : LTS_filter
        Generic map (tapLineLength => tapLineLength,
                     lengthPartSum => lengthPartSum)
        Port map ( clk => clk,
                   enable => enable,
                   din_I => din_I,
                   din_Q => din_Q,
                   dout_I => dout_I,
                   dout_Q => dout_Q);
--
    Read_input_dataI: ReadFile
        generic map( numOfBits => 16,
                     file_name => "D:\NIR\WIFI\Signals\data2fpgaI.dat" )
        port map( data => din_I,
                  dv => dv,
                  rst => rst,
                  rfd => rfd,
                  clk => clk);   
              
    Read_input_dataQ: ReadFile
        generic map( numOfBits => 16,
                     file_name => "D:\NIR\WIFI\Signals\data2fpgaQ.dat" )
        port map( data => din_Q,
                  dv => dv,
                  rst => rst,
                  rfd => rfd,
                  clk => clk); 
--
    Write_output_dataI : WriteFile
        generic map( numOfBits => numOfBits,
                     file_name => "D:\NIR\WIFI\Signals\data_from_fpga_LTS_I.dat" )
        port map( clk => clk,
                  dv => dv,
                  sign => sign,
                  DataIn => dout_I);  

    Write_output_dataQ : WriteFile
        generic map( numOfBits => numOfBits,
                     file_name => "D:\NIR\WIFI\Signals\data_from_fpga_LTS_Q.dat" )
        port map( clk => clk,
                  dv => dv,
                  sign => sign,
                  DataIn => dout_Q);           
--
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
    rst_gen : process begin
        rst <= '0';
        wait for clk_period/2;
        rst <= '1';
        wait for clk_period/2;
        rst <= '0';
        wait;
    end process;
--
end Behavioral;
