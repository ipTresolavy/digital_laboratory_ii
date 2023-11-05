library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_comm_interface is
end entity tb_comm_interface;

architecture sim of tb_comm_interface is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal lidar_dist       : std_logic_vector(15 downto 0) := (others => '0');
  signal hcsr04_dist      : std_logic_vector(15 downto 0) := (others => '0');
  signal send_data        : std_logic := '0';
  signal rx               : std_logic := '0';
  signal tx               : std_logic;

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant bitPeriod   : time := 8681 ns; -- 115200 baud rate

  component comm_interface is
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
  end component comm_interface;

  type comm_data_type is record
    id   : integer;
    lidar_data : std_logic_vector(15 downto 0);
    hcsr04_data : std_logic_vector(15 downto 0);
  end record;

  type comm_data_array is array (natural range <>) of comm_data_type;
  constant comm_data_test: comm_data_array := (
    (0, "1010101010101010", "0101010101010101"),
    (1, "1110001011100010", "1111001011100011"),
    (2, "1111000011110000", "1111000011110011"),
    (3, "1111111111111111", "1111111111111000"),
    (4, "0000000000000000", "0000000000000111")
  );

  begin
    
    uut_comm_interface: comm_interface
    port map
    (
      clock       => clock,
      reset       => reset,
      lidar_dist  => lidar_dist,
      hcsr04_dist => hcsr04_dist,
      send_data   => send_data,
      rx          => rx,
      tx          => tx
    );

    -- Clock process
    clock <= not clock after clockPeriod / 2;

    stimulus_process : process
    begin
      -- Reset the system
      reset <= '1';
      wait for clockPeriod;
      reset <= '0';

    for i in comm_data_test'range loop
        -- Simulate data sending
        lidar_dist <= comm_data_test(i).lidar_data;
        hcsr04_dist <= comm_data_test(i).hcsr04_data;
        wait until falling_edge(clock);
        send_data <= '1';
        wait until falling_edge(clock);
        send_data <= '0';
        
        wait until tx = '0';
        wait for bitPeriod; -- Wait for one full baud period
        
        -- Receive 8 data bits
        for j in 0 to 7 loop
          assert tx = comm_data_test(i).lidar_data(j) 
            report "lidar data bit failed: " & std_logic'image(comm_data_test(i).lidar_data(j))
            severity error;
          wait for bitPeriod; -- Wait for one full baud period
        end loop;

        assert tx = '1' report "[lidar_byte0] stop bit failed: " & integer'image(comm_data_test(i).id) severity error;

        wait until tx = '0';
        wait for bitPeriod; -- Wait for one full baud period

        for j in 8 to 15 loop
          assert tx = comm_data_test(i).lidar_data(j) 
            report "lidar data bit failed: " & std_logic'image(comm_data_test(i).lidar_data(j))
            severity error;
          wait for bitPeriod; -- Wait for one full baud period
        end loop;

        assert tx = '1' report "[lidar_byte1] stop bit failed: " & integer'image(comm_data_test(i).id) severity error;

        wait until tx = '0';
        wait for bitPeriod; -- Wait for one full baud period

        for j in 0 to 7 loop
          assert tx = comm_data_test(i).hcsr04_data(j) 
            report "HC-SR04 data bit failed: " & std_logic'image(comm_data_test(i).hcsr04_data(j))
            severity error;
          wait for bitPeriod; -- Wait for one full baud period
        end loop;

        assert tx = '1' report "[hcsr04_byte0] stop bit failed: " & integer'image(comm_data_test(i).id) severity error;

        wait until tx = '0';
        wait for bitPeriod; -- Wait for one full baud period

        for j in 8 to 15 loop
          assert tx = comm_data_test(i).hcsr04_data(j) 
            report "HC-SR04 data bit failed: " & std_logic'image(comm_data_test(i).hcsr04_data(j))
            severity error;
          wait for bitPeriod; -- Wait for one full baud period
        end loop;

        assert tx = '1' report "[hcsr04_byte1] stop bit failed: " & integer'image(comm_data_test(i).id) severity error;
      end loop;

      -- Finish the simulation
      report "Calling 'stop'";
      stop;
      wait;
    end process stimulus_process;

  end architecture sim;

