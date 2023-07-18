library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
LIBRARY std;
USE std.textio.all;

entity WriteFile is
    generic( numOfBits : natural;
             file_name : string);
    port( dv: in std_logic; -- ������ ��������� ����������
          sign : in std_logic; -- ��������� ��������� (1) � ������������ (0) �����
          clk : in std_logic; -- ������ ������������
          DataIn : in std_logic_vector ( (numOfBits-1) downto 0) ); -- ������ ����������� � ��������� �������
end WriteFile;

architecture Behavioral of WriteFile is
    constant log_file_wr : string := file_name; --  ����� ����� ��� ������
    file file_wr: TEXT open write_mode is log_file_wr; -- �������� ����� � ������ ������
BEGIN
    write_data : process(clk)
        variable l_wr : line; -- ������������ � ���� �������
    begin
        if(rising_edge(clk)) then
            if dv = '1' then
                if sign='0' then
                    write (l_wr, CONV_INTEGER(UNSIGNED(DataIn))); -- ���������� DataIn � ������� l_wr
                    writeline(file_wr, l_wr); -- ���������� � ���� ������� l_wr
                else
                    write (l_wr, CONV_INTEGER(SIGNED(DataIn))); -- ���������� DataIn � ������� l_wr
                    writeline(file_wr, l_wr); -- ���������� � ���� ������� l_wr
                end if;
            end if;
        end if;
    end process;
end Behavioral;