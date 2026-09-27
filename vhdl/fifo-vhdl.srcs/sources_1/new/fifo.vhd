library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

entity fifo is
    generic(
        DATA_WIDTH: integer := 16;
        FIFO_DEPTH: integer := 16
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        wr_en: in std_logic;
        rd_en: in std_logic;
        data_in: in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
        fifo_full: out std_logic;
        fifo_empty: out std_logic
     );
end fifo;



architecture rtl of fifo is

type mem_type is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal fifo_mem: mem_type;

--pointers
signal wr_pointer: integer range 0 to FIFO_DEPTH-1:= 0;
signal rd_pointer: integer range 0 to FIFO_DEPTH-1:= 0;

signal counter: integer range 0 to FIFO_DEPTH:= 0;

begin

process(clk) 
begin
    if rising_edge(clk) then
        if rst = '1' then
            data_out <= (others => '0');
            wr_pointer <= 0;
            rd_pointer <= 0;
            counter <= 0;
        
        else
        
-----------------------write only------------------------------------------------------------------------------------------------------------------            
            if (wr_en = '1' and rd_en = '0') and (counter < FIFO_DEPTH) then          --if write, not read and not full
                fifo_mem(wr_pointer) <= data_in;                                      --store data at current write pointer position

                counter <= counter + 1;                                               --write adds an element so increase counter
                
                if wr_pointer = FIFO_DEPTH - 1 then                                   --reset pointer if reached max depth
                    wr_pointer <= 0;
                else
                    wr_pointer <= wr_pointer + 1;                                     --shift write pointer by one place if max depth not reached
                end if;
            

-----------------------read only--------------------------------------------------------------------------------------------------------------------           
            elsif (rd_en = '1' and wr_en = '0') and (counter > 0) then                --if read, not write and not empty
                data_out <= fifo_mem(rd_pointer);                                     --output data at current read pointer position

                counter <= counter - 1;                                               --read removes an element so decrease counter
                
                if rd_pointer = FIFO_DEPTH - 1 then                                   --reset pointer if reached max depth
                    rd_pointer <= 0;
                else
                    rd_pointer <= rd_pointer + 1;                                     --shift read pointer by one place if max depth not reached
                end if;

            
-----------------------read & write-----------------------------------------------------------------------------------------------------------------          
            elsif rd_en = '1' and wr_en = '1' then
                if counter = 0 then                                                   --if fifo is empty, only do write, no read
                    fifo_mem(wr_pointer) <= data_in;
                    
                    counter <= counter + 1;
                    
                    --check only write pointer here
                    if wr_pointer = FIFO_DEPTH - 1 then                               --reset pointer if reached max depth
                        wr_pointer <= 0;
                    else
                        wr_pointer <= wr_pointer + 1;
                    end if;
                    
                    
                elsif counter = FIFO_DEPTH then                                       --if fifo is full, only do read, no write
                    data_out <= fifo_mem(rd_pointer);
                    
                    counter <= counter - 1;
                    
                    --check only read pointer here
                    if rd_pointer = FIFO_DEPTH - 1 then                               --reset pointer if reached max depth
                        rd_pointer <= 0;
                    else
                        rd_pointer <= rd_pointer + 1;                                 --shift read pointer by one place if max depth not reached
                    end if;
                    
                else                                                                  --if fifo is neither empty or full, do both read and write
                
                    fifo_mem(wr_pointer) <= data_in;                                  --write
                    data_out <= fifo_mem(rd_pointer);                                 --read
                    
                    --check both wr and rd pointer here    
                    if wr_pointer = FIFO_DEPTH - 1 then                               --reset pointer if reached max depth
                        wr_pointer <= 0;
                    else
                        wr_pointer <= wr_pointer + 1;                                 --shift write pointer by one place if max depth not reached
                    end if;
                    
                    
                    if rd_pointer = FIFO_DEPTH - 1 then                               --reset pointer if reached max depth
                        rd_pointer <= 0;
                    else
                        rd_pointer <= rd_pointer + 1;                                 --shift read pointer by one place if max depth not reached
                    end if;
                end if;
            

            end if;
        end if;
    end if;
end process;


fifo_empty <= '1' when (counter = 0) else '0';                                        --pulse fifo_empty signal high is counter is 0 (meaning fifo is empty)
fifo_full  <= '1' when (counter = FIFO_DEPTH) else '0';                               --pulse fifo_full signal high is counter is max depth (meaning fifo is full)


end rtl;
