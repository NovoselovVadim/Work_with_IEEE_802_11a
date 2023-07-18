library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
LIBRARY std;
USE std.textio.all;

entity ReadFile is
    generic( numOfBits : natural;
             file_name : string);
    port( data : out std_logic_vector ((numOfBits-1) downto 0):= "0000000000000000"; -- входные данные
          dv: out std_logic := '0'; -- сигнал индикации считывания
          rst : in std_logic; -- сигнал сброса
          rfd : in std_logic; -- сигнал разрешения чтения
          clk : in std_logic ); -- сигнал тактирования
end ReadFile;
--
ARCHITECTURE a OF ReadFile IS
    constant log_file_rd : string := file_name; -- адрес файла для считывания
    file file_rd: TEXT open read_mode is log_file_rd; -- открытие файла в режиме чтения
BEGIN
    read_data: process(clk,rst)
        variable s: integer; -- данные строчки
        variable l_rd : line; -- считываемая из файла строчка
    begin
        if (rst = '1') then
            data <= (others => '0');
            dv <= '0';
        elsif(rising_edge(clk)) then
            if rfd='1' then

                readline(file_rd, l_rd); -- из файла считываем строчку в l_rd
                read (l_rd, s); -- из строчки l_rd записываем данные в s
                data <= CONV_STD_LOGIC_VECTOR(s,numOfBits);
                dv <= '1';
            else
                dv <= '0';
            end if;
        end if;
    end process;
END ARCHITECTURE a;