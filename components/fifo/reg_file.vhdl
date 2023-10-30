library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity reg_file is
  generic
  (
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 2
  );
  port
  (
    clock  : in  std_logic;
    reset  : in  std_logic;
    wr_en  : in  std_logic;
    w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
     
  );
end entity reg_file ;

architecture structural of reg_file is

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

    type array_reg_type is array (2**ADDR_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_mux_outs : array_reg_type;

    signal reg_write_enables : std_logic_vector(2**ADDR_WIDTH-1 downto 0);

begin

  g_registers: for i in 0 to 2**ADDR_WIDTH-1 generate
    reg_write_enables(i) <= '1' when ((w_addr = std_logic_vector(to_unsigned(i, w_addr'LENGTH))) and wr_en = '1') else
                            '0';
    reg: register_d
    generic map
    (
      WIDTH => DATA_WIDTH 
    )
    port map
    (
      clock    => clock,
      reset    => reset,
      enable   => reg_write_enables(i),
      data_in  => w_data,
      data_out => reg_mux_outs(i)
    );
  end generate g_registers;
 
  r_data <= reg_mux_outs(to_integer(unsigned(r_addr)));
 
end architecture structural;
