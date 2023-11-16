--! \file
--! \brief VHDL file for the datapath of a multiplier module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

--! \brief Datapath entity for a multiplier module.
--! This entity includes the data path logic necessary for performing multiplication, including registers and an adder.
entity multiplier_dpath is
  port
  (
    -- system signals
    clock : in  std_logic; --! Clock signal.
    reset : in  std_logic; --! Reset signal.

    -- control inputs
    load           : in  std_logic; --! Load signal.
    shift_operands : in  std_logic; --! Signal to shift operands.

    -- control outputs
    finished : out std_logic; --! Signal indicating the completion of multiplication.

    -- data inputs and outputs
    multiplicand : in  std_logic_vector(15 downto 0); --! Input multiplicand.
    multiplier   : in  std_logic_vector(15 downto 0); --! Input multiplier.
    product      : out std_logic_vector(31 downto 0)  --! Output product.
  );
end entity multiplier_dpath;

architecture structural of multiplier_dpath is
  -- Component declarations for the adder and register modules.

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
      clock         : in  std_logic; --! Clock input.
      reset         : in  std_logic; --! Reset input.
      enable        : in  std_logic; --! Enable signal.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! Data input.
      data_out      : out std_logic_vector(WIDTH-1 downto 0)  --! Data output.
    );
  end component register_d;

  -- Signal declarations for internal logic and data flow.
  signal   multiplier_reg_en  : std_logic;
  signal   multiplier_reg_in  : std_logic_vector(15 downto 0);
  signal   multiplier_reg_out : std_logic_vector(15 downto 0);
  constant zero_vector        : std_logic_vector(15 downto 0) := (others => '0');
  
  signal multiplicand_reg_en  : std_logic;
  signal multiplicand_reg_in  : std_logic_vector(31 downto 0);
  signal multiplicand_reg_out : std_logic_vector(31 downto 0);
  
  signal product_reg_reset : std_logic;
  signal partial_sum       : std_logic_vector(31 downto 0);
  signal product_reg_out   : std_logic_vector(31 downto 0);
  
begin
  --! Logic for shifting and storing the multiplier.
  with shift_operands select
    multiplier_reg_in <= "0" & multiplier_reg_out(multiplier_reg_out'LENGTH-1 downto 1) when '1',
                           multiplier  when others;
  multiplier_reg_en <= load or shift_operands;
  --! Instantiation of the multiplier register.
  multiplier_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => multiplier_reg_en,
    data_in  => multiplier_reg_in,
    data_out => multiplier_reg_out
  );

  --! Logic for shifting and storing the multiplicand.
  with shift_operands select
    multiplicand_reg_in <= multiplicand_reg_out(multiplicand_reg_out'LENGTH-2 downto 0) & "0" when '1',
                           x"0000" & multiplicand  when others;
  multiplicand_reg_en <= load or shift_operands;
  --! Instantiation of the multiplicand register.
  multiplicand_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => multiplicand_reg_en,
    data_in  => multiplicand_reg_in,
    data_out => multiplicand_reg_out
  );

  --! Instantiation of the Sklansky adder to calculate the partial sum.
  adder: sklansky_adder
  generic map
  (
    WIDTH => 32 
  )
  port map
  (
    a     => product_reg_out,
    b     => multiplicand_reg_out,
    c_in  => '0',
    c_out => open,
    s     => partial_sum
  );

  --! Logic for updating the product register.
  product_reg_reset <= reset or load;
  product_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => product_reg_reset,
    enable   => multiplier_reg_out(0),
    data_in  => partial_sum,
    data_out => product_reg_out
  );

  --! Output assignment for the product.
  product <= product_reg_out;

  --! Logic to determine the finished signal based on the multiplier register.
  finished <= '1' when (multiplier_reg_out = zero_vector) else
              '0';
  
end architecture structural;
