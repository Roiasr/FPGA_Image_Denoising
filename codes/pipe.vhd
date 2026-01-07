library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.System_Package.all;

entity pipe is 
generic (
     Colour_File  : string;
     Colour_Ram   : string
);

port (
     clk         : in  std_logic;
     rst         : in  std_logic;
     aclr        : in  std_logic;
     Rom_address : in  std_logic_vector(Address_bits - 1 downto 0);
     Ram_address : in  std_logic_vector(Address_bits - 1 downto 0);
     ram_en      : in  std_logic;
     data_out    : out std_logic_vector(Row_Bits - 1 downto 0)
);

end entity;

architecture arch_pipe of pipe is

signal data_in   : std_logic_vector(Row_Bits - 1 downto 0);
signal Fixed_Row : std_logic_vector(Row_Bits - 1 downto 0);

begin

U1 : entity work.Image_Line_Processor
port map (
     clk     => clk,
     rst     => rst,
     data_in => data_in,
     Fixed_Row => Fixed_Row
);

U2 : entity work.rom1 
generic map(Colour_File => Colour_File)
port map (  
     aclr    => aclr, 
     address => Rom_address,
     clock   => clk, 
     q       => data_in
);

U3 : entity work.Ram
generic map(Colour_Ram => Colour_Ram)
port map (
     aclr    => aclr,
     address => Ram_address,
     clock   => clk,
     data    => Fixed_Row,
     wren    => ram_en,
     q       => data_out
);

end architecture arch_pipe; 



 


