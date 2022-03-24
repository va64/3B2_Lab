library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_gen is
	generic (
    	 CLK_HALF_PERIOD : integer := 5 --low value for simulation. Use 25,000,000 i_clk pulses(for 50 MHz clk)
    );
    
    port (
    	i_clk : in std_logic;
        i_rst_l : in std_logic;
        i_clk_en : in std_logic;
        
        o_slow_clk : out std_logic
    );
end entity;




architecture rtl of clock_gen is
	
    signal r_slow_clk : std_logic := '0';
    signal r_clk_count : integer range 0 to CLK_HALF_PERIOD := CLK_HALF_PERIOD - 1;

begin

	 
    CLK_GEN : process(i_clk, i_rst_l) is
    begin
    	if i_rst_l = '0' then
        	--reset signals
            r_slow_clk <= '0';
            r_clk_count <= CLK_HALF_PERIOD - 1;
            
        elsif rising_edge(i_clk) then
        
        	if i_clk_en = '1' then
            	if r_clk_count > 0 then
                	r_clk_count <= r_clk_count - 1;
                else
                	r_slow_clk <= not r_slow_clk;
                    r_clk_count <= CLK_HALF_PERIOD - 1;
                end if;
            else
            	r_slow_clk <= '0';
            end if;
            
        end if;
    end process CLK_GEN;
    
    o_slow_clk <= r_slow_clk;

end architecture;