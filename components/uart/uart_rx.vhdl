library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_rx is
  generic
  (
    DBIT    : natural := 8; -- data bits
    SB_TICK : natural := 16 -- num of ticks for stop bits
                            -- 16: 1 stop bit, 24: 1.5 stop bit
                            -- 32: 2 stop bits
  );
  port
  (
    clock        : in  std_logic;
    reset        : in  std_logic;
    rx           : in  std_logic;
    s_tick       : in  std_logic;
    rx_done_tick : out std_logic;
    dout         : out std_logic_vector(DBIT-1 downto 0)
  );
end entity uart_rx;

architecture behavioral of uart_rx is
  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      cnt_en : in  std_logic;
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)
    );
  end component sync_par_counter;

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

  constant n_counter_max : std_logic_vector(integer(ceil(log2(real(DBIT))))-1 downto 0) := std_logic_vector(to_unsigned(DBIT-1, integer(ceil(log2(real(DBIT))))));
  constant s_counter_max : std_logic_vector(integer(ceil(log2(real(SB_TICK))))-1 downto 0) := std_logic_vector(to_unsigned(SB_TICK-1, integer(ceil(log2(real(SB_TICK))))));
  
  type state_type is (idle, start, data, stop);
  signal state_reg, state_next : state_type;

  -- tick counter
  signal s_counter : std_logic_vector(s_counter_max'LENGTH-1 downto 0);
  signal s_counter_clear : std_logic;
  signal s_counter_reset : std_logic;
  signal s_counter_en : std_logic;

  -- bit counter
  signal n_counter : std_logic_vector(n_counter_max'LENGTH-1 downto 0);
  signal n_counter_clear : std_logic;
  signal n_counter_reset : std_logic;
  signal n_counter_en : std_logic;

  signal b_reg, b_next : std_logic_vector(DBIT-1 downto 0);
  signal b_reg_en : std_logic;

  signal comp_en : std_logic;
 
begin

  s_counter_reset <= reset or s_counter_clear;
  s_counter_inst: sync_par_counter
  generic map
  (
    MODU => 2**(s_counter_max'LENGTH)
  )
  port map
  (
    clock => clock,
    reset => s_counter_reset,
    cnt_en => s_counter_en,
    q => s_counter
  );

  n_counter_reset <= reset or n_counter_clear;
  n_counter_inst: sync_par_counter
  generic map
  (
    MODU => 2**(n_counter_max'LENGTH)
  )
  port map
  (
    clock => clock,
    reset => n_counter_reset,
    cnt_en => n_counter_en,
    q => n_counter
  );

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

  rx_fsm: process(clock, reset)
  begin
    if reset = '1' then
      state_reg <= idle;
    elsif rising_edge(clock) then
      state_reg <= state_next;     
    end if;
  end process rx_fsm;

  next_state_logic: process(state_reg, s_counter, n_counter, rx, s_tick, comp_en)
  begin
    state_next <= state_reg;
    rx_done_tick <= '0';
    comp_en <= '1';
    s_counter_clear <= '0';
    n_counter_clear <= '0';
    s_counter_en <= '0';
    n_counter_en <= '0';
    b_reg_en <= '0';

    case state_reg is
      when idle =>
        if rx = '0' then
          state_next <= start;
          s_counter_clear <= '1';
        end if;

      when start =>
        if s_tick = '1' then
          if s_counter(2 downto 0) = "111" then
            state_next <= data;
            s_counter_clear <= s_counter(3);
            n_counter_clear <= '1';
          else
            s_counter_en <= '1';
          end if;
        end if;

      when data =>
        if s_tick = '1' then
          if s_counter(3 downto 0) = "1111" then
            s_counter_clear <= s_counter(4);
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
        if s_tick = '1' then
          if s_counter = s_counter_max and comp_en = '1' then
            state_next <= idle;
            rx_done_tick <= '1';
          else
            s_counter_en <= '1';
            comp_en <= '0';
          end if;
        end if;

      when others =>
        state_next <= idle;

    end case;
  end process next_state_logic;

  dout <= b_reg;

end architecture behavioral;
