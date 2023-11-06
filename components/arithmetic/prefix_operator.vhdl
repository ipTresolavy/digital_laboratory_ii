--! \file
--! \brief Prefix Operator Entity Implementation
--! 
--! This file contains the implementation of a prefix operator used in parallel prefix adders.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! \entity prefix_operator
--! \brief Prefix Operator Entity
--! 
--! The prefix operator is a fundamental component in parallel prefix adders, used to generate propagate and generate signals.
entity prefix_operator is
  port
  (
    g_i : in  std_logic; --! \brief Generate input from operand i.
    g_j : in  std_logic; --! \brief Generate input from operand j.
    p_i : in  std_logic; --! \brief Propagate input from operand i.
    p_j : in  std_logic; --! \brief Propagate input from operand j.
    g   : out std_logic; --! \brief Generate output.
    p   : out std_logic  --! \brief Propagate output.
  );
end entity prefix_operator;

--! \architecture dataflow
--! \brief Dataflow Architecture of Prefix Operator
--! 
--! This architecture implements the logic for a prefix operator using a dataflow model.
architecture dataflow of prefix_operator  is
begin

  -- Generate signal logic
  g <= g_i or (p_i and g_j);
  
  -- Propagate signal logic
  p <= p_i and p_j;
  
end architecture dataflow;
