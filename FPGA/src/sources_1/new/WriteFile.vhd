library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
LIBRARY std;
USE std.textio.all;

entity WriteFile is
    generic( numOfBits : natural;
             file_name : string);
    port( dv: in std_logic; -- сигнал индикации считывания
          sign : in std_logic; -- индикация знакового (1) и беззнакового (0) типов
          clk : in std_logic; -- сигнал тактирования
          DataIn : in std_logic_vector ( (numOfBits-1) downto 0) ); -- данные полученного в симуляции сигнала
end WriteFile;

architecture Behavioral of WriteFile is
    constant log_file_wr : string := file_name; --  адрес файла для записи
    file file_wr: TEXT open write_mode is log_file_wr; -- открытие файла в режиме записи
BEGIN
    write_data : process(clk)
        variable l_wr : line; -- записываемая в файл строчка
    begin
        if(rising_edge(clk)) then
            if dv = '1' then
                if sign='0' then
                    write (l_wr, CONV_INTEGER(UNSIGNED(DataIn))); -- записываем DataIn в строчку l_wr
                    writeline(file_wr, l_wr); -- записываем в файл строчку l_wr
                else
                    write (l_wr, CONV_INTEGER(SIGNED(DataIn))); -- записываем DataIn в строчку l_wr
                    writeline(file_wr, l_wr); -- записываем в файл строчку l_wr
                end if;
            end if;
        end if;
    end process;
end Behavioral;