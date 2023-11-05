library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_hcsr04_ctrl is
end entity tb_hcsr04_ctrl;

architecture sim of tb_hcsr04_ctrl is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal mensurar         : std_logic := '0';
  signal echo             : std_logic := '0';
  signal pulse_sent       : std_logic := '0';
  signal timeout          : std_logic := '0';
  signal generate_pulse   : std_logic;
  signal reset_counters   : std_logic;
  signal store_measurement: std_logic;
  signal watchdog_en      : std_logic;
  signal reset_watchdog   : std_logic;
  signal pronto           : std_logic;
  signal db_estado        : std_logic_vector(3 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)

  component hcsr04_ctrl is
    port
    (
      clock              : in std_logic;
      reset              : in std_logic;
      mensurar           : in std_logic;
      echo               : in std_logic;
      pulse_sent         : in std_logic;
      timeout            : in std_logic;
      generate_pulse     : out std_logic;
      reset_counters     : out std_logic;
      store_measurement  : out std_logic;
      watchdog_en        : out std_logic;
      reset_watchdog     : out std_logic;
      pronto             : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0)
    );
  end component hcsr04_ctrl;

  type test_array_type is record
      id    : natural; 
      duration : integer;     
  end record;

  type test_array is array (natural range <>) of test_array_type;
  constant test_array_inst : test_array :=
      ( 
        ( 1,  294),   --   5cm ( 294us)
        ( 2,  353),    --   6cm ( 353us)
        ( 3, 5882),  -- 100cm (5882us)
        ( 4, 5882),  -- 100cm (5882us)
        ( 5,  882),  --  15cm ( 882us)
        ( 6,  882),  --  15cm ( 882us)
        ( 7, 5882),  -- 100cm (5882us)
        ( 8,  588),   --  10cm ( 588us)
        -- inserir aqui outros posicoes de teste (inserir "," na linha anterior)
        ( 9,  1088), -- cm 
        ( 10, 5000), -- cm 
        ( 11, 2500)  --  m 
      );

  signal pulse_width: time := 1 us;

begin
  uut_hcsr04_ctrl: hcsr04_ctrl
  port map
  (
    clock              => clock,
    reset              => reset,
    mensurar           => mensurar,
    echo               => echo,
    pulse_sent         => pulse_sent,
    timeout            => timeout,
    generate_pulse     => generate_pulse,
    reset_counters     => reset_counters,
    store_measurement  => store_measurement,
    watchdog_en        => watchdog_en,
    reset_watchdog     => reset_watchdog,
    pronto             => pronto,
    db_estado          => db_estado
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    -- Wait for a few clock cycles
    wait for clockPeriod * 5;

    -- Initialize variables
    mensurar          <= '0';
    echo              <= '0';
    pulse_sent        <= '0';
    timeout           <= '0';

    for i in test_array_inst'range  loop
      wait until falling_edge(clock);

      -- Start a measurement
      mensurar <= '1';

      wait until generate_pulse = '1';
      mensurar <= '0';
      assert reset_counters = '1' report "reset_counters /= 1; " & integer'image(test_array_inst(i).id) severity failure;
      wait for 10 us;
      pulse_sent <= '1';
      wait until generate_pulse = '0';
      pulse_sent <= '0';
      assert reset_counters = '0' report "reset_counters /= 0; " & integer'image(test_array_inst(i).id)severity failure;

      wait for clockPeriod * i;
      echo <= '1';
      wait for test_array_inst(i).duration * 1 us;
      echo <= '0';
      
      wait until rising_edge(store_measurement);
      wait until falling_edge(store_measurement);
      wait until falling_edge(clock);
      assert pronto = '1' report "pronto /= '1'; " & integer'image(test_array_inst(i).id) severity failure;

      wait until falling_edge(clock);
      assert pronto = '0' report "pronto /= '0'; " & integer'image(test_array_inst(i).id) severity failure;
      assert db_estado = "0000" report "db_estado /= '0000'; " & integer'image(test_array_inst(i).id) severity failure;
      
    end loop;
    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
