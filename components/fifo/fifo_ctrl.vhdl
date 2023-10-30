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

  component sync_par_counter is
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

  -- ponteiro de escrita
  signal w_ptr_logic_reset : std_logic;
  signal w_ptr_logic_cnt_en : std_logic;
  signal w_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0);
  
  -- ponteiro de leitura
  signal r_ptr_logic_reset : std_logic;
  signal r_ptr_logic_cnt_en : std_logic;
  signal r_ptr_logic : std_logic_vector(ADDR_WIDTH-1 downto 0);

  -- registrador que guarda a última operação realizada
  signal last_op_en  : std_logic;
  signal last_op_out : std_logic_vector(1 downto 0);

  signal full_logic  : std_logic;
  signal empty_logic : std_logic;

  signal wr_rd : std_logic_vector(1 downto 0);

begin

  w_ptr_logic_reset <= reset;
  w_ptr_logic_counter: sync_par_counter
  generic map
  (
    MODU => 2**ADDR_WIDTH
  )
  port map
  (
    clock => clock,
    reset => w_ptr_logic_reset,
    cnt_en => w_ptr_logic_cnt_en,
    q => w_ptr_logic
  );

  r_ptr_logic_reset <= reset;
  r_ptr_logic_counter: sync_par_counter
  generic map
  (
    MODU => 2**ADDR_WIDTH
  )
  port map
  (
    clock => clock,
    reset => r_ptr_logic_reset,
    cnt_en => r_ptr_logic_cnt_en,
    q => r_ptr_logic
  );

  last_op_reg: register_d
  generic map
  (
    WIDTH => 2
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    enable => last_op_en,
    data_in => wr_rd,
    data_out => last_op_out
  );

  wr_rd <= wr & rd;

  next_state_logic: process(full_logic, empty_logic, wr_rd)
  begin
    r_ptr_logic_cnt_en <= '0';
    w_ptr_logic_cnt_en <= '0';
    last_op_en <= '0';
    
    case wr_rd is
      when "01" =>
        if empty_logic = '0' then
          r_ptr_logic_cnt_en <= '1';
          last_op_en <= '1';
        end if; 

      when "10" =>
        if full_logic = '0' then
          w_ptr_logic_cnt_en <= '1';
          last_op_en <= '1';
        end if;

      when "11" =>
        w_ptr_logic_cnt_en <= '1';
        r_ptr_logic_cnt_en <= '1';

      when others =>

    end case;
  end process next_state_logic;

  full_logic  <= '1' when ((last_op_out = "10") and (w_ptr_logic = r_ptr_logic)) else
                 '0';

  empty_logic <= '1' when ((((last_op_out = "01") ) and (w_ptr_logic = r_ptr_logic)) or (last_op_out = "00"))else
                 '0';

  w_addr <= w_ptr_logic;
  r_addr <= r_ptr_logic;
  full   <= full_logic;
  empty  <= empty_logic;
  
end architecture behavioral;
