--! \file
--! \brief VHDL file for a divisor datapath.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

--! \brief Entity representing the divisor datapath.
--! This entity includes the interface for the divisor datapath including system signals, control inputs and outputs, and data inputs and outputs.
entity divisor_dpath is
  port
  (
    -- system signals
    clock : in  std_logic; --! Clock signal.
    reset : in  std_logic; --! Reset signal.

    -- control inputs
    load             : in std_logic; --! Load signal.
    shift_quotient   : in std_logic; --! Signal to shift the quotient.
    set_quotient_bit : in std_logic; --! Signal to set a bit in the quotient.
    shift_divisor    : in std_logic; --! Signal to shift the divisor.
    restore_sub      : in std_logic; --! Signal to restore after subtraction.
    write_remainder  : in std_logic; --! Signal to write the remainder.

    -- control outputs
    neg_remainder : out std_logic; --! Output signal indicating negative remainder.
    finished      : out std_logic; --! Output signal indicating completion.
  
    -- data inputs and outputs
    dividend  : in  std_logic_vector(15 downto 0); --! Input dividend.
    divisor   : in  std_logic_vector(15 downto 0); --! Input divisor.
    quotient  : out std_logic_vector(31 downto 0); --! Output quotient.
    remainder : out std_logic_vector(31 downto 0)  --! Output remainder.
  );
end entity divisor_dpath;

architecture structural of divisor_dpath is
  -- Component and signal declarations...

begin
  --! Behavioral part of the architecture.

  --! Logic for shifting the quotient register.
  with shift_quotient select
    quotient_reg_in <= quotient_reg_out(quotient_reg_out'LENGTH-2 downto 0) & set_quotient_bit when '1',
                       (others => '0') when others;
  quotient_reg_en <= load or shift_quotient; 

  --! Instantiation of the quotient register.
  quotient_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => quotient_reg_en,
    data_in  => quotient_reg_in,
    data_out => quotient_reg_out
  );
  
  --! Logic for shifting the divisor register.
  with shift_divisor select
    divisor_reg_in <= "0" & divisor_reg_out(divisor_reg_out'LENGTH-1 downto 1) when '1',
                      divisor & x"0000" when others;
  divisor_reg_en <= load or shift_divisor; 

  --! Instantiation of the divisor register.
  divisor_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => divisor_reg_en,
    data_in  => divisor_reg_in,
    data_out => divisor_reg_out
  );

  --! Logic for selecting the adder's second operand based on restore_sub signal.
  with restore_sub select
    b <= divisor_reg_out when '1',
         not divisor_reg_out when others;
  c_in <= not restore_sub;

  --! Instantiation of the Sklansky adder.
  adder: sklansky_adder
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    a     => remainder_reg_out,
    b     => b,
    c_in  => c_in,
    c_out => open,
    s     => s
  );

  --! Logic for loading or updating the remainder register.
  with load select
    remainder_reg_in <= x"0000" & dividend when '1',
                        s when others;

  remainder_reg_reset <= reset;
  remainder_reg_en <= write_remainder or load;

  --! Instantiation of the remainder register.
  remainder_reg: register_d
  generic map
  (
    WIDTH => 32
  )
  port map
  (
    clock    => clock,
    reset    => remainder_reg_reset,
    enable   => remainder_reg_en,
    data_in  => remainder_reg_in,
    data_out => remainder_reg_out
  );

  --! Logic for controlling the iteration counter.
  iteration_counter_reset <= reset or load;
  iteration_counter: sync_par_counter
  generic map
  (
    MODU => 18
  )
  port map
  (
    clock  => clock,
    reset  => iteration_counter_reset,
    cnt_en => shift_quotient,
    q_in   => (others => '0'),
    load   => '0',
    q      => iteration_count
  );

  --! Logic for determining the negative remainder and completion status.
  neg_remainder <= remainder_reg_out(remainder_reg_out'LENGTH-1) or divisor_reg_out(divisor_reg_out'LENGTH-1);
  finished <= '1' when iteration_count = "10001" else
              '0';
  --! Assigning output signals for quotient and remainder.
  remainder <= remainder_reg_out;
  quotient <= x"0000" & quotient_reg_out;

end architecture structural;
