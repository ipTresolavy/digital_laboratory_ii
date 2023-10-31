library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity fp_sp_adder_dp is
  port
  (
    multiplicand : std_logic_vector(31 downto 0);
    multiplier   : std_logic_vector(31 downto 0);
    result       : std_logic_vector(31 downto 0)
  );
end entity fp_sp_adder_dp;

architecture structural of fp_sp_adder_dp is
  
  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0);
      b     : in  std_logic_vector(WIDTH-1 downto 0);
      c_in  : in  std_logic;
      c_out : out std_logic;
      s     : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component sklansky_adder;

  alias multiplicand_sign     : std_logic is multiplicand(31);
  alias multiplicand_exponent : std_logic_vector(7 downto 0) is multiplicand(30 downto 23);
  alias multiplicand_fraction : std_logic_vector(22 downto 0) is multiplicand(22 downto 0);

  alias multiplier_sign     : std_logic is multiplier(31);
  alias multiplier_exponent : std_logic_vector(7 downto 0) is multiplier(30 downto 23);
  alias multiplier_fraction : std_logic_vector(22 downto 0) is multiplier(22 downto 0);

  signal n_multiplier_exponent : std_logic_vector(7 downto 0);
  signal exponent_difference   : std_logic_vector(7 downto 0);

begin

  n_multiplier_exponent <= not multiplier_exponent;
  small_ALU: sklansky_adder
  generic map
  (
    WIDTH => 8
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
