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

  with shift_operands select
    multiplier_reg_in <= "0" & multiplier_reg_out(multiplier_reg_out'LENGTH-1 downto 1) when '1',
                           multiplier  when others;
  multiplier_reg_en <= load or shift_operands;
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

  with shift_operands select
    multiplicand_reg_in <= multiplicand_reg_out(multiplicand_reg_out'LENGTH-2 downto 0) & "0" when '1',
                           x"0000" & multiplicand  when others;
  multiplicand_reg_en <= load or shift_operands;
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
  
  product <= product_reg_out;

  finished <= '1' when (multiplier_reg_out = zero_vector) else
              '0';
  
end architecture structural;
