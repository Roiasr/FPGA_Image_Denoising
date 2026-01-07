library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.System_Package.all;

entity Top_Level is
port (
     clk   : in std_logic;
     rst   : in std_logic;
     start : in std_logic;
     done  : out std_logic
	 );
      attribute altera_chip_pin_lc: string;
      attribute altera_chip_pin_lc of clk  : signal is "Y2";
      attribute altera_chip_pin_lc of rst  : signal is "AB28";
      attribute altera_chip_pin_lc of start: signal is "AC28";
      attribute altera_chip_pin_lc of done : signal is "E21";
end entity;

architecture arch_Top_Level of Top_Level is 
    signal Rom_Address_Sig : std_logic_vector(Address_bits - 1 downto 0);
    signal Ram_Address_Sig : std_logic_vector(Address_bits - 1 downto 0);
    signal aclr_sig        : std_logic;
    signal ram_en_sig 	   : std_logic;
    signal data_out_r      : std_logic_vector(Row_Bits - 1 downto 0);   
    signal data_out_g      : std_logic_vector(Row_Bits - 1 downto 0); 
    signal data_out_b      : std_logic_vector(Row_Bits - 1 downto 0); 

begin

state_machine : entity work.Fsm
    port map(
        clk         => clk,                     
        reset       => rst,                      
        start       => start,                      
        rom_address => Rom_Address_Sig,  
        ram_address => Ram_Address_Sig,
        ram_en      => ram_en_sig,
        done        => done,                   
        aclr        => aclr_sig
    );

 red : entity work.pipe 
    generic map(Colour_File => "Lena_r.mif", Colour_Ram => "Red_File")
    port map (
    
       clk         => clk,
       rst         => rst,
       aclr        => aclr_sig,      
       Rom_address => Rom_Address_Sig, 
       Ram_address => Ram_Address_Sig,
       ram_en      => ram_en_sig,
       data_out    => data_out_r
);

green : entity work.pipe 
    generic map(Colour_File => "Lena_g.mif", Colour_Ram => "Green_File")
    port map (
    
       clk         => clk,
       rst         => rst,
       aclr        => aclr_sig,      
       Rom_address => Rom_Address_Sig, 
       Ram_address => Ram_Address_Sig,
       ram_en      => ram_en_sig,
       data_out    => data_out_g
);

blue : entity work.pipe 
    generic map(Colour_File => "Lena_b.mif", Colour_Ram => "Blue_File")
    port map (
    
       clk         => clk,
       rst         => rst,
       aclr        => aclr_sig,      
       Rom_address => Rom_Address_Sig, 
       Ram_address => Ram_Address_Sig,
       ram_en      => ram_en_sig,
       data_out    => data_out_b
);

end architecture arch_Top_Level;


 






