library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity comm_interface is
  port
  (
    clock       : in  std_logic;
    reset       : in  std_logic;
    lidar_dist  : in  std_logic_vector(15 downto 0);
    hcsr04_dist : in  std_logic_vector(15 downto 0);
    send_data   : in  std_logic;
    rx          : in  std_logic;
    tx          : out std_logic
  );
end entity comm_interface;

architecture behavioral of comm_interface is
  component uart is
    generic
    (
      DBIT    : natural := 8;
      SB_TICK : natural := 16;
      FIFO_W  : natural := 2
    );
    port
    (
      clock    : in  std_logic;
      reset    : in  std_logic;
      rd_uart  : in  std_logic;
      wr_uart  : in  std_logic;
      rx       : in  std_logic;
      w_data   : in  std_logic_vector(DBIT-1 downto 0);
      divisor  : in  std_logic_vector(10 downto 0);
      tx_full  : out std_logic;
      rx_empty : out std_logic;
      tx       : out std_logic;
      r_data   : out std_logic_vector(DBIT-1 downto 0)
    );
  end component uart;

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


  signal rd_uart : std_logic;
  signal wr_uart : std_logic;
  signal r_data  : std_logic_vector(7 downto 0);
  signal w_data  : std_logic_vector(7 downto 0);
  constant divisor : std_logic_vector(10 downto 0) := "00000011011"; -- 27 in binary
  signal tx_full  : std_logic;
  signal rx_empty : std_logic;

  signal buffer_inputs : std_logic;
  signal lidar_dist_buf : std_logic_vector(15 downto 0);
  signal hcsr04_dist_buf : std_logic_vector(15 downto 0);
  
  signal w_data_src : std_logic_vector(1 downto 0);

  type state_type is (idle, lidar_byte0, lidar_byte1, hcsr04_byte0, hcsr04_byte1);
  signal state, next_state : state_type;
  
begin
  
  uart_inst: uart
  generic map
  (
    DBIT    => 8,
    SB_TICK => 16,
    FIFO_W  => 4
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    rd_uart  => rd_uart,
    wr_uart  => wr_uart,
    rx       => rx,
    w_data   => w_data,
    divisor  => divisor,
    tx_full  => tx_full,
    rx_empty => rx_empty,
    tx       => tx,
    r_data   => r_data
  );

  lidar_buf: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => lidar_dist,
    data_out => lidar_dist_buf
  );
  
  hcsr04_buf: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => hcsr04_dist,
    data_out => hcsr04_dist_buf
  );
  
  fsm: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process fsm;

  fsm_logic: process(state, send_data, tx_full)
  begin
    buffer_inputs <= '0';
    w_data_src <= "00";
    wr_uart <= '0';

    case state is
      when idle =>
        if send_data = '1' then
          buffer_inputs <= '1';
          next_state <= lidar_byte0;
        else
          next_state <= idle;
        end if;

      when lidar_byte0 =>
        w_data_src <= "00";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= lidar_byte1;
        else
          next_state <= lidar_byte0;
        end if;

      when lidar_byte1 =>
        w_data_src <= "01";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= hcsr04_byte0;
        else
          next_state <= lidar_byte1;
        end if;

      when hcsr04_byte0 =>
        w_data_src <= "10";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= hcsr04_byte1;
        else
          next_state <= hcsr04_byte0;
        end if;

      when hcsr04_byte1 =>
        w_data_src <= "11";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= idle;
        else
          next_state <= hcsr04_byte1;
        end if;

      when others =>
        next_state <= idle; 

    end case;
    
  end process fsm_logic;

  rd_uart <= '0';

  with w_data_src select
    w_data <= lidar_dist_buf(7 downto 0) when "00",
              lidar_dist_buf(15 downto 8) when "01",
              hcsr04_dist_buf(7 downto 0) when "10",
              hcsr04_dist_buf(15 downto 8) when others;
  
end architecture behavioral;
