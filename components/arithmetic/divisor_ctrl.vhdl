library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity divisor_ctrl is
  port
  (
    -- system signals
    clock : in std_logic;  
    reset : in std_logic;  

    -- control inputs
    valid         : in std_logic;
    neg_remainder : in std_logic;
    finished      : in std_logic;
  
    -- control outputs
    ready            : out std_logic;
    load             : out std_logic;
    shift_quotient   : out std_logic;
    set_quotient_bit : out std_logic;
    shift_divisor    : out std_logic;
    restore_sub      : out std_logic;
    write_remainder  : out std_logic
  );
end entity divisor_ctrl;

architecture behavioral of divisor_ctrl is

  type state_type is (idle, subtracting, testing_remainder);
  signal state, next_state : state_type;

begin
  
  state_fetch: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process state_fetch;
  
  next_state_logic: process(state, valid, neg_remainder, finished)
  begin
    ready <= '0';
    load <= '0';
    write_remainder <= '0';
    shift_divisor <= '0';
    restore_sub <= '0';
    write_remainder <= '0';
    set_quotient_bit <= '0';
    shift_quotient <= '0';

    case state is
      when idle =>
        ready <= '1';
        if valid = '1' then
          load <= '1';
          next_state <= subtracting;
        else
          next_state <= idle;
        end if;

      when subtracting =>
        if finished = '0' then
          write_remainder <= '1';
          next_state <= testing_remainder;
        else
          next_state <= idle; 
        end if;

      when testing_remainder =>
        shift_divisor <= '1';
        shift_quotient <= '1';
        if neg_remainder = '1' then
          restore_sub <= '1';
          write_remainder <= '1';
          set_quotient_bit <= '0';
          next_state <= subtracting;
        else
          set_quotient_bit <= '1';
          next_state <= subtracting;
        end if;

      when others =>
        next_state <= idle;
    end case;
  end process next_state_logic;
end architecture behavioral;
