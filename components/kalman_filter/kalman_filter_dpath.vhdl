-- Standard library and logic types are included for VHDL design.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! @brief Entity for Kalman Filter Datapath.
--! This entity represents the datapath of a Kalman filter, processing sensor inputs to estimate a state.
entity kalman_filter_dpath is
  port
  (
    -- System signals
    clock : std_logic; --! @brief Clock signal for synchronization.
    reset : std_logic; --! @brief Reset signal to initialize or reset the datapath logic.

    -- Control inputs
    buffer_inputs : in std_logic; --! @brief Signal to buffer inputs from sensors.
    x_src, p_src  : in std_logic_vector(1 downto 0); --! @brief Source selectors for state estimate (x) and error covariance (p).
    x_en, p_en    : in std_logic; --! @brief Enable signals for x and p registers.
    diff_src      : in std_logic; --! @brief Source selector for the difference calculation.
    mult_src      : in std_logic; --! @brief Source selector for the multiplier.
    mult_valid    : in std_logic; --! @brief Validation signal for the multiplier.
    div_src       : in std_logic; --! @brief Source selector for the divider.
    div_valid     : in std_logic; --! @brief Validation signal for the divider.
    add_src       : in std_logic; --! @brief Source selector for the adder.
    pred_en       : in std_logic; --! @brief Enable signal for the predictor.

    -- Control outputs
    mult_ready : out std_logic; --! @brief Signal indicating the multiplier is ready.
    div_ready  : out std_logic; --! @brief Signal indicating the divider is ready.

    -- Data inputs
    lidar  : in std_logic_vector(15 downto 0); --! @brief Input from lidar sensor.
    hcsr04 : in std_logic_vector(15 downto 0); --! @brief Input from hcsr04 ultrasonic sensor.

    -- Data output
    dist : out std_logic_vector(15 downto 0) --! @brief Output estimated distance.
  );
end entity kalman_filter_dpath;

--! @brief Structural architecture of the kalman_filter_dpath entity.
--! This architecture includes various components for arithmetic operations that constitute the Kalman filter's datapath.
architecture structural of kalman_filter_dpath is
  -- Component declarations for arithmetic operations used in Kalman filter
  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16 --! @brief Width of the operands for the adder.
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0); --! @brief First operand.
      b     : in  std_logic_vector(WIDTH-1 downto 0); --! @brief Second operand.
      c_in  : in  std_logic; --! @brief Carry input.
      c_out : out std_logic; --! @brief Carry output.
      s     : out std_logic_vector(WIDTH-1 downto 0) --! @brief Sum output.
    );
  end component sklansky_adder;

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
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! @brief Output data of the register.
    );
  end component register_d;

  component signed_multiplier is
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
  end component signed_multiplier;

  component signed_divisor is
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
  end component signed_divisor;

  signal lidar_buff  : std_logic_vector(15 downto 0);
  signal hcsr04_buff : std_logic_vector(15 downto 0);

  signal lidar_hcsr04_sum : std_logic_vector(15 downto 0);
  signal inputs_mean : std_logic_vector(15 downto 0);

  signal x_reg_in  : std_logic_vector(15 downto 0);
  signal x_reg_out : std_logic_vector(15 downto 0);
  signal p_reg_in  : std_logic_vector(15 downto 0);
  signal p_reg_out : std_logic_vector(15 downto 0);
  signal pred_x_reg_out : std_logic_vector(15 downto 0);
  signal pred_p_reg_out : std_logic_vector(15 downto 0);
  signal pred_x_sum_out : std_logic_vector(15 downto 0);
  signal pred_p_sum_out : std_logic_vector(15 downto 0);
  signal next_x : std_logic_vector(15 downto 0);
  signal next_p : std_logic_vector(15 downto 0);

  signal diff_a : std_logic_vector(15 downto 0);
  signal diff_b : std_logic_vector(15 downto 0);
  signal diff_out : std_logic_vector(15 downto 0);

  signal multiplier : std_logic_vector(15 downto 0);
  signal multiplicand : std_logic_vector(15 downto 0);
  signal product : std_logic_vector(31 downto 0);

  signal dividend : std_logic_vector(15 downto 0);
  signal divisor_adder_a : std_logic_vector(15 downto 0);
  signal divisor : std_logic_vector(15 downto 0);
  signal quotient : std_logic_vector(31 downto 0);

  signal add_a : std_logic_vector(31 downto 0);
  signal add_b : std_logic_vector(31 downto 0);
  signal add_out : std_logic_vector(31 downto 0);
  
begin
  
  lidar_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => lidar,
    data_out => lidar_buff
  );
  
  hcsr04_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => hcsr04,
    data_out => hcsr04_buff
  );

  mean_adder: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => lidar_buff,
    b     => hcsr04_buff,
    c_in  => '0',
    c_out => open,
    s     => lidar_hcsr04_sum
  );
  inputs_mean <= "0" & lidar_hcsr04_sum(lidar_hcsr04_sum'LENGTH-1 downto 1);

  with x_src select
    x_reg_in <= inputs_mean when "11",
                next_x when "00",
                add_out(15 downto 0) when others;
  x: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => x_en,
    data_in  => x_reg_in,
    data_out => x_reg_out
  );

  with p_src select
    p_reg_in <= (6 to 15 => '0') & "101100" when "11",
                next_p when "00",
                add_out(15 downto 0) when others;
  p: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => p_en,
    data_in  => p_reg_in,
    data_out => p_reg_out
  );

  with diff_src select
    diff_a <= lidar_buff when '1',
              hcsr04_buff when others;
  diff_b <= not x_reg_out;
  diff: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => diff_a,
    b     => diff_b,
    c_in  => '1',
    c_out => open,
    s     => diff_out
  );

  with mult_src select
    multiplicand <= p_reg_out when '1',
                    diff_out when others;
  multiplier <= p_reg_out;
  multiplier_component: signed_multiplier
  port map
  (
    clock        => clock,
    reset        => reset,
    valid        => mult_valid,
    ready        => mult_ready,
    multiplicand => multiplicand,
    multiplier   => multiplier,
    product      => product
  );

  with div_src select
    divisor_adder_a <= (7 to 15 => '0') & "1100100" when '1',
                       (7 to 15 => '0') & "1100100" when others;
  divisor_adder: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => divisor_adder_a,
    b     => p_reg_out,
    c_in  => '0',
    c_out => open,
    s     => divisor
  );

  dividend <= product(15 downto 0);
  divisor_component: signed_divisor
  port map
  (
    clock     => clock,
    reset     => reset,
    valid     => div_valid,
    ready     => div_ready,
    dividend  => dividend,
    divisor   => divisor,
    quotient  => quotient,
    remainder => open
  );

  with add_src select
    add_a <= (16 to 31 => p_reg_out(15)) & p_reg_out when '1',
             (16 to 31 => x_reg_out(15)) & x_reg_out when others;
  with add_src select
    add_b <= not quotient when '1',
             quotient when others;
  add: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => add_a,
    b     => add_b,
    c_in  => add_src,
    c_out => open,
    s     => add_out
  );

  next_x <= x_reg_out;

  next_p_adder: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => x"0006",
    b     => p_reg_out,
    c_in  => '0',
    c_out => open,
    s     => next_p
  );

  dist <= x_reg_out;
  
end architecture structural;
