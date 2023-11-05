--! @file
--! @brief Floating Point Single Precision Adder Double Precision (fp_sp_adder_dp)
--! 
--! This file contains the VHDL description of a floating point single precision adder
--! with double precision support. It utilizes a sklansky adder component for its operations.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

--! @brief Entity for FP_SP_ADDER_DP
--! 
--! This entity represents a floating point single precision adder with double precision support.
--! It has two input operands (multiplicand and multiplier) and one output (result), all of which are 32-bit wide.
entity fp_sp_adder_dp is
  port
  (
    multiplicand : std_logic_vector(31 downto 0); --! < 32-bit multiplicand input
    multiplier   : std_logic_vector(31 downto 0); --! < 32-bit multiplier input
    result       : std_logic_vector(31 downto 0)  --! < 32-bit result output
  );
end entity fp_sp_adder_dp;

--! @brief Structural architecture of FP_SP_ADDER_DP
--! 
--! This architecture defines the internal structure and components used by the fp_sp_adder_dp entity.
architecture structural of fp_sp_adder_dp is
  
  --! @brief Sklansky Adder Component
  --! 
  --! This component represents a Sklansky adder, which is used for addition operations within the fp_sp_adder_dp.
  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16 --! < Width of the adder, default is 16
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0); --! < Input operand A
      b     : in  std_logic_vector(WIDTH-1 downto 0); --! < Input operand B
      c_in  : in  std_logic;                           --! < Carry input
      c_out : out std_logic;                           --! < Carry output
      s     : out std_logic_vector(WIDTH-1 downto 0)  --! < Sum output
    );
  end component sklansky_adder;

  -- Aliases for multiplicand and multiplier components
  alias multiplicand_sign     : std_logic is multiplicand(31);
  alias multiplicand_exponent : std_logic_vector(7 downto 0) is multiplicand(30 downto 23);
  alias multiplicand_fraction : std_logic_vector(22 downto 0) is multiplicand(22 downto 0);

  alias multiplier_sign     : std_logic is multiplier(31);
  alias multiplier_exponent : std_logic_vector(7 downto 0) is multiplier(30 downto 23);
  alias multiplier_fraction : std_logic_vector(22 downto 0) is multiplier(22 downto 0);

  -- Internal signals
  signal n_multiplier_exponent : std_logic_vector(7 downto 0);
  signal exponent_difference   : std_logic_vector(7 downto 0);

begin

  -- Inversion of multiplier exponent
  n_multiplier_exponent <= not multiplier_exponent;
  
  --! @brief Small ALU instantiation
  --! 
  --! This instance of sklansky_adder is used to compute the exponent difference.
  small_ALU: sklansky_adder
  generic map
  (
    WIDTH => 8 --! < Set the width of the adder to 8 for exponent operations
  )
  port map
  (
    a     => multiplicand_exponent,
    b     => n_multiplier_exponent,
    c_in  => '1',
    c_out => open,
    s     => exponent_difference
  );
  
end architecture structural;
