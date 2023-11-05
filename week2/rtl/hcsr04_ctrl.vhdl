library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hcsr04_ctrl is
  port
  (
    -- sinais de sistema
    clock              : in std_logic;
    reset              : in std_logic;

    -- sinais de controle e condicao
    mensurar           : in  std_logic;
    echo               : in  std_logic;
    pulse_sent         : in  std_logic;
    timeout            : in  std_logic;
    generate_pulse     : out std_logic;
    reset_counters     : out std_logic;
    store_measurement  : out std_logic;
    watchdog_en        : out std_logic;
    reset_watchdog     : out std_logic;

    -- sinais do toplevel
    pronto             : out std_logic;
    db_estado          : out std_logic_vector(3 downto 0) -- estado da UC
  );
end entity hcsr04_ctrl;

architecture behavioral of hcsr04_ctrl is

  type state_type is (idle, send_pulse, wait_echo_start, wait_echo_end, store_value, end_transmission);
  signal state, next_state : state_type;

  signal s_pronto : std_logic;

begin

  sync_process: process (clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then 
      state <= next_state;
    end if;
  end process;

  next_state_decode: process(state, mensurar, echo, pulse_sent, timeout) is
  begin

    generate_pulse    <= '0';
    reset_counters    <= '0';
    store_measurement <= '0';
    watchdog_en       <= '0';
    reset_watchdog    <= '0';
    s_pronto          <= '0';

    case state is
      when idle =>
        if mensurar = '1' then
          next_state <= send_pulse;
        else 
          next_state <= idle;
        end if;

      when send_pulse =>
        generate_pulse <= '1';
        reset_counters <= '1';
        if pulse_sent = '1' then
          reset_watchdog <= '1';
          next_state <= wait_echo_start;
        else
          next_state <= send_pulse;
        end if;

      when wait_echo_start =>
        watchdog_en <= '1';
        if timeout = '1' then
          next_state <= send_pulse;
        elsif echo = '1' then
          reset_watchdog <= '1';
          next_state <= wait_echo_end;
        else
          next_state <= wait_echo_start;
        end if;

      when wait_echo_end =>
        watchdog_en <= '1';
        if timeout = '1' then
          next_state <= send_pulse;
        elsif echo = '0' then
          reset_watchdog <= '1';
          next_state <= store_value;
        else
          next_state <= wait_echo_end;
        end if;

      when store_value =>
        store_measurement <= '1';
        next_state <= end_transmission;

      when end_transmission =>
        s_pronto <= '1';
        next_state <= idle;

      when others =>
        next_state <= idle;

    end case;
  end process;

  pronto <= s_pronto;

  with state select
      db_estado <= "0000" when idle,
                   "0001" when send_pulse,
                   "0010" when wait_echo_start,
                   "0011" when wait_echo_end,
                   "0100" when store_value,
                   "1111" when end_transmission,
                   "1110" when others;

end architecture behavioral;
