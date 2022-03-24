-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity morse_top_TB is
end morse_top_TB;

architecture TB of morse_top_TB is

	--declare component
    component top is
        generic (
        CLK_HALF_PERIOD : integer := 5;
        MAX_WORD_LENGTH : integer := 13
        );

        port (
            i_clk : in std_logic;
            i_rst_l : in std_logic;
            i_send : in std_logic;
            i_switch_select : in std_logic_vector(4 downto 0);
        	o_morse_led : out std_logic
        );
    end component top;

	--constants
	constant c_MAX_WORD_LENGTH : integer := 13;
    constant c_CLK_HALF_PERIOD : integer := 5;
    --clock
    signal r_clk : std_logic := '0';
    --i/o
    signal r_rst_l : std_logic := '0';
    signal r_send : std_logic := '0';
    signal r_switch_select : std_logic_vector(4 downto 0) := (others=>'0');
    signal w_morse_led : std_logic;



begin

	-- 50MHz Clock Generator:
	r_clk <= not r_clk after 10 ns;



	--Instantiate UUT
    UUT : entity work.morse_top
    generic map (
    	MAX_WORD_LENGTH      => c_MAX_WORD_LENGTH,
        CLK_HALF_PERIOD      => c_CLK_HALF_PERIOD
        )
    port map (
    	i_clk                => r_clk,
        i_rst_l              => r_rst_l,
        i_send               => r_send,
        i_switch_select      => r_switch_select,
        
        o_morse_led          => w_morse_led
        );
        
        
        
	process
    begin
    
    
    
   		r_rst_l <= '0';
        wait for 4 ns;


        
        r_rst_l <= '1';
        wait for 10 ns;
        
        
        
        --letter A
        r_switch_select <= "00000";
        wait for 4 ns;
        r_send <= '1';
        wait for 20 ns;
        r_send <= '0';
        wait;
               
    end process;
	

end TB;
