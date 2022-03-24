library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity char_sel is
	
    port (
    	i_clk : in std_logic;
        i_sw_select : in std_logic_vector(4 downto 0);
        o_morse_bin : out std_logic_vector(12 downto 0)
    );
    
end entity;



architecture rtl of char_sel is

	signal r_morse_bin : std_logic_vector(12 downto 0);

begin

	process (i_clk) is
    begin
    	if rising_edge(i_clk) then
        	case i_sw_select is
            	when "00000" =>
            		r_morse_bin <= "1011100000000";
                when "00001" =>
                    r_morse_bin <= "1110101010000";
                when "00010" =>
                    r_morse_bin <= "1110101110100";
                when "00011" =>
                    r_morse_bin <= "1110101000000";
                when "00100" =>
                    r_morse_bin <= "1000000000000";      
                when "00101" =>
                    r_morse_bin <= "1010111010000";
                when "00110" =>
                    r_morse_bin <= "1110111010000";
                when "00111" =>
                    r_morse_bin <= "1010101000000";
                when "01000" =>
                    r_morse_bin <= "1010000000000";
                when "01001" =>
                    r_morse_bin <= "1011101110111";
                when "01010" =>
                    r_morse_bin <= "1110101110000";
                when "01011" =>
                    r_morse_bin <= "1011101010000";
                when "01100" =>
                    r_morse_bin <= "1110111000000";
                when "01101" =>
                    r_morse_bin <= "1110100000000";
                when "01110" =>
                    r_morse_bin <= "1110111011100";
                when "01111" =>
                    r_morse_bin <= "1011101110100";
                when "10000" =>
                    r_morse_bin <= "1110111010111";
                when "10001" =>
                    r_morse_bin <= "1011101000000";
                when "10010" =>
                    r_morse_bin <= "1010100000000";
                when "10011" =>
                    r_morse_bin <= "1110000000000";         
                when "10100" =>
                    r_morse_bin <= "1010111000000";
                when "10101" =>
                    r_morse_bin <= "1010101110000";
                when "10110" =>
                    r_morse_bin <= "1011101110000";
                when "10111" =>
                    r_morse_bin <= "1110101011100";
                when "11000" =>
                    r_morse_bin <= "1110101110111";
                when "11001" =>
                    r_morse_bin <= "1110111010100";
                when others  =>
                    r_morse_bin <= "1111111111111";
                
            end case;
        end if;
    end process;

    o_morse_bin <= r_morse_bin;

end architecture rtl;