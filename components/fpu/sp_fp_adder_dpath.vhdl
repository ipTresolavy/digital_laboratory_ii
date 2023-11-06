library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity sp_fp_adder_dpath is
  port
  (
    -- system signals
    clock : in  std_logic;
    reset : in  std_logic;

    -- control inputs
    buffer_inputs        : in std_logic;
    load_smaller         : in std_logic;
    shift_smaller_signif : in std_logic;
    
    -- control outputs
    equal_exps : out std_logic;
    
    -- data inputs
    a     : in  std_logic_vector(31 downto 0);
    b     : in  std_logic_vector(31 downto 0);

    -- data output
    y     : out std_logic_vector(31 downto 0)
  );
end entity sp_fp_adder_dpath;

architecture behavioral of sp_fp_adder_dpath is
  component register_d is
    generic
    (
      WIDTH : natural := 8 --! @brief Width of the register.
    );
    port
    (
      clock         : in  std_logic; --! @brief System clock signal.
      reset         : in  std_logic; --! @brief System reset signal.
      enable        : in  std_logic; --! @brief Enable signal for the register.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! @brief Input data for the register.
      data_out      : out std_logic_vector(WIDTH-1 downto 0)  --! @brief Output data of the register.
    );
  end component register_d;

  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16 --! \brief Width of the operands.
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0); --! \brief First operand.
      b     : in  std_logic_vector(WIDTH-1 downto 0); --! \brief Second operand.
      c_in  : in  std_logic; --! \brief Carry input.
      c_out : out std_logic; --! \brief Carry output.
      s     : out std_logic_vector(WIDTH-1 downto 0) --! \brief Sum output.
    );
  end component sklansky_adder;

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


  signal a_buf, b_buf : std_logic_vector(31 downto 0);
  signal s_y : std_logic_vector(31 downto 0);

  signal a_signif : std_logic_vector(23 downto 0);
  signal b_signif : std_logic_vector(23 downto 0);

  signal smaller_exp : std_logic_vector(7 downto 0);
  signal larger_exp : std_logic_vector(7 downto 0);
  signal smaller_signif : std_logic_vector(23 downto 0);
  signal larger_signif : std_logic_vector(23 downto 0);

  -- aliases
  alias a_sign : std_logic is a_buf(31);
  alias a_exp : std_logic_vector(7 downto 0) is a_buf(30 downto 23);
  alias a_mant : std_logic_vector(22 downto 0) is a_buf(22 downto 0);

  alias b_sign : std_logic is b_buf(31);
  alias b_exp : std_logic_vector(7 downto 0) is b_buf(30 downto 23);
  alias b_mant : std_logic_vector(22 downto 0) is b_buf(22 downto 0);
  -- ---

  signal not_b_exp : std_logic_vector(7 downto 0);
  signal exp_b_gt_a : std_logic;
  signal signif_b_gt_a : std_logic;

  signal smaller_signif_reg_en  : std_logic;
  signal smaller_signif_reg_in  : std_logic_vector(23 downto 0);
  signal smaller_signif_reg_out : std_logic_vector(23 downto 0);
  signal not_smaller_signif_reg_out : std_logic_vector(23 downto 0);
  signal smaller_exp_cnt_out : std_logic_vector(7 downto 0);

  signal ones_complement_decoder : std_logic_vector(1 downto 0);
  signal sum_c_in, sum_c_out : std_logic;
  signal sum_a, sum_b : std_logic_vector(23 downto 0);
  signal sum_out : std_logic_vector(23 downto 0);

begin

  a_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => a,
    data_out => a_buf
  );
  
  b_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => b,
    data_out => b_buf
  );

  a_signif <= "1" & a_mant;
  b_signif <= "1" & b_mant;

  -- compare exponents
  not_b_exp <= not b_exp;

  exp_comparator: sklansky_adder
  generic map
  (
    WIDTH => 8
  )
  port map
  (
    a     => a_exp,
    b     => not_b_exp,
    c_in  => '1',
    c_out => exp_b_gt_a,
    s     => open
  );

  with exp_b_gt_a select
    larger_exp <= b_exp when '1',
                  a_exp when others;

  with exp_b_gt_a select
    smaller_exp <= a_exp when '1',
                   b_exp when others;

  with exp_b_gt_a select
    larger_signif <= b_signif when '1',
                     a_signif when others;

  with exp_b_gt_a select
    smaller_signif <= a_signif when '1',
                      b_signif when others;
  -- ---

  -- shift smaller exponent number's significand
  with shift_smaller_signif select
    smaller_signif_reg_in <= smaller_signif when '0',
                             "0" & smaller_signif_reg_out(23 downto 1) when others;

  smaller_signif_reg_en <= load_smaller or shift_smaller_signif;

  smaller_signif_reg: register_d
  generic map
  (
    WIDTH => 24
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => smaller_signif_reg_en,
    data_in  => smaller_signif_reg_in,
    data_out => smaller_signif_reg_out
  );

  smaller_exp_cnt: sync_par_counter
  generic map
  (
    MODU => 2**8
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    cnt_en => shift_smaller_signif,
    q_in   => smaller_exp,
    load   => load_smaller,
    q      => smaller_exp_cnt_out
  );

  equal_exps <= '1' when (smaller_exp_cnt_out = larger_exp) else
                '0';
  -- ---

  -- compare significands
  not_smaller_signif_reg_out <= not smaller_signif_reg_out;

  signif_comparator: sklansky_adder
  generic map
  (
    WIDTH => 24
  )
  port map
  (
    a     => larger_signif,
    b     => not_smaller_signif_reg_out,
    c_in  => '1',
    c_out => signif_b_gt_a,
    s     => open
  );

  ones_complement_decoder(1) <= signif_b_gt_a and (a_sign xor b_sign);
  ones_complement_decoder(0) <= (not signif_b_gt_a) and (a_sign xor b_sign);

  with ones_complement_decoder(1) select
    sum_a <= not larger_signif when '1',
             larger_signif when others; 

  with ones_complement_decoder(0) select
    sum_b <= not_smaller_signif_reg_out when '1',
             smaller_signif_reg_out when others; 
  -- ---

  -- sum significands
  sum_c_in <= a_sign xor b_sign;
  
  signif_adder: sklansky_adder
  generic map
  (
    WIDTH => 24
  )
  port map
  (
    a     => sum_a,
    b     => sum_b,
    c_in  => sum_c_in,
    c_out => sum_c_out,
    s     => sum_out
  );

  -- ---
  
end architecture behavioral;
