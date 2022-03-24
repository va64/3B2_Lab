library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is

	generic (
    	 CLK_HALF_PERIOD : integer := 25000000;
         MAX_WORD_LENGTH : integer := 13

    );
    
	port (
    	i_clk : in std_logic;
        i_rst_l : in std_logic;
        i_send : in std_logic;
        i_switch_select : in std_logic_vector(4 downto 0);
        o_morse_led : out std_logic
    );
end top;




architecture rtl of top is



	---DECLARE COMPONENTS--------
    -----------------------------
    component clock_gen is
        generic (
            CLK_HALF_PERIOD : integer-- := 5
        );
        port (
            i_clk : in std_logic;
            i_rst_l : in std_logic;
            i_clk_en : in std_logic;
            o_slow_clk : out std_logic
        );
	end component;
    -----------------------------
    component char_sel is
        port (
          i_clk : in std_logic;
          i_sw_select : in std_logic_vector(4 downto 0);
          o_morse_bin : out std_logic_vector(12 downto 0)
        );
    end component;
    -----------------------------
    component length_counter is
        generic (
        MAX_WORD_LENGTH : integer-- := 13
        );
        port (
            i_clk : in std_logic;
            i_rst_l : in std_logic;
            i_letter_bin : in std_logic_vector(MAX_WORD_LENGTH-1 downto 0);
            i_count_start : in std_logic;
            o_length : out std_logic_vector(3 downto 0);
            o_length_DV : out std_logic
        );
	end component;
    -----------------------------
    component morse_top is
        generic (
             MAX_WORD_LENGTH : integer-- := 13
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
    end component;
    ------------------------------
    
    
    
    
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
    
    ---CONNECTING SIGNALS---
    signal w_clk_en : std_logic := '0';
    signal w_slow_clk : std_logic;
    signal w_morse_bin : std_logic_vector(12 downto 0);
    signal w_count_start : std_logic := '0';
    signal w_length : std_logic_vector(3 downto 0);
    signal w_length_DV : std_logic;
    signal w_morse_led : std_logic;
    signal w_switch_select : std_logic_vector(4 downto 0);
	

begin

	


	---INSTANTIATE COMPONENTS----
    -----------------------------
    CLKGEN0: entity work.clock_gen 
        generic map(
            CLK_HALF_PERIOD => CLK_HALF_PERIOD
        )
        port map(
            i_clk           => i_clk,
            i_rst_l         => i_rst_l,
            i_clk_en        => w_clk_en,
            o_slow_clk      => w_slow_clk
        );
    -----------------------------
    CHAR0: entity work.char_sel
        port map(
          i_clk             => i_clk,
          i_sw_select       => w_switch_select,
          o_morse_bin       => w_morse_bin
        );
    -----------------------------
    LEN0: entity work.length_counter
        generic map(
        	MAX_WORD_LENGTH     => MAX_WORD_LENGTH
        )
        port map(
            i_clk           => i_clk,
            i_rst_l         => i_rst_l,
            i_letter_bin    => w_morse_bin,
            i_count_start   => w_count_start,
            o_length        => w_length,
            o_length_DV     => w_length_DV
        );
    -----------------------------
    MORSE0: entity work.morse_top
        generic map(
             MAX_WORD_LENGTH    => MAX_WORD_LENGTH
        )
        port map (
            i_clk           => i_clk,
            i_rst_l         => i_rst_l,
            i_send          => i_send,
            i_morse_bin     => w_morse_bin,
            i_length        => w_length,
            i_length_DV     => w_length_DV,
            i_slow_clk      => w_slow_clk,
            o_count_start   => w_count_start,
            o_clk_en        => w_clk_en,
            o_morse_led     => o_morse_led
        );
    -----------------------------



end architecture rtl;