--! \file
--! \brief VHDL file for the top-level entity of a multiplier module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! \brief Top-level entity for the multiplier module.
--! This entity serves as the interface between the system and the multiplier module, handling data inputs and outputs, system signals, and handshake signals.
entity multiplier_top is
  port
  (
    -- system signals
    clock : in std_logic;  --! Clock signal.
    reset : in std_logic;  --! Reset signal.

    -- handshake signals
    valid : in  std_logic; --! Input validation signal.
    ready : out std_logic; --! Output ready signal.

    -- data inputs and outputs
    multiplicand : in  std_logic_vector(15 downto 0); --! Input multiplicand.
    multiplier   : in  std_logic_vector(15 downto 0); --! Input multiplier.
    product      : out std_logic_vector(31 downto 0)  --! Output product.
  );
end entity multiplier_top;

architecture structural of multiplier_top is
  -- Component declarations for the datapath and control units.

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

  -- Signal declarations for interfacing between the datapath and control units.
  signal finished : std_logic;
  signal load     : std_logic;
  signal shift_operands : std_logic;
  
begin
  --! Instantiation of the datapath component.
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
  
  --! Instantiation of the control unit component.
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
