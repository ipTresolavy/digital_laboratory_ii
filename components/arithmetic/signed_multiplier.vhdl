library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_multiplier is
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
end entity signed_multiplier;

architecture structural of signed_multiplier is
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

  component multiplier_top is
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
  end component multiplier_top;

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

  type state_type is (idle, waiting);
  signal state, next_state : state_type;

  signal mult_ready : std_logic;
  signal buffer_sign : std_logic;
  signal signal_reg_in : std_logic_vector(0 downto 0);
  signal signal_reg_out : std_logic_vector(0 downto 0);

  signal n_multiplier : std_logic_vector(15 downto 0);
  signal inv_multiplier : std_logic_vector(15 downto 0);
  signal n_multiplicand : std_logic_vector(15 downto 0);
  signal inv_multiplicand : std_logic_vector(15 downto 0);
  signal n_product : std_logic_vector(31 downto 0);
  signal inv_product : std_logic_vector(31 downto 0);

  signal multiplicand_in : std_logic_vector(15 downto 0);
  signal multiplier_in : std_logic_vector(15 downto 0);
  signal product_out : std_logic_vector(31 downto 0);
  
begin

  signal_reg_in(0) <= multiplier(15) xor multiplicand(15);
  signal_reg: register_d
  generic map
  (
    WIDTH => 1
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_sign,
    data_in  => signal_reg_in,
    data_out => signal_reg_out
  );

  state_transition: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state;
    end if;
  end process state_transition;

  next_state_logic: process(state, valid, mult_ready)
  begin
    buffer_sign <= '0';

    case state is
      when idle =>
        if valid = '1' then
          buffer_sign <= '1';
          next_state <= waiting;
        else
          next_state <= idle;
        end if;

      when waiting =>
        if mult_ready = '1' then
          next_state <= idle;
        else
          next_state <= waiting;
        end if;

      when others =>
        next_state <= idle;
    end case;
  end process next_state_logic;
 
  n_multiplier <= not multiplier;
  multiplier_inverter: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => n_multiplier,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_multiplier
  );

  n_multiplicand <= not multiplicand;
  multiplicand_inverter: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => n_multiplicand,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_multiplicand
  );

  with multiplicand(15) select
    multiplicand_in <= inv_multiplicand when '1',
                       multiplicand when others;

  with multiplier(15) select
    multiplier_in <= inv_multiplier when '1',
                     multiplier when others;

  multiplier_component: multiplier_top
  port map
  (
    clock        => clock,
    reset        => reset,
    valid        => valid,
    ready        => mult_ready,
    multiplicand => multiplicand_in,
    multiplier   => multiplier_in,
    product      => product_out
  );

  n_product <= not product_out;
  product_inverter: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => n_product,
    b     => (others => '0'),
    c_in  => '1',
    c_out => open,
    s     => inv_product
  );

  with signal_reg_out(0) select
    product <= inv_product when '1',
               product_out when others;
  
  ready <= mult_ready;
  
end architecture structural;
