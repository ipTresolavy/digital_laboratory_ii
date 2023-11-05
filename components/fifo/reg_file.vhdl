--! \file
--! \brief Register File Entity Implementation
--! 
--! This file contains the implementation of a register file with configurable data and address widths.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! \entity reg_file
--! \brief Register File Entity
--! 
--! The register file entity provides a set of registers that can be read and written.
entity reg_file is
  generic
  (
    DATA_WIDTH : natural := 8; --! \brief Width of the data bus.
    ADDR_WIDTH : natural := 2  --! \brief Width of the address bus.
  );
  port
  (
    clock  : in  std_logic; --! \brief Clock input.
    reset  : in  std_logic; --! \brief Reset input.
    wr_en  : in  std_logic; --! \brief Write enable input.
    w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Write address input.
    r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0); --! \brief Read address input.
    w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); --! \brief Data input for writing.
    r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)  --! \brief Data output for reading.
  );
end entity reg_file;

--! \architecture structural
--! \brief Structural Architecture of Register File
--! 
--! This architecture implements the register file using an array of D-type registers.
architecture structural of reg_file is

  --! \component register_d
  --! \brief D-Type Register Component
  --! 
  --! This component implements a D-type register used for storing data in the register file.
  component register_d is
    generic
    (
      WIDTH : natural := 8 --! \brief Width of the data bus.
    );
    port
    (
      clock         : in  std_logic; --! \brief Clock input.
      reset         : in  std_logic; --! \brief Reset input.
      enable        : in  std_logic; --! \brief Enable input.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! \brief Data input.
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! \brief Data output.
    );
  end component register_d;

  -- Internal signals
  type array_reg_type is array (2**ADDR_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0); --! \brief Array type for register outputs.
  signal reg_mux_outs : array_reg_type; --! \brief Register outputs signal array.

  signal reg_write_enables : std_logic_vector(2**ADDR_WIDTH-1 downto 0); --! \brief Register write enables signal array.

begin

  -- Register array generation
  g_registers: for i in 0 to 2**ADDR_WIDTH-1 generate
    -- Write enable logic for each register
    reg_write_enables(i) <= '1' when ((w_addr = std_logic_vector(to_unsigned(i, w_addr'LENGTH))) and wr_en = '1') else
                            '0';
    -- Register instantiation
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
 
  -- Read data output assignment
  r_data <= reg_mux_outs(to_integer(unsigned(r_addr)));
 
end architecture structural;
