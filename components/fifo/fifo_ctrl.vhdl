library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fifo_ctrl is
  generic
  (
    ADDR_WIDTH : natural := 4
  );
  port
  (
    clock  : in  std_logic;
    reset  : in  std_logic;
    rd     : in  std_logic;
    wr     : in  std_logic;
    empty  : out std_logic;
    full   : out std_logic;
    w_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    r_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end entity fifo_ctrl;

architecture behavioral of fifo_ctrl is

  signal w_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal w_ptr_next  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal w_ptr_succ  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal tmp_w_ptr_succ  : std_logic_vector(ADDR_WIDTH downto 0);
  
  signal r_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal r_ptr_next  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal r_ptr_succ  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal tmp_r_ptr_succ  : std_logic_vector(ADDR_WIDTH downto 0);

  signal full_logic  : std_logic;
  signal empty_logic : std_logic;
  signal full_next   : std_logic;
  signal empty_next  : std_logic;

  signal wr_rd : std_logic_vector(1 downto 0);

begin

  wr_rd <= wr & rd;
  
  fifo_control_logic: process(clock, reset)
  begin
    if reset = '1' then
      w_ptr_logic <= (others => '0');
      r_ptr_logic <= (others => '0');
      full_logic  <= '0';
      empty_logic <= '1';
    elsif rising_edge(clock) then
      w_ptr_logic <= w_ptr_next;
      r_ptr_logic <= r_ptr_next;
      full_logic  <= full_next;
      empty_logic <= empty_next;
    end if;
  end process fifo_control_logic;

  tmp_w_ptr_succ <= std_logic_vector(to_unsigned(to_integer(unsigned(w_ptr_logic)) + 1, tmp_w_ptr_succ'LENGTH));
  tmp_r_ptr_succ <= std_logic_vector(to_unsigned(to_integer(unsigned(r_ptr_logic)) + 1, tmp_r_ptr_succ'LENGTH));

  next_state_logic: process(w_ptr_logic, r_ptr_logic, full_logic, empty_logic, wr_rd, r_ptr_succ, w_ptr_succ, tmp_r_ptr_succ, tmp_w_ptr_succ)
  begin
    w_ptr_succ <= tmp_w_ptr_succ(w_ptr_succ'LENGTH-1 downto 0);
    r_ptr_succ <= tmp_r_ptr_succ(r_ptr_succ'LENGTH-1 downto 0);
    w_ptr_next <= w_ptr_logic;
    r_ptr_next <= r_ptr_logic;
    full_next  <= full_logic;
    empty_next <= empty_logic;
    
    case wr_rd is
      when "01" =>
        if empty_logic = '0' then
          r_ptr_next <= r_ptr_succ;
          full_next <= '0';
          if r_ptr_succ = w_ptr_logic then
            empty_next <= '1';
          end if;
        end if; 

      when "10" =>
        if full_logic = '0' then
          w_ptr_next <= w_ptr_succ;
          empty_next <= '0';
          if w_ptr_succ = r_ptr_logic then
            full_next <= '1';
          end if;
        end if;

      when "11" =>
        w_ptr_next <= w_ptr_succ;
        r_ptr_next <= r_ptr_succ;

      when others =>

    end case;
  end process next_state_logic;

  w_addr <= w_ptr_logic;
  r_addr <= r_ptr_logic;
  full   <= full_logic;
  empty  <= empty_logic;
  
end architecture behavioral;
