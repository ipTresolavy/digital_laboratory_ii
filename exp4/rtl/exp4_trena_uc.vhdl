library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_trena_uc is
  port
  (
    -- sinais de sistema
    clock              : in std_logic;
    reset              : in std_logic;

    -- sinais de controle e condição
    mensurar           : in  std_logic;
    echo               : in  std_logic;
    pulse_sent         : in  std_logic;
    measurement_sent   : in  std_logic;
    generate_pulse     : out std_logic;
    reset_counters     : out std_logic;
    store_measurement  : out std_logic;
    send_measurement   : out std_logic;

    -- sinais do toplevel
    pronto             : out std_logic;
    db_estado          : out std_logic_vector(3 downto 0) -- estado da UC
  );
end entity exp4_trena_uc;

architecture behavioral of exp4_trena_uc is

  type state_type is (idle, send_pulse, wait_echo_start, wait_echo_end, store_value, send_value, end_transmission);
  signal state, next_state : state_type;

begin

  sync_process: process (clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then 
      state <= next_state;
    end if;
  end process;

  next_state_decode: process(state, mensurar, echo, pulse_sent, measurement_sent) is
  begin

    generate_pulse    <= '0';
    reset_counters    <= '0';
    store_measurement <= '0';
    send_measurement  <= '0';
    pronto            <= '0';

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
          next_state <= wait_echo_start;
        else
          next_state <= send_pulse;
        end if;

      when wait_echo_start =>
        if echo = '1' then
          next_state <= wait_echo_end;
        else
          next_state <= wait_echo_start;
        end if;

      when wait_echo_end =>
        if echo = '0' then
          next_state <= store_value;
        else
          next_state <= wait_echo_end;
        end if;

      when store_value =>
        store_measurement <= '1';
        next_state <= send_value;

      when send_value =>
        send_measurement <= '1';
        if measurement_sent = '1' then
          next_state <= end_transmission;
        else
          next_state <= send_value;
        end if;

      when end_transmission =>
        pronto <= '1';
        next_state <= idle;

      when others =>
        next_state <= idle;

    end case;
  end process;

  with state select
      db_estado <= "0000" when idle,
                   "0001" when send_pulse,
                   "0010" when wait_echo_start,
                   "0011" when wait_echo_end,
                   "0100" when store_value,
                   "0101" when send_value,
                   "1111" when end_transmission,
                   "1110" when others;

end architecture behavioral;
