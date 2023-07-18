library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_Receiver is
	Generic (W_IN : natural := 16;
		W_OUT  : natural := 16;
		TB_NUM : natural := 1);
--  Port ( );
end TB_Receiver;

architecture Behavioral of TB_Receiver is
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
	signal rfd : std_logic := '1';
	signal rst : std_logic := '0';
	-- Read-Write signal
	signal r_dv : std_logic := '0';
	signal w_dv : std_logic := '0';

	-- Receiver's signals
	signal din_i, din_q     : STD_LOGiC_VECTOR (W_IN - 1 downto 0) := (others => '0');
	signal dout_i, dout_q   : STD_LOGiC_VECTOR (W_OUT - 1 downto 0);
	signal enable, r_enable : STD_LOGiC := '0';
	signal reset            : STD_LOGiC := '0';

	-- Components
	Component Receiver is
		generic (W_IN : natural;
			W_OUT : natural);
		port ( clk : in std_logic;
			enable : in  std_logic;
			reset  : in  std_logic;
			din_i  : in  std_logic_vector (W_IN - 1 downto 0);
			din_q  : in  std_logic_vector (W_IN - 1 downto 0);
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
	Receiver_connect : Receiver
		generic map(W_IN => W_IN,
			W_OUT => W_OUT)
		port map ( clk => clk,
			enable => r_dv,
			reset  => reset,
			din_i  => din_i,
			din_q  => din_q,
			dout_i => dout_i,
			dout_q => dout_q,
			out_dv => w_dv);

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

	Write_output_datai : WriteFile
		generic map( numOfBits => W_OUT,
			file_name => "D:\NiR\WiFi\Signals\data_from_fpga_Receiver_i.dat" )
		port map( clk => clk,
			dv     => w_dv,
			sign   => sign,
			Datain => dout_i);

	Write_output_dataq : WriteFile
		generic map( numOfBits => W_OUT,
			file_name => "D:\NiR\WiFi\Signals\data_from_fpga_Receiver_q.dat" )
		port map( clk => clk,
			dv     => w_dv,
			sign   => sign,
			Datain => dout_q);

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
