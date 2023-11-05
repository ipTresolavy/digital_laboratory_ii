--! \file
--! \brief UART Receiver Entity Implementation
--! 
--! This file contains the implementation of a UART receiver with configurable data bits and stop bits.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity uart_rx
--! \brief UART Receiver Entity
--! 
--! The UART receiver entity is responsible for receiving serial data and converting it into parallel data.
entity uart_rx is
  generic
  (
    DBIT    : natural := 8; --! \brief Number of data bits.
    SB_TICK : natural := 16 --! \brief Number of ticks for stop bits. 16: 1 stop bit, 24: 1.5 stop bit, 32: 2 stop bits.
  );
  port
  (
    clock        : in  std_logic; --! \brief Clock input.
    reset        : in  std_logic; --! \brief Reset input.
    rx           : in  std_logic; --! \brief Serial data input.
    s_tick       : in  std_logic; --! \brief Sampling tick input.
    rx_done_tick : out std_logic; --! \brief Flag indicating reception is done.
    dout         : out std_logic_vector(DBIT-1 downto 0) --! \brief Parallel data output.
  );
end entity uart_rx;

--! \architecture behavioral
--! \brief Behavioral Architecture of UART Receiver
--! 
--! This architecture implements the state machine and logic for the UART receiver.
architecture behavioral of uart_rx is
  -- Component declarations
  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16 --! \brief Modulus of the counter.
    );
    port
    (
      clock  : in  std_logic; --! \brief Clock input.
      reset  : in  std_logic; --! \brief Reset input.
      cnt_en : in  std_logic; --! \brief Count enable input.
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! \brief Parallel load input.
      load   : in  std_logic; --! \brief Load enable input.
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0) --! \brief Counter output.
    );
  end component sync_par_counter;

  component register_d is
    generic
    (
      WIDTH : natural := 8 --! \brief Width of the data bus.
    );
    port
    (
      clock         : in  std_logic; --! \brief Clock input.
      reset         : in  std_logic; --! \brief Reset input.
      enable        : in  std_logic; --! \brief Enable input.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! \brief Data input.
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! \brief Data output.
    );
  end component register_d;

  -- Constants and types
  constant n_counter_max : std_logic_vector(integer(ceil(log2(real(DBIT))))-1 downto 0) := std_logic_vector(to_unsigned(DBIT-1, integer(ceil(log2(real(DBIT))))));
  constant s_counter_max : std_logic_vector(integer(ceil(log2(real(SB_TICK))))-1 downto 0) := std_logic_vector(to_unsigned(SB_TICK-1, integer(ceil(log2(real(SB_TICK))))));
  
  type state_type is (idle, start, data, stop); --! \brief State type for the UART receiver state machine.
  signal state_reg, state_next : state_type; --! \brief State machine registers.

  -- Internal signals
  signal s_counter : std_logic_vector(s_counter_max'LENGTH-1 downto 0); --! \brief Sampling counter.
  signal s_counter_clear : std_logic; --! \brief Sampling counter clear signal.
  signal s_counter_en : std_logic; --! \brief Sampling counter enable signal.

  signal n_counter : std_logic_vector(n_counter_max'LENGTH-1 downto 0); --! \brief Bit counter.
  signal n_counter_clear : std_logic; --! \brief Bit counter clear signal.
  signal n_counter_en : std_logic; --! \brief Bit counter enable signal.

  signal b_reg, b_next : std_logic_vector(DBIT-1 downto 0); --! \brief Data buffer registers.
  signal b_reg_en : std_logic; --! \brief Data buffer register enable signal.

begin

  -- Counter instances
  s_counter_inst: sync_par_counter
  generic map
  (
    MODU => 2**(s_counter_max'LENGTH)
  )
  port map
  (
    clock => clock,
    reset => reset,
    cnt_en => s_counter_en,
    load => s_counter_clear,
    q_in => (others => '0'),
    q => s_counter
  );

  n_counter_inst: sync_par_counter
  generic map
  (
    MODU => 2**(n_counter_max'LENGTH)
  )
  port map
  (
    clock => clock,
    reset => reset,
    cnt_en => n_counter_en,
    load => n_counter_clear,
    q_in => (others => '0'),
    q => n_counter
  );

  -- Data buffer logic
  b_next <= rx & b_reg(b_reg'LENGTH-1 downto 1);
  b_reg_inst: register_d
  generic map
  (
    WIDTH => DBIT
  )
  port map
  (
    clock => clock,
    reset => reset,
    enable => b_reg_en,
    data_in => b_next,
    data_out => b_reg
  );

  -- UART receiver state machine
  rx_fsm: process(clock, reset)
  begin
    if reset = '1' then
      state_reg <= idle;
    elsif rising_edge(clock) then
      state_reg <= state_next;     
    end if;
  end process rx_fsm;

  -- Next state logic
  next_state_logic: process(state_reg, s_counter, n_counter, rx, s_tick)
  begin
    rx_done_tick <= '0';
    s_counter_clear <= '0';
    n_counter_clear <= '0';
    s_counter_en <= '0';
    n_counter_en <= '0';
    b_reg_en <= '0';

    case state_reg is
      when idle =>
        state_next <= idle;
        if rx = '0' then
          state_next <= start;
          s_counter_clear <= '1';
        end if;

      when start =>
        state_next <= start;
        if s_tick = '1' then
          if s_counter(2 downto 0) = "111" then
            state_next <= data;
            s_counter_clear <= '1';
            n_counter_clear <= '1';
          else
            s_counter_en <= '1';
          end if;
        end if;

      when data =>
        state_next <= data;
        if s_tick = '1' then
          if s_counter(3 downto 0) = "1111" then
            s_counter_clear <= '1';
            b_reg_en <= '1';
            if n_counter = n_counter_max then
              state_next <= stop;
            else
              n_counter_en <= '1';
            end if;
          else
            s_counter_en <= '1';
          end if;
        end if;

      when stop =>
        state_next <= stop;
        if s_tick = '1' then
          if s_counter = s_counter_max then
            state_next <= idle;
            rx_done_tick <= '1';
          else
            s_counter_en <= '1';
          end if;
        end if;

      when others =>
        state_next <= idle;

    end case;
  end process next_state_logic;

  -- Output assignments
  dout <= b_reg;

end architecture behavioral;
