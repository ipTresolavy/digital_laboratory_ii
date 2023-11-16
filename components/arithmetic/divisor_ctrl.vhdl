--! \file divisor_ctrl.vhdl
--! \brief This file contains the definition of the divisor_ctrl entity and its architecture.
--! 
--! The divisor_ctrl entity is responsible for controlling the division process in a digital system.
--! It manages the division operations through various states and control signals.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! \class divisor_ctrl
--! \brief The divisor_ctrl entity represents a control unit for a division operation.
--!
--! This entity defines the input and output ports necessary for controlling the division process.
--! It includes ports for system signals, control inputs, and control outputs.

entity divisor_ctrl is
  port
  (
    --! \brief System clock input.
    clock : in std_logic;  

    --! \brief System reset input.
    reset : in std_logic;  

    --! \brief Input signal indicating if the current data is valid.
    valid         : in std_logic;

    --! \brief Input signal indicating if the remainder is negative.
    neg_remainder : in std_logic;

    --! \brief Input signal indicating if the division process is finished.
    finished      : in std_logic;
  
    --! \brief Output signal indicating if the controller is ready.
    ready            : out std_logic;

    --! \brief Output signal to load the data for division.
    load             : out std_logic;

    --! \brief Output signal to shift the quotient.
    shift_quotient   : out std_logic;

    --! \brief Output signal to set the current bit of the quotient.
    set_quotient_bit : out std_logic;

    --! \brief Output signal to shift the divisor.
    shift_divisor    : out std_logic;

    --! \brief Output signal to restore the subtraction.
    restore_sub      : out std_logic;

    --! \brief Output signal to write the remainder back.
    write_remainder  : out std_logic
  );
end entity divisor_ctrl;

architecture behavioral of divisor_ctrl is

  --! \enum state_type
  --! \brief Defines the possible states of the division control process.
  type state_type is (idle, subtracting, testing_remainder);

  --! \var state
  --! \brief Holds the current state of the division control process.
  signal state, next_state : state_type;

begin
  
  --! \process state_fetch
  --! \brief Responsible for updating the current state based on the next state and reset signal.
  --!
  --! This process triggers on the rising edge of the clock or a reset signal.
  --! It sets the current state to idle on reset or to the next state on the clock's rising edge.
  state_fetch: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process state_fetch;
  
  --! \process next_state_logic
  --! \brief Determines the next state of the division control process based on the current state and input signals.
  --!
  --! This process sets control outputs and transitions between states based on the inputs and current state.
  --! It handles the main logic of the division control including ready signal, loading, writing remainder, etc.
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
