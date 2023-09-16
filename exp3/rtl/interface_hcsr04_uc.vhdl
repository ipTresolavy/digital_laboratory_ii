library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_uc is
  port (
    clock          : in std_logic;
    reset          : in std_logic;
    medir          : in std_logic;
    echo           : in std_logic;
    pulse_sent     : in std_logic;
    half_cm        : in std_logic;
    reset_counter  : out std_logic;
    generate_pulse : out std_logic;
    round_distance : out std_logic;
    pronto         : out std_logic;
    db_estado      : out std_logic_vector(3 downto 0) -- estado da UC
  );
end entity interface_hcsr04_uc;

architecture structural of interface_hcsr04_uc is

  type state_type is (idle, send_pulse, wait_echo_start, wait_echo_end, round, end_transmission);
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

  next_state_decode: process(state, medir, echo, pulse_sent, half_cm) is
  begin

    generate_pulse <= '0';
    pronto <= '0';
    reset_counter <= '0';
    round_distance <= '0';

    case state is
      when idle =>
        if medir = '1' then
          next_state <= send_pulse;
        else 
          next_state <= idle;
        end if;

      when send_pulse =>
        generate_pulse <= '1';
        reset_counter <= '1';
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
          next_state <= round;
        else
          next_state <= wait_echo_end;
        end if;

      when round =>
        if half_cm = '1' then
          round_distance <= '1';
        end if;
        next_state <= end_transmission;

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
                   "1111" when end_transmission,
                   "1110" when others;

end architecture structural;
