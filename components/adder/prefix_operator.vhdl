library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prefix_operator is
  port
  (
    g_i : in  std_logic;
    g_j : in  std_logic;
    p_i : in  std_logic;
    p_j : in  std_logic;
    g   : out std_logic;
    p   : out std_logic
  );
end entity prefix_operator;

architecture dataflow of prefix_operator  is
begin

  g <= g_i or (p_i and g_j);
  p <= p_i and p_j;
  
end architecture dataflow;
