library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sync_par_counter is
  generic
  (
    constant MODU : natural := 16
  );
  port (
    clock  : in  std_logic;
    reset  : in  std_logic;
    cnt_en : in  std_logic;
    q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)
  );
end entity sync_par_counter;

architecture behavioral of sync_par_counter is
  component t_flip_flop is
    port
    (
      clock : in  std_logic;
      reset : in  std_logic;
      en    : in  std_logic;
      q     : out std_logic
    );
  end component t_flip_flop;

  type and_array_type is array (natural(ceil(log2(real(MODU))))-1 downto 0) of std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal en_vector  : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal and_array  : and_array_type;
  signal q_vector   : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  
begin

  en_vector(0)  <= cnt_en;
  en_vector(en_vector'LENGTH-1 downto 1) <= q_vector(q_vector'LENGTH-2 downto 0);
  --g_first_bit: for i in 0 to natural(ceil(log2(real(MODU))))-1 generate
    --and_array(i)(0) <= cnt_en;
  --end generate g_first_bit;

  g_regs: for i in 0 to natural(ceil(log2(real(MODU))))-1 generate
    and_array(i)(0) <= cnt_en;
    g_test_cond: if i /= 0 generate
      g_ands: for j in 1 to i generate
        and_array(i)(j) <= and_array(i)(j-1) and en_vector(j);
      end generate g_ands;
    end generate g_test_cond;
    
    reg: t_flip_flop
    port map
    (
      clock => clock,
      reset => reset,
      en    => and_array(i)(i),
      q     => q_vector(i)
    );
  end generate g_regs;

  q <= q_vector;
  
end architecture behavioral;
