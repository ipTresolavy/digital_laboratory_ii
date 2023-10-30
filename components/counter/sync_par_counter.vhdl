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

  signal en_vector  : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal and_vector : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  signal q_vector   : std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
  
begin

  en_vector(0) <= cnt_en;
  en_vector(en_vector'LENGTH-1 downto 1) <= q_vector(q_vector'LENGTH-2 downto 0);

  g_regs: for i in 0 to natural(ceil(log2(real(MODU))))-1 generate
    and_vector(i) <= and en_vector(i downto 0);
    
    reg: t_flip_flop
    port map
    (
      clock => clock,
      reset => reset,
      en    => and_vector(i),
      q     => q_vector(i)
    );
  end generate g_regs;

  q <= q_vector;
  
end architecture behavioral;
