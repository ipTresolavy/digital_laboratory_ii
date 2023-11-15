library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier_ctrl is
  port
  (
    -- system signals
    clock : in std_logic;
    reset : in std_logic;

    -- control inputs
    valid    : in std_logic;
    finished : in std_logic; 

    -- control outputs
    ready          : out std_logic;
    load           : out std_logic;
    shift_operands : out std_logic

  );
end entity multiplier_ctrl;

architecture behavioral of multiplier_ctrl is
  type state_type is (idle, multiplying);
  signal state, next_state : state_type;
  
begin
  
  fetch_next_state: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process fetch_next_state;
  
  next_state_logic: process(state, valid, finished)
  begin
    ready <= '0';
    load <= '0';
    shift_operands <= '0';

    case state is
      when idle =>
        ready <= '1';
        if valid = '1' then
          load <= '1';
          next_state <= multiplying;
        else
          next_state <= idle;
        end if;

      when multiplying =>
        shift_operands <= '1';
        if finished = '1' then
          next_state <= idle;
        else
          next_state <= multiplying;
        end if;

      when others =>
        next_state <= idle;

    end case;
    
  end process next_state_logic;
  
end architecture behavioral;
