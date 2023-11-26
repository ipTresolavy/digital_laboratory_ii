--! @file
--! @brief VHDL module for communication interface.
--! @details This module provides the communication logic for interfacing with external devices,
--!          including UART transmission of sensor data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! @entity comm_interface
--! @brief Entity for communication interface.
entity comm_interface is
  port
  (
    clock             : in  std_logic; --! @brief System clock signal.
    reset             : in  std_logic; --! @brief System reset signal.
    lidar_dist        : in  std_logic_vector(15 downto 0); --! @brief Distance measurement from LiDAR sensor.
    hcsr04_dist       : in  std_logic_vector(15 downto 0); --! @brief Distance measurement from HC-SR04 sensor.
    dist_estimate     : in  std_logic_vector(15 downto 0);
    send_data         : in  std_logic; --! @brief Signal to initiate data transmission.
    rx                : in  std_logic; --! @brief UART receive signal.
    tx                : out std_logic  --! @brief UART transmit signal.
  );
end entity comm_interface;

architecture behavioral of comm_interface is
  -- Component declarations
  component uart is
    generic
    (
      DBIT    : natural := 8; --! @brief Data bits.
      SB_TICK : natural := 16; --! @brief Stop bits.
      FIFO_W  : natural := 2 --! @brief FIFO width.
    );
    port
    (
      clock    : in  std_logic; --! @brief System clock signal.
      reset    : in  std_logic; --! @brief System reset signal.
      rd_uart  : in  std_logic; --! @brief UART read signal.
      wr_uart  : in  std_logic; --! @brief UART write signal.
      rx       : in  std_logic; --! @brief UART receive signal.
      w_data   : in  std_logic_vector(DBIT-1 downto 0); --! @brief Data to write to UART.
      divisor  : in  std_logic_vector(10 downto 0); --! @brief Baud rate divisor.
      tx_full  : out std_logic; --! @brief UART transmit buffer full signal.
      rx_empty : out std_logic; --! @brief UART receive buffer empty signal.
      tx       : out std_logic; --! @brief UART transmit signal.
      r_data   : out std_logic_vector(DBIT-1 downto 0) --! @brief Data read from UART.
    );
  end component uart;

  component register_d is
    generic
    (
      WIDTH : natural := 8 --! @brief Width of the register.
    );
    port
    (
      clock         : in  std_logic; --! @brief System clock signal.
      reset         : in  std_logic; --! @brief System reset signal.
      enable        : in  std_logic; --! @brief Enable signal for the register.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! @brief Input data for the register.
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! @brief Output data of the register.
    );
  end component register_d;

  -- Signal declarations
  signal rd_uart : std_logic;
  signal wr_uart : std_logic;
  signal r_data  : std_logic_vector(7 downto 0);
  signal w_data  : std_logic_vector(7 downto 0);
  constant divisor : std_logic_vector(10 downto 0) := "00000011011"; --! @brief 27 in binary, sets the baud rate.
  signal tx_full  : std_logic;
  signal rx_empty : std_logic;

  signal buffer_inputs     : std_logic;
  signal lidar_dist_buf    : std_logic_vector(15 downto 0);
  signal hcsr04_dist_buf   : std_logic_vector(15 downto 0);
  signal dist_estimate_buf : std_logic_vector(15 downto 0);
  
  signal w_data_src : std_logic_vector(2 downto 0);

  -- State machine for controlling data transmission
  type state_type is (idle, lidar_byte0, lidar_byte1, hcsr04_byte0, hcsr04_byte1, estimate_byte0, estimate_byte1, newline);
  signal state, next_state : state_type;
  
begin
  
  -- UART instantiation
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

  -- Buffer registers for sensor data
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
  
  estimate_buf: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buffer_inputs,
    data_in  => dist_estimate,
    data_out => dist_estimate_buf
  );
  
  -- Finite state machine for controlling the data transmission process
  fsm: process(clock, reset)
  begin
    if reset = '1' then
      state <= idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process fsm;

  -- Logic for the finite state machine
  fsm_logic: process(state, send_data, tx_full)
  begin
    buffer_inputs <= '0';
    w_data_src <= "000";
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
        w_data_src <= "000";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= lidar_byte1;
        else
          next_state <= lidar_byte0;
        end if;

      when lidar_byte1 =>
        w_data_src <= "001";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= hcsr04_byte0;
        else
          next_state <= lidar_byte1;
        end if;

      when hcsr04_byte0 =>
        w_data_src <= "010";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= hcsr04_byte1;
        else
          next_state <= hcsr04_byte0;
        end if;

      when hcsr04_byte1 =>
        w_data_src <= "011";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= estimate_byte0;
        else
          next_state <= hcsr04_byte1;
        end if;

      when estimate_byte0 =>
        w_data_src <= "100";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= estimate_byte1;
        else
          next_state <= estimate_byte0;
        end if;

      when estimate_byte1 =>
        w_data_src <= "101";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= newline;
        else
          next_state <= estimate_byte1;
        end if;

      when newline =>
        w_data_src <= "111";
        wr_uart <= '1';
        if tx_full = '0' then
          next_state <= idle;
        else
          next_state <= newline;
        end if;

      when others =>
        next_state <= idle; 

    end case;
    
  end process fsm_logic;

  rd_uart <= '0';

  -- Data selection for UART transmission based on current state
  with w_data_src select
    w_data <= lidar_dist_buf(7 downto 0) when "000",
              lidar_dist_buf(15 downto 8) when "001",
              hcsr04_dist_buf(7 downto 0) when "010",
              hcsr04_dist_buf(15 downto 8) when "011",
              dist_estimate_buf(7 downto 0) when "100",
              dist_estimate_buf(15 downto 8) when "101",
              x"13" when "110",
              x"0A" when others;
  
end architecture behavioral;
