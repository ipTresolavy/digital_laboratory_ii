library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_top is
  port
  (
    -- system signals
    clock : in std_logic;  
    reset : in std_logic;

    -- handshake signals
    valid : in  std_logic;
    ready : out std_logic;

    -- data inputs and outputs
    multiplicand : in  std_logic_vector(15 downto 0);
    multiplier   : in  std_logic_vector(15 downto 0);
    product      : out std_logic_vector(31 downto 0)
  );
end entity multiplier_top;

architecture structural of multiplier_top is
  component multiplier_dpath is
    port
    (
      -- system signals
      clock : in  std_logic;
      reset : in  std_logic;

      -- control inputs
      load           : in  std_logic;
      shift_operands : in  std_logic;

      -- control outputs
      finished : out std_logic; 

      -- data inputs and outputs
      multiplicand : in  std_logic_vector(15 downto 0);
      multiplier   : in  std_logic_vector(15 downto 0);
      product      : out std_logic_vector(31 downto 0)

    );
  end component multiplier_dpath;

  component multiplier_ctrl is
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
  end component multiplier_ctrl;

  signal finished : std_logic;
  signal load     : std_logic;
  signal shift_operands : std_logic;
  
begin

  datapath: multiplier_dpath
  port map
  (
    clock          => clock,
    reset          => reset,
    load           => load, 
    shift_operands => shift_operands,
    finished       => finished,
    multiplicand   => multiplicand,
    multiplier     => multiplier,
    product        => product
  );
  
  control_unit: multiplier_ctrl
  port map
  (
    clock          => clock,
    reset          => reset,
    valid          => valid,
    finished       => finished,
    ready          => ready,
    load           => load,
    shift_operands => shift_operands
  );
  
end architecture structural;
