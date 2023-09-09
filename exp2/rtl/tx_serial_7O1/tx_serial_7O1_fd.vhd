------------------------------------------------------------------
-- Arquivo   : tx_serial_7O1_fd.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
-- > implementa configuracao 7O1
-- > 
-- > bit de paridade calculada usando portas XOR (veja linha 76)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
--     19/09/2022  2.1     Edson Midorikawa  revisao (db_estado)
--     17/08/2023  3.0     Edson Midorikawa  revisao para 7O1
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity tx_serial_7O1_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        zera         : in  std_logic;
        conta        : in  std_logic;
        carrega      : in  std_logic;
        desloca      : in  std_logic;
        dados_ascii  : in  std_logic_vector(6 downto 0);
        saida_serial : out std_logic;
        fim          : out std_logic
    );
end entity;

architecture tx_serial_7O1_fd_arch of tx_serial_7O1_fd is
     
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
    
    signal s_dados, s_saida: std_logic_vector(10 downto 0);

begin

    s_dados(0)          <= '1';   -- repouso
    s_dados(1)          <= '0';   -- start bit
    s_dados(8 downto 2) <= dados_ascii;
    -- bit de paridade da transmissao impar (dados + paridade)
    s_dados(9)          <= not (dados_ascii(0) xor dados_ascii(1) 
                             xor dados_ascii(2) xor dados_ascii(3) 
                             xor dados_ascii(4) xor dados_ascii(5) 
                             xor dados_ascii(6));
    s_dados(10)         <= '1';   -- stop bit

    U1: deslocador_n 
        generic map (
            N => 11
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => '1', 
            dados          => s_dados, 
            saida          => s_saida
        );

    U2: contador_m 
        generic map (
            M => 12, 
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

    saida_serial <= s_saida(0);
    
end architecture;

