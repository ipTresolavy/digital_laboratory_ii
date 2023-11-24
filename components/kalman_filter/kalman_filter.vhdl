library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kalman_filter is
  port
  (
    -- system signals
    clock : in std_logic;
    reset : in std_logic;

    -- handshake signals
    i_valid : in  std_logic;
    o_valid : out std_logic;
    ready   : out std_logic;

    -- data inputs
    lidar  : in std_logic_vector(15 downto 0);
    hcsr04 : in std_logic_vector(15 downto 0);

    -- data output
    dist : out std_logic_vector(15 downto 0)
  );
end entity kalman_filter;

architecture structural of kalman_filter is
  component kalman_filter_ctrl is
    port
    (
      -- system signals
      clock : in std_logic;
      reset : in std_logic;

      -- handshake signals
      i_valid : in  std_logic;
      o_valid : out std_logic;
      ready   : out std_logic;

      -- control inputs
      mult_ready : in std_logic;
      div_ready  : in std_logic;

      -- control outputs
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

  component kalman_filter_dpath is
    port
    (
      -- system signals
      clock : std_logic;
      reset : std_logic;

      -- control inputs
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

      -- control outputs
      mult_ready : out std_logic;
      div_ready  : out std_logic;

      -- data inputs
      lidar  : in std_logic_vector(15 downto 0);
      hcsr04 : in std_logic_vector(15 downto 0);

      -- data output
      dist : out std_logic_vector(15 downto 0)
    );
  end component kalman_filter_dpath;

      -- control inputs
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

      -- control outputs
      signal mult_ready : std_logic;
      signal div_ready  : std_logic;

begin
  

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

  datapath: kalman_filter_dpath
  port map
  (
    clock         => clock,
    reset         => reset,
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
    pred_en       => pred_en,
    lidar         => lidar,
    hcsr04        => hcsr04,
    dist          => dist
  );
end architecture structural;
