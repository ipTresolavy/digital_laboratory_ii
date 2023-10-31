library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity lidar_ctrl is
  port
  (
    clock       : in  std_logic;
    reset       : in  std_logic;
    rx_empty    : in  std_logic;
    r_data      : in  std_logic_vector(7 downto 0);
    rd_uart     : out std_logic;
    dist_l      : out std_logic_vector(7 downto 0);
    dist_h      : out std_logic_vector(7 downto 0)
  );
end entity lidar_ctrl;

architecture structural of lidar_ctrl is

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

  type state_type is (initial, wait_rx_fifo, byte0, byte1, byte2, byte3);
  signal state, next_state : state_type;
  signal state_return, next_state_return : state_type;
  signal state_return_en : std_logic;

  signal r_data_buf: std_logic_vector(7 downto 0);
  signal r_data_buf_en : std_logic;

  signal dist_l_en : std_logic;
  signal dist_h_en : std_logic;

begin

  r_data_buffer: register_d
  generic map
  (
    WIDTH => 8
  )
  port map
  (
    clock => clock,
    reset =>  reset,
    enable => r_data_buf_en,
    data_in => r_data,
    data_out => r_data_buf
  );

  dist_l_reg: register_d
  generic map
  (
    WIDTH => 8
  )
  port map
  (
    clock => clock,
    reset =>  reset,
    enable => dist_l_en,
    data_in => r_data_buf,
    data_out => dist_l
  );

  dist_h_reg: register_d
  generic map
  (
    WIDTH => 8
  )
  port map
  (
    clock => clock,
    reset =>  reset,
    enable => dist_h_en,
    data_in => r_data_buf,
    data_out => dist_h
  );

  fsm: process(clock, reset)
  begin
    if reset = '1' then
      state <= initial; 
      state_return <= initial;
    elsif rising_edge(clock) then
      state <= next_state; 
      if state_return_en = '1' then
        state_return <= next_state_return;
      end if;
    end if;
  end process fsm;

  next_state_logic: process(state, rx_empty, r_data_buf, state_return)
  begin
    rd_uart <= '0'; 
    next_state <= initial;
    next_state_return <= initial;
    state_return_en <= '0';
    r_data_buf_en <= '0';
    dist_l_en <='0';
    dist_h_en <= '0';

    case state is
      when initial =>
        next_state <= wait_rx_fifo;

        next_state_return <= byte0;
        state_return_en <= '1';

      when wait_rx_fifo =>
        if rx_empty = '0' then
          r_data_buf_en <= '1';
          next_state <= state_return;
        else
          next_state <= wait_rx_fifo;
        end if;
       
      when byte0 =>
        rd_uart <= '1';
        if r_data_buf = x"59" then
          next_state <= wait_rx_fifo;

          next_state_return <= byte1;
          state_return_en <= '1';
        else
          next_state <= initial;
        end if;

      when byte1 =>
        rd_uart <= '1';
        if r_data_buf = x"59" then
          next_state <= wait_rx_fifo;

          next_state_return <= byte2;
          state_return_en <= '1';
        else
          next_state <= initial;
        end if;

      when byte2 =>
        rd_uart <= '1';
        next_state <= wait_rx_fifo;

        dist_l_en <= '1';
        next_state_return <= byte3;
        state_return_en <= '1';

      when byte3 =>
        rd_uart <= '1';
        next_state <= wait_rx_fifo;

        dist_h_en <= '1';
        next_state_return <= initial;
        state_return_en <= '1';

      when others =>
        next_state <= wait_rx_fifo;

    end case;
  end process next_state_logic;
  
end architecture structural;
