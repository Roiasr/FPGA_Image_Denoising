library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.System_Package.all;

entity Image_Line_Processor is 
port (
      clk       : in std_logic;
      rst       : in std_logic;
      data_in   : in std_logic_vector(Row_Bits - 1 downto 0);
      Fixed_Row : out std_logic_vector(Row_Bits - 1 downto 0)
);

end entity;

architecture arch_Image_Line_Processor of Image_Line_Processor is

signal buffers : Buff_t;

begin

process(clk,rst) is
begin
   if (rst='1') then
       buffers <= (others => (others => (others => '0')));
   elsif rising_edge(clk) then
          buffers(0) <= buffers(1);
          buffers(1) <= buffers(2);
          buffers(2) <= Pad_And_Convert(data_in);
    end if;
end process;

gen_Mask_3X3 : for i in 1 to Image_Width generate
signal Mask_temp : Mask_3X3 := (others => (others => (others => '0'))); 
begin
    Mask_temp(0)(0)<= buffers(0)(i-1);
    Mask_temp(0)(1)<= buffers(0)(i);
    Mask_temp(0)(2)<= buffers(0)(i+1);
     
    Mask_temp(1)(0)<= buffers(1)(i-1);
    Mask_temp(1)(1)<= buffers(1)(i);
    Mask_temp(1)(2)<= buffers(1)(i+1);

    Mask_temp(2)(0)<= buffers(2)(i-1);
    Mask_temp(2)(1)<= buffers(2)(i);
    Mask_temp(2)(2)<= buffers(2)(i+1);

Fixed_Row((Row_Bits - Pixel_Bits * (i-1)-1) downto (Row_Bits - Pixel_Bits * (i)))<= MoM(Mask_temp); 
end generate gen_Mask_3X3;

end architecture arch_Image_Line_Processor;

    
