-- Standard library and logic types are included for VHDL design.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! @brief Entity for a Kalman filter.
--! This entity integrates lidar and hcsr04 sensor inputs to estimate distance using a Kalman filter algorithm.
entity kalman_filter is
  port
  (
    -- System signals
    clock : in std_logic; --! @brief Clock signal for synchronization.
    reset : in std_logic; --! @brief Reset signal to initialize or reset the circuit.

    -- Handshake signals
    i_valid : in  std_logic; --! @brief Input validation signal to start the filtering process.
    o_valid : out std_logic; --! @brief Output validation signal indicating completion of the filtering process.
    ready   : out std_logic; --! @brief Ready signal to indicate readiness for new data.

    -- Data inputs
    lidar  : in std_logic_vector(15 downto 0); --! @brief Input from lidar sensor.
    hcsr04 : in std_logic_vector(15 downto 0); --! @brief Input from hcsr04 ultrasonic sensor.

    -- Data output
    dist : out std_logic_vector(15 downto 0) --! @brief Output estimated distance.
  );
end entity kalman_filter;

--! @brief Structural architecture of the kalman_filter entity.
--! This architecture includes the control and datapath components that constitute the Kalman filter.
architecture structural of kalman_filter is
  -- Component declaration for Kalman filter control unit
  component kalman_filter_ctrl is
    port
    (
      -- System signals
      clock : in std_logic;
      reset : in std_logic;

      -- Handshake signals
      i_valid : in  std_logic;
      o_valid : out std_logic;
      ready   : out std_logic;

      -- Control inputs
      mult_ready : in std_logic;
      div_ready  : in std_logic;

      -- Control outputs
      buffer_inputs : out std_logic;
      x_src, p_src  : out std_logic_vector(1 downto 0);
      x_en, p_en    : out std_logic;
      diff_src      : out std_logic;
      mult_src      : out std_logic;
      mult_valid    : out std_logic;
      div_src       : out std_logic;
      div_valid     : out std_logic;
      add_src       : out std_logic;
      pred_en       : out std_logic
    );
  end component kalman_filter_ctrl;

  -- Component declaration for Kalman filter datapath unit
  component kalman_filter_dpath is
    port
    (
      -- System signals
      clock : in std_logic;
      reset : in std_logic;

      -- Control inputs
      buffer_inputs : in std_logic;
      x_src, p_src  : in std_logic_vector(1 downto 0);
      x_en, p_en    : in std_logic;
      diff_src      : in std_logic;
      mult_src      : in std_logic;
      mult_valid    : in std_logic;
      div_src       : in std_logic;
      div_valid     : in std_logic;
      add_src       : in std_logic;
      pred_en       : in std_logic;

      -- Control outputs
      mult_ready : out std_logic;
      div_ready  : out std_logic;

      -- Data inputs
      lidar  : in std_logic_vector(15 downto 0);
      hcsr04 : in std_logic_vector(15 downto 0);

      -- Data output
      dist : out std_logic_vector(15 downto 0)
    );
  end component kalman_filter_dpath;

  -- Internal signals for control and data flow between control unit and datapath
  signal buffer_inputs : std_logic;
  signal x_src, p_src  : std_logic_vector(1 downto 0);
  signal x_en, p_en    : std_logic;
  signal diff_src      : std_logic;
  signal mult_src      : std_logic;
  signal mult_valid    : std_logic;
  signal div_src       : std_logic;
  signal div_valid     : std_logic;
  signal add_src       : std_logic;
  signal pred_en       : std_logic;

  -- Signals to synchronize the operations of the control unit and datapath
  signal mult_ready : std_logic;
  signal div_ready  : std_logic;

begin
  -- Control unit instantiation, coordinating the operation of the Kalman filter
  control_unit: kalman_filter_ctrl
  port map
  (
    clock         => clock,
    reset         => reset,
    i_valid       => i_valid,
    o_valid       => o_valid,
    ready         => ready,
    mult_ready    => mult_ready,
    div_ready     => div_ready,
    buffer_inputs => buffer_inputs,
    x_src         => x_src,
    p_src         => p_src,
    x_en          => x_en,
    p_en          => p_en,
    diff_src      => diff_src,
    mult_src      => mult_src,
    mult_valid    => mult_valid,
    div_src       => div_src,
    div_valid     => div_valid,
    add_src       => add_src,
    pred_en       => pred_en
  );

  -- Datapath instantiation, responsible for the computation aspects of the Kalman filter
  datapath: kalman_filter_dpath
  port map
  (
    clock         => clock,
    reset         => reset,
    buffer_inputs => buffer_inputs,
    x_src         => x_src,
    p_src         => p_src,
    x_en          => x_en,
    p_en          => p_en,
    diff_src      => diff_src,
    mult_src      => mult_src,
    mult_valid    => mult_valid,
    div_src       => div_src,
    div_valid     => div_valid,
    add_src       => add_src,
    pred_en       => pred_en,
    mult_ready    => mult_ready,
    div_ready     => div_ready,
    lidar         => lidar,
    hcsr04        => hcsr04,
    dist          => dist
  );
end architecture structural;
