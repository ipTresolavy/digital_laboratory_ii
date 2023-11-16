library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity divisor_dpath is
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
end entity divisor_dpath;

architecture structural of divisor_dpath is
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

  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16 --! \brief Modulus of the counter.
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      cnt_en : in  std_logic; --! \brief Count enable signal.
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! \brief Parallel load input.
      load   : in  std_logic; --! \brief Load signal.
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0) --! \brief Counter output.
    );
  end component sync_par_counter;

  constant zero_vector : std_logic_vector(15 downto 0) := (others => '0');

  signal quotient_reg_en  : std_logic;
  signal quotient_reg_in  : std_logic_vector(15 downto 0);
  signal quotient_reg_out : std_logic_vector(15 downto 0);
  
  signal divisor_reg_en  : std_logic;
  signal divisor_reg_in  : std_logic_vector(31 downto 0);
  signal divisor_reg_out : std_logic_vector(31 downto 0);
  
  signal remainder_reg_reset : std_logic;
  signal remainder_reg_en    : std_logic;
  signal remainder_reg_in    : std_logic_vector(31 downto 0);
  signal remainder_reg_out   : std_logic_vector(31 downto 0);

  signal b : std_logic_vector(31 downto 0);
  signal c_in : std_logic;
  signal s : std_logic_vector(31 downto 0);

  signal iteration_counter_reset : std_logic;
  signal iteration_count : std_logic_vector(natural(ceil(log2(real(18))))-1 downto 0);

begin

  with shift_quotient select
    quotient_reg_in <= quotient_reg_out(quotient_reg_out'LENGTH-2 downto 0) & set_quotient_bit when '1',
                       (others => '0') when others;
  quotient_reg_en <= load or shift_quotient; 
  quotient_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => quotient_reg_en,
    data_in  => quotient_reg_in,
    data_out => quotient_reg_out
  );
  
  with shift_divisor select
    divisor_reg_in <= "0" & divisor_reg_out(divisor_reg_out'LENGTH-1 downto 1) when '1',
                      divisor & x"0000" when others;
  divisor_reg_en <= load or shift_divisor; 
  divisor_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => divisor_reg_en,
    data_in  => divisor_reg_in,
    data_out => divisor_reg_out
  );

  with restore_sub select
    b <= divisor_reg_out when '1',
         not divisor_reg_out when others;
  c_in <= not restore_sub;
  adder: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => remainder_reg_out,
    b     => b,
    c_in  => c_in,
    c_out => open,
    s     => s
  );


  with load select
    remainder_reg_in <= x"0000" & dividend when '1',
                        s when others;

  remainder_reg_reset <= reset;
  remainder_reg_en <= write_remainder or load;
  remainder_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => remainder_reg_reset,
    enable   => remainder_reg_en,
    data_in  => remainder_reg_in,
    data_out => remainder_reg_out
  );

  iteration_counter_reset <= reset or load;
  iteration_counter: sync_par_counter
  generic map
  (
    MODU => 18
  )
  port map
  (
    clock  => clock,
    reset  => iteration_counter_reset,
    cnt_en => shift_quotient,
    q_in   => (others => '0'),
    load   => '0',
    q      => iteration_count
  );

  neg_remainder <= remainder_reg_out(remainder_reg_out'LENGTH-1) or divisor_reg_out(divisor_reg_out'LENGTH-1);
  finished <= '1' when iteration_count = "10001" else
              '0';
  remainder <= remainder_reg_out;
  quotient <= x"0000" & quotient_reg_out;

end architecture structural;
