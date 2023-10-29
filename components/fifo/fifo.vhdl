library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fifo is
  generic
  (
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 4
  );
  port
  (
    clock  : in  std_logic;
    reset  : in  std_logic;
    rd     : in  std_logic;
    wr     : in  std_logic;
    w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    empty  : out std_logic;
    full   : out std_logic;
    r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity fifo; 

architecture structural of fifo is
  
  component fifo_ctrl is
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
  end component fifo_ctrl;

  component reg_file is
    generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 2
    );
    port
    (
      wr_en  : in  std_logic;
      clock  : in  std_logic;
      w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
       
    );
  end component reg_file ;

  signal w_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal r_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal wr_en    : std_logic;
  signal full_tmp : std_logic;

begin
  
  wr_en <= wr and (not full_tmp);
  full  <= full_tmp;

  fifo_inst: fifo_ctrl
  generic map
  (
    ADDR_WIDTH => ADDR_WIDTH
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    rd     => rd,
    wr     => wr,
    empty  => empty,
    full   => full_tmp,
    w_addr => w_addr,
    r_addr => r_addr
  );

  registers: reg_file
  generic map
  (
    DATA_WIDTH => DATA_WIDTH,
    ADDR_WIDTH => ADDR_WIDTH
  )
  port map
  (
    clock  => clock,
    wr_en  => wr_en,
    w_addr => w_addr,
    r_addr => r_addr,
    w_data => w_data,
    r_data => r_data
  );
  
end architecture structural;
