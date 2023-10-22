library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_trena_fd is
  port
  (
    -- sinais de sistema
    clock              : in  std_logic;
    reset              : in  std_logic;

    -- sinais de controle e condição
    generate_pulse     : in  std_logic;
    reset_counters     : in  std_logic;
    store_measurement  : in  std_logic;
    send_measurement   : in  std_logic;
    pulse_sent         : out std_logic;
    measurement_sent   : out std_logic;

    -- sinais do toplevel
    echo          : in std_logic;
    medida0       : out std_logic_vector (6 downto 0);
    medida1       : out std_logic_vector (6 downto 0);
    medida2       : out std_logic_vector (6 downto 0);
    saida_serial  : out std_logic;
    trigger       : out std_logic
  );
end entity exp4_trena_fd;

architecture rtl of exp4_trena_fd is
  component hcsr04_interface is
    port
    (
      clock            : in  std_logic;
      reset            : in  std_logic;
      reset_counters   : in  std_logic;
      generate_pulse   : in  std_logic;
      echo             : in  std_logic;
      pulse_sent       : out std_logic;
      trigger          : out std_logic;
      digito0          : out std_logic_vector(3 downto 0); -- 3 digitos BCD
      digito1          : out std_logic_vector(3 downto 0);
      digito2          : out std_logic_vector(3 downto 0)
    );
  end component hcsr04_interface;
  signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);

  component measurement_sender is
    port
    (
      clock               : in  std_logic;
      reset               : in  std_logic;
      reset_counter       : in  std_logic;
      digito0             : in  std_logic_vector(3 downto 0);
      digito2             : in  std_logic_vector(3 downto 0);
      digito1             : in  std_logic_vector(3 downto 0);
      store_measurement   : in  std_logic;
      send_measurement    : in  std_logic;
      saida_serial        : out std_logic;
      measurement_sent    : out std_logic
    );
  end component measurement_sender;

  component register_d is 
    generic
    (
      WIDTH : natural := 8
    );
    port
    ( 
      clock    : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(WIDTH-1 downto 0);
      data_out : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  signal s_data_in, s_data_out : std_logic_vector(11 downto 0);

  component hexa7seg is
    port (
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component hexa7seg;

begin

  sensor_interface: hcsr04_interface
  port map
  (
      clock            => clock,
      reset            => reset,
      reset_counters   => reset_counters,
      generate_pulse   => generate_pulse,
      echo             => echo,
      pulse_sent       => pulse_sent,
      trigger          => trigger,
      digito0          => s_digito0,
      digito1          => s_digito1,
      digito2          => s_digito2
  );

  sender: measurement_sender
  port map
  (
      clock               => clock,
      reset               => reset,
      reset_counter       => reset_counters,
      digito0             => s_digito0,
      digito2             => s_digito2,
      digito1             => s_digito1,
      store_measurement   => store_measurement,
      send_measurement    => send_measurement,
      saida_serial        => saida_serial,
      measurement_sent    => measurement_sent
  );

  s_data_in <= s_digito2 & s_digito1 & s_digito0;
  data_register: register_d
  generic map
  (
    WIDTH => 12
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => store_measurement,
    data_in  => s_data_in,
    data_out => s_data_out
  );

  H0: hexa7seg
  port map
  (
    hexa => s_data_out(3 downto 0),
    sseg => medida0
  );

  H1: hexa7seg
  port map
  (
    hexa => s_data_out(7 downto 4),
    sseg => medida1
  );

  H2: hexa7seg
  port map
  (
    hexa => s_data_out(11 downto 8),
    sseg => medida2
  );

end architecture rtl;
