--! \file
--! \brief VHDL file for the top-level entity of a divisor module.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! \brief Top-level entity for the divisor module.
--! This entity interfaces with the system and handles data inputs and outputs, along with system and handshake signals.
entity divisor_top is
  port
  (
    -- system signals
    clock : in std_logic; --! Clock signal.
    reset : in std_logic; --! Reset signal.
    
    -- handshake signals
    valid : in  std_logic; --! Input validation signal.
    ready : out std_logic; --! Output ready signal.

    -- data inputs and outputs
    dividend  : in  std_logic_vector(15 downto 0); --! Input dividend.
    divisor   : in  std_logic_vector(15 downto 0); --! Input divisor.
    quotient  : out std_logic_vector(31 downto 0); --! Output quotient.
    remainder : out std_logic_vector(31 downto 0)  --! Output remainder.
  );
end entity divisor_top;

architecture structural of divisor_top is
  --! Component declarations for the datapath and control units.

  component divisor_dpath is
    port
    (
      -- system signals
      clock : in  std_logic;
      reset : in  std_logic;

      -- control inputs
      load             : in std_logic;
      shift_quotient   : in std_logic;
      set_quotient_bit : in std_logic;
      shift_divisor    : in std_logic;
      restore_sub      : in std_logic;
      write_remainder  : in std_logic;

      -- control outputs
      neg_remainder : out std_logic;
      finished      : out std_logic;
    
      -- data inputs and outputs
      dividend  : in  std_logic_vector(15 downto 0);
      divisor   : in  std_logic_vector(15 downto 0);
      quotient  : out std_logic_vector(31 downto 0);
      remainder : out std_logic_vector(31 downto 0)

    );
  end component divisor_dpath;

  component divisor_ctrl is
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
  end component divisor_ctrl;

  -- Signal declarations for interfacing between the datapath and control units.

  signal load : std_logic;
  signal shift_quotient : std_logic;
  signal set_quotient_bit : std_logic;
  signal shift_divisor : std_logic;
  signal restore_sub : std_logic;
  signal write_remainder : std_logic;
  signal neg_remainder : std_logic;
  signal finished : std_logic;
  
begin
  --! Instantiation of the datapath component.
  datapath: divisor_dpath
  port map
  (
    clock            => clock,
    reset            => reset,
    load             => load,
    shift_quotient   => shift_quotient,
    set_quotient_bit => set_quotient_bit,
    shift_divisor    => shift_divisor,
    restore_sub      => restore_sub,
    write_remainder  => write_remainder,
    neg_remainder    => neg_remainder,
    finished         => finished,
    dividend         => dividend,
    divisor          => divisor,
    quotient         => quotient,
    remainder        => remainder
  );
  
  --! Instantiation of the control unit component.
  control_unit: divisor_ctrl
  port map
  (
    clock            => clock,
    reset            => reset,
    valid            => valid,
    neg_remainder    => neg_remainder,
    finished         => finished,
    ready            => ready,
    load             => load,
    shift_quotient   => shift_quotient,
    set_quotient_bit => set_quotient_bit,
    shift_divisor    => shift_divisor,
    restore_sub      => restore_sub,
    write_remainder  => write_remainder
  );
  
end architecture structural;
