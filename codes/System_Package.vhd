library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

package System_Package is

constant Pixel_Bits   : integer := 5;
constant Image_Width  : integer := 256;
constant Image_Height : integer := 256;
constant Row_Bits     : integer := Image_Width*Pixel_Bits;
constant Address_bits : integer := 8;

subtype Pixel_t is std_logic_vector(Pixel_Bits-1 downto 0);

type Row_Pixel is array (0 to 2) of Pixel_t;
type Mask_3X3  is array (0 to 2) of Row_Pixel;

type Row_t is array (0 to Image_Width + 1) of Pixel_t;
type Buff_t is array (0 to 2) of Row_t;

function Median_of_3(a, b, c : Pixel_t) return Pixel_t;
function MoM(mask : Mask_3X3) return Pixel_t;
function Pad_And_Convert(vec : std_logic_vector(Row_Bits - 1 downto 0)) return Row_t;

end System_Package;

package body System_Package is


function median_of_3(a, b, c : Pixel_t) return Pixel_t is
variable m : Pixel_t;

begin
    
if ((a <= b and a >= c) or (a >= b and a <= c)) then
        m := a;
    elsif ((b <= a and b >= c) or (b >= a and b <= c)) then
        m := b;
    else
        m := c;
    end if;
    return m;

end median_of_3;

function MoM(mask : Mask_3X3) return Pixel_t is
variable Median_Rows : Row_Pixel;
variable Med_of_Med  : Pixel_t;

begin

    for i in 0 to 2 loop
        Median_Rows(i) := Median_of_3(mask(i)(0), mask(i)(1), mask(i)(2));
    end loop;
    Med_of_Med := Median_of_3(Median_Rows(0), Median_Rows(1), Median_Rows(2));
    return Med_of_Med;

end MoM;

function Pad_And_Convert(vec : std_logic_vector(Row_Bits - 1 downto 0)) return Row_t is
variable row : Row_t;
variable idx : integer;

begin
        for i in 1 to Image_Width loop
            idx := Image_Width - i;
            row(i) := vec( (idx*Pixel_Bits)+ (Pixel_Bits - 1) downto (idx*Pixel_Bits) );
        end loop;
        row(0)   := row(1);
        row(Image_Width + 1) := row(Image_Width); 
        return row;

end Pad_And_Convert;

end System_Package;








 