--! \file
--! \brief T Flip-Flop Entity Implementation
--! 
--! This file contains the implementation of a T flip-flop with enable and load functionality.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! \entity t_flip_flop
--! \brief T Flip-Flop Entity
--! 
--! The T flip-flop entity is a basic memory element that toggles its output on each clock cycle when enabled.
entity t_flip_flop is
  port
  (
    clock : in  std_logic; --! \brief Clock input.
    reset : in  std_logic; --! \brief Reset input.
    en    : in  std_logic; --! \brief Enable signal.
    q_in  : in  std_logic; --! \brief Parallel load input.
    load  : in  std_logic; --! \brief Load signal.
    q     : out std_logic  --! \brief Output of the flip-flop.
  );
end entity t_flip_flop;

--! \architecture behavioral
--! \brief Behavioral Architecture of T Flip-Flop
--! 
--! This architecture implements the logic for a T flip-flop with enable and load functionality.
architecture behavioral of t_flip_flop is

  -- Internal signal for storing the state of the flip-flop
  signal s_q : std_logic;

begin
  
  --! \process behavior
  --! \brief Behavior Process of T Flip-Flop
  --! 
  --! This process describes the behavior of the T flip-flop, including reset, load, and toggle functionality.
  behavior: process(clock, reset)
  begin
    if reset  = '1' then
      s_q <= '0'; -- Reset the flip-flop to '0'
    elsif rising_edge(clock) then
      if load = '1' then
        s_q <= q_in; -- Load the input value into the flip-flop
      else
        s_q <= s_q xor en; -- Toggle the flip-flop if enabled
      end if;
    end if;
  end process behavior;
  
  -- Output assignment
  q <= s_q;
  
end architecture behavioral;
