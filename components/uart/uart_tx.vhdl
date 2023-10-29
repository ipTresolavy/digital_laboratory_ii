library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_tx is
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
    tx_start     : in  std_logic;
    s_tick       : in  std_logic;
    din          : in  std_logic_vector(DBIT-1 downto 0);
    tx_done_tick : out std_logic;
    tx           : out std_logic
  );
end entity uart_tx;

architecture behavioral of uart_tx is

  constant n_reg_max : std_logic_vector(integer(ceil(log2(real(DBIT))))-1 downto 0) := std_logic_vector(to_unsigned(DBIT-1, integer(ceil(log2(real(DBIT))))));
  constant s_reg_max : std_logic_vector(integer(ceil(log2(real(SB_TICK))))-1 downto 0) := std_logic_vector(to_unsigned(SB_TICK-1, integer(ceil(log2(real(SB_TICK))))));
  
  type state_type is (idle, start, data, stop);
  signal state_reg, state_next : state_type;

  signal s_reg,  s_next  : std_logic_vector(s_reg_max'LENGTH-1 downto 0);
  signal n_reg,  n_next  : std_logic_vector(n_reg_max'LENGTH-1 downto 0);
  signal b_reg,  b_next  : std_logic_vector(DBIT-1 downto 0);
  signal tx_reg, tx_next : std_logic;
  
begin
  
  tx_fsm: process(clock, reset)
  begin
    if reset = '1' then
      state_reg <= idle;
      s_reg <= (others => '0');
      n_reg <= (others => '0');
      b_reg <= (others => '0');
      tx_reg <= '1';
    elsif rising_edge(clock) then
      state_reg <= state_next;
      s_reg <= s_next;
      n_reg <= n_next;
      b_reg <= b_next;
      tx_reg <= tx_next;
    end if;
  end process tx_fsm;
  
  next_state_logic: process(state_reg, s_reg, n_reg, b_reg, tx_reg, tx_start, din, s_tick, b_reg)
  begin
    state_next <= state_reg;
    tx_done_tick <= '0';
    s_next <= s_reg;
    n_next <= n_reg;
    b_next <= b_reg;
    tx_next <= tx_reg;
    case state_reg is
      when idle =>
        tx_next <= '1';
        if tx_start = '1' then
          state_next <= start;
          s_next <= (others => '0');
          b_next <= din;
        end if;

      when start =>
        tx_next <= '0';
        if s_tick = '1' then
          if s_reg(3 downto 0) = "1111" then
            state_next <= data;
            s_next <= (others => '0');
            n_next <= (others => '0');
          else
            s_next <= std_logic_vector(to_unsigned(to_integer(unsigned(s_reg)) + 1, s_next'LENGTH));
          end if;
        end if;

      when data =>
        tx_next <= b_reg(0);
        if s_tick = '1' then
          if s_reg(3 downto 0) = "1111" then
            s_next <= (others => '0');
            b_next <= '1' & b_reg(b_reg'LENGTH-1 downto 1);
            if n_reg = n_reg_max  then
              state_next <= stop;
            else
              n_next <= std_logic_vector(to_unsigned(to_integer(unsigned(n_reg)) + 1, n_next'LENGTH));
            end if;
          else
            s_next <= std_logic_vector(to_unsigned(to_integer(unsigned(s_reg)) + 1, s_next'LENGTH));
          end if;
        end if;

      when stop =>
        tx_next <= '1';
        if s_tick = '1' then
          if s_reg = s_reg_max then
            state_next <= idle;
            tx_done_tick <= '1';
          else 
            s_next <= std_logic_vector(to_unsigned(to_integer(unsigned(s_reg)) + 1, s_next'LENGTH));
          end if;
        end if;

      when others =>
        state_next <= idle;

    end case;
  end process next_state_logic;

  tx <= tx_reg;
  
end architecture behavioral;

