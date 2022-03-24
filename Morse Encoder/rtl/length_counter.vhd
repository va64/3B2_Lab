--This entity takes the binary representation of a morse symbol (std_signal_vector)
--and outputs the length of the word as an unsigned binary number
--It will always be at most decimal 13 so the ouput will be a 4 bit std_signal_vector
--A valid signal will be pulsed once the counting is over
--the conversion is triggered by a control pulse, i_count_start

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity length_counter is
	generic (
    -- length of largest morse code in binary form
    -- 11 is enough for the first 8 letters. 13 is needed for whole alphabet
    MAX_WORD_LENGTH : integer := 13
    );
    
	port (
    	i_clk : in std_logic;
        i_rst_l : in std_logic;
        i_letter_bin : in std_logic_vector(MAX_WORD_LENGTH-1 downto 0);
        i_count_start : in std_logic;
        o_length : out std_logic_vector(3 downto 0);
        o_length_DV : out std_logic
    );
end length_counter;




architecture rtl of length_counter is
	
    --Registered I/O signals
	signal r_letter_bin : std_logic_vector(MAX_WORD_LENGTH-1 downto 0) := (others => '0');
    signal r_length : std_logic_vector(3 downto 0) := (others => '0');
    signal r_length_DV : std_logic := '0';
    
    --Control signals
    signal r_count_en : std_logic := '0';
    
    --Counting signals
    signal r_zero_counter : integer range 0 to 3 := 0;
    signal r_bit_counter : integer range 0 to MAX_WORD_LENGTH := 0;
    signal r_word_index : integer range 0 to MAX_WORD_LENGTH := MAX_WORD_LENGTH-1;
    


begin


	BIT_COUNT : process (i_clk, i_rst_l) is
    begin
    	if i_rst_l = '0' then
        	--reset necessary signals
        	r_word_index <= MAX_WORD_LENGTH-1;
         	r_bit_counter <= 0;
      		r_zero_counter <= 0;
            r_length <= (others => '0');
            
        
        elsif rising_edge(i_clk) then
        	--default value of DV signal is '0'.
            --Once triggered, the pulse will last one clock cycle
            r_length_DV <= '0';
        
        
        	--latch the start signal and the input binary data
        	if i_count_start = '1' then
            	r_count_en <= '1';
                r_letter_bin <= i_letter_bin;
                --reset signals to prepare for new count
                r_word_index <= MAX_WORD_LENGTH-1;
                r_bit_counter <= 0;
                r_zero_counter <= 0;
            end if;    
            
            --only count if ...
            if r_count_en = '1' then
                --read every bit by indexing the input binary
            	if r_word_index > 0 then
                	r_bit_counter <= r_bit_counter + 1;
                    
                    if r_letter_bin(r_word_index) = '0' then
                    	r_zero_counter <= r_zero_counter + 1;
                    else
                    	r_zero_counter <= 0;
                    end if;
                    
                    --once a second consecutive zero is detected, the word is over
                    if r_zero_counter = 2 then
                    	r_count_en <= '0';
                        --assign the integer as a 4-bit unsigned std_logic_vector
                        --subtract 2 because we have counted two extra bits
                        r_length <= std_logic_vector(to_unsigned((r_bit_counter-2),r_length'length));
                        r_length_DV <= '1';   
                    end if;
                    
                	r_word_index <= r_word_index - 1;
                else
                	--reached index zero.
                    --Now consider the last bit 
                    if r_letter_bin(r_word_index) = '1' then
                    	r_length <= std_logic_vector(to_unsigned((r_bit_counter+1),r_length'length));
                    elsif r_letter_bin(r_word_index) = '0' then
                    	if r_zero_counter = 1 then
                        	r_length <= std_logic_vector(to_unsigned((r_bit_counter-1),r_length'length));
                    	else
                    		r_length <= std_logic_vector(to_unsigned((r_bit_counter+1),r_length'length));
                        end if;
                    end if;
                	--Stop counting and trigger DV.
                    r_count_en <= '0';
                    r_length_DV <= '1';
                end if;
            end if;
        
        end if;
    end process BIT_COUNT;



	--output signal assignment
    o_length <= r_length;
    o_length_DV <= r_length_DV;
    
end rtl;

