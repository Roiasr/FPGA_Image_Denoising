library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;    
use ieee.std_logic_unsigned.all; 
use work.System_Package.all;

entity Fsm is
    port(
        clk         : in  std_logic;                      
        reset       : in  std_logic;                      
        start       : in  std_logic;                      

        rom_address : out std_logic_vector(Address_bits - 1 downto 0);   
        ram_address : out std_logic_vector(Address_bits - 1 downto 0);   

        ram_en      : out std_logic;              
        done        : out std_logic;                       
        aclr        : out std_logic
    );
end entity;

architecture arch_Fsm of Fsm is

    signal rom_row : std_logic_vector(Address_bits - 1 downto 0);
    signal ram_row : std_logic_vector(Address_bits - 1 downto 0);

    signal ram_en_delay_chain : std_logic_vector(3 downto 0);
    signal pipeline_valid_in : std_logic;

    signal dup_cnt : integer range 0 to 2;

    type fsm_st is (S_IDLE, S_FIRST_ROW, S_MIDDLE_ROWS, S_LAST_ROW, S_DONE);
    signal state : fsm_st;

begin
 
    rom_address <= rom_row;
    ram_address <= ram_row;
    
    ram_en <= ram_en_delay_chain(3); 

    fsm_proc : process(clk, reset)
    begin
        if reset = '1' then
            state              <= S_IDLE;
            rom_row            <= (others=>'0');
            ram_row            <= (others=>'0');
            pipeline_valid_in  <= '0'; 
            done               <= '0';
            aclr               <= '1';
            ram_en_delay_chain <= (others => '0');

        elsif rising_edge(clk) then
            ram_en_delay_chain <= ram_en_delay_chain(2 downto 0) & pipeline_valid_in;
            
            if ram_en_delay_chain(3) = '1' then
                 if ram_row < Image_Height - 1 then
                    ram_row <= ram_row + 1;
                 end if;
            end if;

            pipeline_valid_in <= '0';
            done <= '0';
            aclr <= '0';

            case state is

                when S_IDLE =>
                    if start = '1' then
                        rom_row <= (others => '0');
                        ram_row <= (others => '0');
                        dup_cnt <= 0;
                        state   <= S_FIRST_ROW;
                    end if;

                when S_FIRST_ROW =>
                    pipeline_valid_in <= '1';
                    if dup_cnt = 0 then
                        dup_cnt <= 1;
                    else
                        dup_cnt <= 0;
                        rom_row <= rom_row + 1; 
                        state   <= S_MIDDLE_ROWS;
                    end if;

                when S_MIDDLE_ROWS =>
                    pipeline_valid_in <= '1';

                    if rom_row < Image_Height - 1 then
                        rom_row <= rom_row + 1;
                    else
                        pipeline_valid_in <= '0';
                        state   <= S_LAST_ROW;
                    end if;

                when S_LAST_ROW =>
                    if ram_row = Image_Height - 1 and ram_en_delay_chain(3) = '0' then
                       state <= S_DONE;
                    end if;
                
                when S_DONE =>
                    done <= '1';
                    if start = '0' then
                        state <= S_IDLE;
                    end if;

            end case;
        end if;
    end process;

end architecture arch_Fsm;