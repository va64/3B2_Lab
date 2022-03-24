library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity morse_top is

	generic (
         MAX_WORD_LENGTH : integer := 13
    );
    
	port (
    	i_clk : in std_logic;
        i_rst_l : in std_logic;
        i_send : in std_logic;
        i_morse_bin : in std_logic_vector(MAX_WORD_LENGTH-1 downto 0);
        i_length : in std_logic_vector(3 downto 0);
        i_length_DV : in std_logic;
        i_slow_clk : in std_logic;
        o_count_start : out std_logic;
        o_clk_en : out std_logic;
        o_morse_led : out std_logic
    );
end morse_top;




architecture rtl of morse_top is


    
    
    
    
    -----SIGNAL DECLARATIONS-----
    
    ---CLK DETECTION----
    signal r_slow_clk_old : std_logic;
    signal r_leading_edge : std_logic;
    
    ---FSM----
    type t_FSM_MORSE is (READY, SAVE, TX);
    signal r_state : t_FSM_MORSE := SAVE;
    signal r_tx_ready : std_logic := '0';
    signal r_index : integer range 0 to 13;
    signal r_len : integer range 0 to 13;
    signal r_message : std_logic_vector(12 downto 0);
    signal r_message_complete : std_logic := '0';
    

    
	

begin
    
    
	---DETECT RISING EDGE OF SLOW CLOCK---
	slow_clk_edge : process(i_clk, i_slow_clk) is
    begin
    	if rising_edge(i_clk) then
        	--default to low
            r_leading_edge <= '0';
            --register slow clk
        	r_slow_clk_old <= i_slow_clk;
            if r_slow_clk_old = '0' and i_slow_clk = '1' then
            	r_leading_edge <= '1';
            end if;
        end if;
    end process;

    
    
    
    
    
    ---TX INITIATION---
    Transmit: process(i_clk) is
    begin
    	if rising_edge(i_clk) then
        	o_count_start <= '0';
            if r_tx_ready = '1' and i_send = '1' then  --button press = ground
            	o_count_start <= '1';
            end if;
        end if;
    end process;
    
    



	---MAIN PROCESS--------------
	xyz : process(i_clk, i_rst_l) is
    begin
    	if i_rst_l = '0' then
        	--reset process signals
            r_state <= READY;
            r_tx_ready <= '0';
            o_clk_en <= '0';
            r_message_complete <= '0';
            o_morse_led <= '0';
            
            
        elsif rising_edge(i_clk) then
        	case r_state is
            
                when READY =>
                    r_state <= SAVE;
                    r_tx_ready <= '1';
                    
                    
                when SAVE =>
                  --we can only expect a DV after the length counter has been triggered  
                	if i_length_DV = '1' then
                    	--register the morse message and its length (as an integer)
                    	r_index <= MAX_WORD_LENGTH - 1;--to_integer(unsigned(w_length));   --talk about this bug in the FTR
                    	r_len <= to_integer(unsigned(i_length)) - 1;
                        r_message <= i_morse_bin;
                        --stop accepting inputs
                        r_tx_ready <= '0';                         
                        --move on to TX state
                        r_state <= TX;
                        --RESET r_message_complete SIGNAL
                        r_message_complete <= '0';
                    end if;
                    
                
                when TX =>
                	--enable slow clock
                    o_clk_en <= '1';
                    
                	if r_leading_edge = '1' then
							--bug fix code
                        if r_len > 0 then
                    		o_morse_led <= r_message(r_index);
                    		r_index <= r_index - 1;
                    		r_len <= r_len - 1;
                        else
                        	o_morse_led <= r_message(r_index);
                            r_message_complete <= '1';
                        end if;
                    
                    end if;
                        
							--this won't work because r_message_complete is
							--reset on the next system clock pulse                      
--                	if r_leading_edge = '1' and r_message_complete = '1' then
--                    	--disable the slow clock and the led
--                    	r_morse_led <= '0';
--                        r_clk_en <= '0';
--                        r_state <= SAVE;
--                    end if;

							--FINAL FIX: NOW 
							
                    if r_message_complete = '1' and r_leading_edge = '1' then
                        --disable the slow clock and the led
                        o_morse_led <= '0';
                        o_clk_en <= '0';
                        r_message_complete <= '0';
                    
                        r_state <= READY; --basically wait for the last pulse to
                                          --be transmitted before accepting a new code
                    end if;
                        
                        
                when others =>
                	r_state <= READY;
                    
            end case;
        end if;
    end process xyz;

end architecture rtl;