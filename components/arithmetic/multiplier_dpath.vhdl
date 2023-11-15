library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity multiplier_dpath is
  port
  (
    -- system signals
    clock : in  std_logic;
    reset : in  std_logic;

    -- data inputs and outputs
    multiplicand : in  std_logic_vector(15 downto 0);
    multiplier   : in  std_logic_vector(15 downto 0);
    product      : out std_logic_vector(31 downto 0)
  );
end entity multiplier_dpath;

architecture structural of multiplier_dpath is
  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16 --! Width of the operands.
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0); --! First operand.
      b     : in  std_logic_vector(WIDTH-1 downto 0); --! Second operand.
      c_in  : in  std_logic; --! Carry input.
      c_out : out std_logic; --! Carry output.
      s     : out std_logic_vector(WIDTH-1 downto 0) --! Sum output.
    );
  end component sklansky_adder;

  component register_d is
    generic
    (
      WIDTH : natural := 8
    );
    port
    (
      clock         : in  std_logic;
      reset         : in  std_logic;
      enable        : in  std_logic;
      data_in       : in  std_logic_vector(WIDTH-1 downto 0);
      data_out      : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component register_d;

  signal r_multiplicand : std_logic_vector(15 downto 0);
  
begin

  multiplicand_reg: register_d
  generic map
  (
    WIDTH => 15
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => load,
    data_in  => multiplicand,
    data_out => r_multiplicand
  );

  
  
end architecture structural;
