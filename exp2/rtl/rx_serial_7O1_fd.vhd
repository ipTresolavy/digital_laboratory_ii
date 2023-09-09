library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    port (
        reset          : in  std_logic;
        clock          : in  std_logic;
        zera           : in  std_logic;
        conta          : in  std_logic;
        desloca        : in  std_logic;
        entrada_serial : in  std_logic;
        dados_ascii    : out std_logic_vector(6 downto 0);
        paridade       : out std_logic;
        start_bit      : out std_logic;
        stop_bit       : out std_logic;
        fim            : out std_logic
    );
end entity;

architecture rx_serial_7O1_fd_arch of rx_serial_7O1_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector(N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component;
    
    signal s_saida : std_logic_vector(8 downto 0);

begin

    dados_ascii <= s_saida(6 downto 0);
    paridade    <= s_saida(7);
    stop_bit    <= s_saida(8);
    start_bit   <= entrada_serial;

    U1: deslocador_n 
        generic map (
            N => 9
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => '0', 
            desloca        => desloca, 
            entrada_serial => entrada_serial, 
            dados          => "000000000", 
            saida          => s_saida
        );

    U2: contador_m 
        generic map (
            M => 11, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim, 
            meio  => open
        );

end architecture;
