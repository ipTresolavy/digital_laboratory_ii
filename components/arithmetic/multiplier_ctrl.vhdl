--! \file
--! \brief VHDL file for the control unit of a multiplier module.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! \brief Control entity for a multiplier module.
--! Handles control logic for the multiplication process including receiving input validation and signaling when the multiplication is finished.
entity multiplier_ctrl is
  port
  (
    -- system signals
    clock : in std_logic; --! Clock signal.
    reset : in std_logic; --! Reset signal.

    -- control inputs
    valid    : in std_logic; --! Input validation signal.
    finished : in std_logic; --! Signal indicating the completion of multiplication.

    -- control outputs
    ready          : out std_logic; --! Signal to indicate the system is ready.
    load           : out std_logic; --! Signal to initiate loading of operands.
    shift_operands : out std_logic  --! Signal to shift the operands.
  );
end entity multiplier_ctrl;

--! \brief Behavioral architecture for the multiplier control entity.
architecture behavioral of multiplier_ctrl is
  --! States for the control state machine.
  type state_type is (idle, multiplying);
  signal state, next_state : state_type;
  
begin
  --! State transition process.
  fetch_next_state: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle; --! Reset to idle state.
    elsif rising_edge(clock) then
      state <= next_state; --! Transition to the next state.
    end if;
  end process fetch_next_state;
  
  --! Logic to determine the next state and control signal outputs.
  next_state_logic: process(state, valid, finished)
  begin
    ready <= '0';
    load <= '0';
    shift_operands <= '0';

    case state is
      when idle =>
        ready <= '1'; --! Indicate ready when in idle state.
        if valid = '1' then
          load <= '1'; --! Load operands if valid input is received.
          next_state <= multiplying; --! Transition to multiplying state.
        else
          next_state <= idle;
        end if;

      when multiplying =>
        shift_operands <= '1'; --! Shift operands during multiplication.
        if finished = '1' then
          next_state <= idle; --! Return to idle when multiplication is finished.
        else
          next_state <= multiplying;
        end if;

      when others =>
        next_state <= idle;

    end case;
    
  end process next_state_logic;
  
end architecture behavioral;
