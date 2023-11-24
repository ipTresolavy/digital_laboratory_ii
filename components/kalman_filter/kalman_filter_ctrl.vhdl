library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kalman_filter_ctrl is
  port
  (
    -- system signals
    clock : in std_logic;
    reset : in std_logic;

    -- handshake signals
    i_valid : in  std_logic;
    o_valid : out std_logic;
    ready   : out std_logic;

    -- control inputs
    mult_ready : in std_logic;
    div_ready  : in std_logic;

    -- control outputs
    buffer_inputs : out std_logic;
    x_src, p_src  : out std_logic_vector(1 downto 0);
    x_en, p_en    : out std_logic;
    diff_src      : out std_logic;
    mult_src      : out std_logic;
    mult_valid    : out std_logic;
    div_src       : out std_logic;
    div_valid     : out std_logic;
    add_src       : out std_logic;
    pred_en       : out std_logic
  );
end entity kalman_filter_ctrl;

architecture behavioral of kalman_filter_ctrl is
  type state_type is (init_idle, init_regs, predict, update_idle, update_lidar_x_mult_init, update_lidar_x_mult_end, update_lidar_x_div_init, update_lidar_x_div_end, update_lidar_x_add, update_lidar_p_mult_init, update_lidar_p_mult_end, update_lidar_p_div_init, update_lidar_p_div_end, update_lidar_p_add, update_hcsr04_x_mult_init, update_hcsr04_x_mult_end, update_hcsr04_x_div_init, update_hcsr04_x_div_end, update_hcsr04_x_add, update_hcsr04_p_mult_init, update_hcsr04_p_mult_end, update_hcsr04_p_div_init, update_hcsr04_p_div_end, update_hcsr04_p_add);
  
  signal state, next_state : state_type;
  
begin
  
  state_latch: process(clock, reset)
  begin
    if reset = '1' then
      state <= init_idle;
    elsif rising_edge(clock) then
      state <= next_state; 
    end if;
  end process state_latch;
  
  next_state_logic: process(state, i_valid, mult_ready, div_ready)
  begin
    ready <= '0';
    buffer_inputs <= '0';
    x_src <= "00";
    p_src <= "00";
    x_en  <= '0';
    p_en  <= '0';
    pred_en <= '0';
    diff_src   <= '0';
    mult_src   <= '0';
    mult_valid <= '0';
    div_src   <= '0';
    div_valid <= '0';
    add_src <= '0';
    o_valid <= '0';

    case state is
      when init_idle =>
        ready <='1';
        if i_valid = '1' then
          buffer_inputs <= '1';
          next_state <= init_regs;
        else
          next_state <= init_idle;
        end if;

      when init_regs =>
        x_src <= "11";
        p_src <= "11";
        x_en  <= '1';
        p_en  <= '1';
        next_state <= predict;

      when predict =>
        x_en       <= '1';
        p_en       <= '1';
        pred_en    <= '1';
        next_state <= update_idle;

      when update_idle =>
        ready <='1';
        if i_valid = '1' then
          buffer_inputs <= '1';
          next_state <= update_lidar_x_mult_init;
        else
          next_state <= update_idle;
        end if;

      when update_lidar_x_mult_init =>
        diff_src   <= '1';
        mult_valid <= '1';
        if mult_ready = '0' then
          next_state <= update_lidar_x_mult_end;
        else
          next_state <= update_lidar_x_mult_init;
        end if;

      when update_lidar_x_mult_end =>
        diff_src   <= '1';
        if mult_ready = '1' then
          next_state <= update_lidar_x_div_init;
        else
          next_state <= update_lidar_x_mult_end;
        end if;

      when update_lidar_x_div_init =>
        div_src   <= '1';
        div_valid <= '1';
        if div_ready = '0' then
          next_state <= update_lidar_x_div_end;
        else 
          next_state <= update_lidar_x_div_init;
        end if;

      when update_lidar_x_div_end =>
        div_src   <= '1';
        if div_ready = '1' then
          next_state <= update_lidar_x_add;
        else 
          next_state <= update_lidar_x_div_end;
        end if;

      when update_lidar_x_add =>
        x_src <= "10";
        x_en <= '1';
        next_state <= update_lidar_p_mult_init;

      when update_lidar_p_mult_init =>
        mult_src   <= '1';
        mult_valid <= '1';
        if mult_ready = '0' then
          next_state <= update_lidar_p_mult_end;
        else
          next_state <= update_lidar_p_mult_init;
        end if;

      when update_lidar_p_mult_end =>
        mult_src   <= '1';
        if mult_ready = '1' then
          next_state <= update_lidar_p_div_init;
        else
          next_state <= update_lidar_p_mult_end;
        end if;

      when update_lidar_p_div_init =>
        div_src   <= '1';
        div_valid <= '1';
        if div_ready = '0' then
          next_state <= update_lidar_p_div_end;
        else
          next_state <= update_lidar_p_div_init;
        end if;

      when update_lidar_p_div_end =>
        div_src <= '1';
        if div_ready = '1' then
          next_state <= update_lidar_p_add;
        else
          next_state <= update_lidar_p_div_end;
        end if;

      when update_lidar_p_add =>
        add_src <= '1';
        p_src <= "10";
        p_en <= '1';
        next_state <= update_hcsr04_x_mult_init;

      when update_hcsr04_x_mult_init =>
        mult_valid <= '1';
        if mult_ready = '0' then
          next_state <= update_hcsr04_x_mult_end;
        else
          next_state <= update_hcsr04_x_mult_init;
        end if;

      when update_hcsr04_x_mult_end =>
        if mult_ready = '1' then
          next_state <= update_hcsr04_x_div_init;
        else
          next_state <= update_hcsr04_x_mult_end;
        end if;

      when update_hcsr04_x_div_init =>
        div_valid <= '1';
        if div_ready = '0' then
          next_state <= update_hcsr04_x_div_end;
        else 
          next_state <= update_hcsr04_x_div_init;
        end if;

      when update_hcsr04_x_div_end =>
        if div_ready = '1' then
          next_state <= update_hcsr04_x_add;
        else 
          next_state <= update_hcsr04_x_div_end;
        end if;

      when update_hcsr04_x_add =>
        x_src <= "10";
        x_en <= '1';
        next_state <= update_hcsr04_p_mult_init;

      when update_hcsr04_p_mult_init =>
        mult_src   <= '1';
        mult_valid <= '1';
        if mult_ready = '0' then
          next_state <= update_hcsr04_p_mult_end;
        else
          next_state <= update_hcsr04_p_mult_init;
        end if;

      when update_hcsr04_p_mult_end =>
        mult_src   <= '1';
        if mult_ready = '1' then
          next_state <= update_hcsr04_p_div_init;
        else
          next_state <= update_hcsr04_p_mult_end;
        end if;

      when update_hcsr04_p_div_init =>
        div_valid <= '1';
        if div_ready = '0' then
          next_state <= update_hcsr04_p_div_end;
        else
          next_state <= update_hcsr04_p_div_init;
        end if;

      when update_hcsr04_p_div_end =>
        if div_ready = '1' then
          next_state <= update_hcsr04_p_add;
        else
          next_state <= update_hcsr04_p_div_end;
        end if;

      when update_hcsr04_p_add =>
        add_src <= '1';
        p_src <= "10";
        p_en <= '1';
        o_valid <= '1';
        next_state <= predict;

      when others =>
        next_state <= init_idle;
    end case;
  end process next_state_logic;
end architecture behavioral;
