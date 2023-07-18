library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
LIBRARY std;
USE std.textio.all;

entity ReadFile is
    generic( numOfBits : natural;
             file_name : string);
    port( data : out std_logic_vector ((numOfBits-1) downto 0):= "0000000000000000"; -- ������� ������
          dv: out std_logic := '0'; -- ������ ��������� ����������
          rst : in std_logic; -- ������ ������
          rfd : in std_logic; -- ������ ���������� ������
          clk : in std_logic ); -- ������ ������������
end ReadFile;
--
ARCHITECTURE a OF ReadFile IS
    constant log_file_rd : string := file_name; -- ����� ����� ��� ����������
    file file_rd: TEXT open read_mode is log_file_rd; -- �������� ����� � ������ ������
BEGIN
    read_data: process(clk,rst)
        variable s: integer; -- ������ �������
        variable l_rd : line; -- ����������� �� ����� �������
    begin
        if (rst = '1') then
            data <= (others => '0');
            dv <= '0';
        elsif(rising_edge(clk)) then
            if rfd='1' then

                readline(file_rd, l_rd); -- �� ����� ��������� ������� � l_rd
                read (l_rd, s); -- �� ������� l_rd ���������� ������ � s
                data <= CONV_STD_LOGIC_VECTOR(s,numOfBits);
                dv <= '1';
            else
                dv <= '0';
            end if;
        end if;
    end process;
END ARCHITECTURE a;