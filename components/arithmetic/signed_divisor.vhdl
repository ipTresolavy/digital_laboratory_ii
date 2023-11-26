-- This library declaration is necessary for using standard logic types.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! @brief Entity for a signed divisor.
--! This entity performs division on two 16-bit signed inputs, producing a 32-bit quotient and remainder.
entity signed_divisor is
  port
  (
    -- System signals
    clock : in std_logic; --! @brief Clock signal for synchronization.
    reset : in std_logic; --! @brief Reset signal to initialize or reset the circuit.

    -- Handshake signals
    valid : in  std_logic; --! @brief Input validation signal to start the division process.
    ready : out std_logic; --! @brief Output ready signal indicating completion of the division process.

    -- Data inputs and outputs
    dividend  : in  std_logic_vector(15 downto 0); --! @brief Input dividend for the division.
    divisor   : in  std_logic_vector(15 downto 0); --! @brief Input divisor for the division.
    quotient  : out std_logic_vector(31 downto 0); --! @brief Output quotient of the division.
    remainder : out std_logic_vector(31 downto 0)  --! @brief Output remainder of the division.
  );
end entity signed_divisor;

--! @brief Structural architecture of the signed_divisor entity.
--! This architecture describes the internal structure and components used for the division operation.
architecture structural of signed_divisor is
  -- Component declaration for a generic register
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

  -- Component declaration for the top-level division module
  component divisor_top is
    port
    (
      -- System signals
      clock : in std_logic; --! Clock signal.
      reset : in std_logic; --! Reset signal.

      -- Handshake signals
      valid : in  std_logic; --! Input validation signal.
      ready : out std_logic; --! Output ready signal.

      -- Data inputs and outputs
      dividend  : in  std_logic_vector(15 downto 0); --! Input dividend.
      divisor   : in  std_logic_vector(15 downto 0); --! Input divisor.
      quotient  : out std_logic_vector(31 downto 0); --! Output quotient.
      remainder : out std_logic_vector(31 downto 0)  --! Output remainder.
    );
  end component divisor_top;

  -- Component declaration for Sklansky adder, used for arithmetic operations
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

  -- Declaration of state types for the FSM in the design
  type state_type is (idle, waiting);
  signal state, next_state : state_type;

  -- Internal signals used in the division process
  signal div_ready : std_logic;
  signal buffer_signs : std_logic;
  signal signal_reg_in : std_logic_vector(1 downto 0);
  signal signal_reg_out : std_logic_vector(1 downto 0);
  signal quotient_sign_selector : std_logic;

  -- Signals for intermediate values in the division process
  signal n_divisor : std_logic_vector(15 downto 0);
  signal inv_divisor : std_logic_vector(15 downto 0);
  signal n_dividend : std_logic_vector(15 downto 0);
  signal inv_dividend : std_logic_vector(15 downto 0);
  signal n_quotient : std_logic_vector(31 downto 0);
  signal inv_quotient : std_logic_vector(31 downto 0);
  signal n_remainder : std_logic_vector(31 downto 0);
  signal inv_remainder : std_logic_vector(31 downto 0);

  -- Signals for the actual inputs and outputs of the division operation
  signal dividend_in : std_logic_vector(15 downto 0);
  signal divisor_in : std_logic_vector(15 downto 0);
  signal quotient_out : std_logic_vector(31 downto 0);
  signal remainder_out : std_logic_vector(31 downto 0);

begin
  -- Logic for handling input sign and determination of output signs
  signal_reg_in <= dividend(15) & divisor(15);
  signal_reg: register_d
  generic map
  (
    WIDTH => 2
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_signs,
    data_in  => signal_reg_in,
    data_out => signal_reg_out
  );

  -- State transition process defining the FSM behavior
  state_transition: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state;
    end if;
  end process state_transition;

  -- Process for determining the next state of the FSM based on current state and input signals
  next_state_logic: process(state, valid, div_ready)
  begin
    buffer_signs <= '0';

    case state is
      when idle =>
        if valid = '1' then
          buffer_signs <= '1';
          next_state <= waiting;
        else
          next_state <= idle;
        end if;

      when waiting =>
        if div_ready = '1' then
          next_state <= idle;
        else
          next_state <= waiting;
        end if;

      when others =>
        next_state <= idle;
    end case;
  end process next_state_logic;

  -- Logic for inverting the divisor if necessary
  n_divisor <= not divisor;
  divisor_inverter: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => n_divisor,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_divisor
  );

  -- Logic for inverting the dividend if necessary
  n_dividend <= not dividend;
  dividend_inverter: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => n_dividend,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_dividend
  );

  -- Selecting the appropriate dividend input based on the sign
  with dividend(15) select
    dividend_in <= inv_dividend when '1',
                       dividend when others;

  -- Selecting the appropriate divisor input based on the sign
  with divisor(15) select
    divisor_in <= inv_divisor when '1',
                     divisor when others;

  -- Instantiation of the divisor_top component
  divisor_component: divisor_top
  port map
  (
    clock     => clock,
    reset     => reset,
    valid     => valid,
    ready     => div_ready,
    dividend  => dividend_in,
    divisor   => divisor_in,
    quotient  => quotient_out,
    remainder => remainder_out
  );

  -- Logic for inverting the quotient if necessary
  n_quotient <= not quotient_out;
  quotient_inverter: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => n_quotient,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_quotient
  );

  -- Logic for inverting the remainder if necessary
  n_remainder <= not remainder_out;
  remainder_inverter: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => n_remainder,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_remainder
  );

  -- Logic for determining the sign of the quotient
  quotient_sign_selector <= signal_reg_out(0) xor signal_reg_out(1);
  with quotient_sign_selector select
    quotient <= inv_quotient when '1',
                quotient_out when others;

  -- Logic for determining the sign of the remainder
  with signal_reg_out(1) select
    remainder <= inv_remainder when '1',
                 remainder_out when others;

  -- Outputting the ready signal
  ready <= div_ready;

end architecture structural;
