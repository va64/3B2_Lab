library ieee;
use ieee.std_logic_1164.all;
use ieee. std_logic_unsigned.all;

entity tlc is
	port (
		i_clk, i_rst_l, i_rqst_l, i_cntr_stop_l : in std_logic;
		o_vred, o_vamber, o_vgreen : out std_logic;	--vehicle lights
		o_pred, o_pgreen : out std_logic;					--pedestrian lights
		
		o_Segment0_A  : out std_logic;
		o_Segment0_B  : out std_logic;
		o_Segment0_C  : out std_logic;
		o_Segment0_D  : out std_logic;
		o_Segment0_E  : out std_logic;
		o_Segment0_F  : out std_logic;
		o_Segment0_G  : out std_logic;
		
		o_Segment1_A  : out std_logic;
		o_Segment1_B  : out std_logic;
		o_Segment1_C  : out std_logic;
		o_Segment1_D  : out std_logic;
		o_Segment1_E  : out std_logic;
		o_Segment1_F  : out std_logic;
		o_Segment1_G  : out std_logic
	);
end tlc;



architecture rtl of tlc is


	---DECLARE 7-SEG-DISP------
	component Binary_To_7Segment is
		port(
			i_Clk        : in  std_logic;
			i_Binary_Num : in  std_logic_vector(3 downto 0);
			o_Segment_A  : out std_logic;
			o_Segment_B  : out std_logic;
			o_Segment_C  : out std_logic;
			o_Segment_D  : out std_logic;
			o_Segment_E  : out std_logic;
			o_Segment_F  : out std_logic;
			o_Segment_G  : out std_logic
		);
	end component;
	
	
	

	-------CONSTANTS---------------
	constant c_ty : integer range 0 to 250000000 := 250000000;   -- 5 seconds for a 50MHz clock
	constant c_tpedestrian : integer range 0 to 500000000 := 500000000;  -- 10 seconds
	constant c_tdelay : integer range 0 to 500000000 := 500000000;  -- 10 seconds

	-------CONTROL SIGNALS---------
	type t_SM_main is (IDLE, REQUEST, PEDESTRIAN, DELAY);
	signal r_SM_main : t_SM_main := IDLE;
	signal r_rqst_mem : std_logic := '0';
	
	-------TIMING SIGNALS----------
	signal r_ty : integer range 0 to c_ty := c_ty;
	signal r_tpedestrian : integer range 0 to c_tpedestrian := c_tpedestrian;
	signal r_tdelay : integer range 0 to c_tdelay := c_tdelay;
	
	-------LIGHT SIGNALS-----------
	signal r_vehicle : std_logic_vector(2 downto 0) := "001";			--- [ red | amber | green ]
	signal r_pedestrian : std_logic_vector(1 downto 0) := "10";		--- [ red | green ]

	----PEDESTRIAN 7-SEG. DISP.----
	signal r_ped_counter : std_logic_vector(7 downto 0) := (others => '0');
	
	signal w_Segment0_A : std_logic;
	signal w_Segment0_B : std_logic;
	signal w_Segment0_C : std_logic;
	signal w_Segment0_D : std_logic;
	signal w_Segment0_E : std_logic;
	signal w_Segment0_F : std_logic;
	signal w_Segment0_G : std_logic;
	
	signal w_Segment1_A : std_logic;
	signal w_Segment1_B : std_logic;
	signal w_Segment1_C : std_logic;
	signal w_Segment1_D : std_logic;
	signal w_Segment1_E : std_logic;
	signal w_Segment1_F : std_logic;
	signal w_Segment1_G : std_logic;

begin


	---INSTANTIATE 7SEG.DISP. FOR PEDESTRIANS----
	PED7SD0 : Binary_To_7Segment 
		port map(
			i_Clk        => i_clk,
			i_Binary_Num => r_ped_counter(3 downto 0),
			o_Segment_A  => w_Segment0_A,
			o_Segment_B  => w_Segment0_B,
			o_Segment_C  => w_Segment0_C,
			o_Segment_D  => w_Segment0_D,
			o_Segment_E  => w_Segment0_E,
			o_Segment_F  => w_Segment0_F,
			o_Segment_G  => w_Segment0_G
		);
		
		PED7SD1 : Binary_To_7Segment 
		port map(
			i_Clk        => i_clk,
			i_Binary_Num => r_ped_counter(7 downto 4),
			o_Segment_A  => w_Segment1_A,
			o_Segment_B  => w_Segment1_B,
			o_Segment_C  => w_Segment1_C,
			o_Segment_D  => w_Segment1_D,
			o_Segment_E  => w_Segment1_E,
			o_Segment_F  => w_Segment1_F,
			o_Segment_G  => w_Segment1_G
		);



	Traffic_controller : process (i_clk, i_rst_l) is
	begin
	
		if i_rst_l = '0' then
			r_SM_main <= IDLE;  		--reset command returns the system to its initial state
			
		elsif rising_edge(i_clk) then
		
			case r_SM_main is      -- state machine checks state every cycle
			
			
			
				when IDLE =>
						
					r_vehicle <= "001";
					r_pedestrian <= "10";		--initial state lights
					
					if r_rqst_mem = '1' then   --first check if the button had been pressed during the 10 sec delay
						r_sM_main <= REQUEST;
						r_rqst_mem <= '0';
					elsif i_rqst_l = '0' then     --check if the pedestrian button is pressed
						r_sM_main <= REQUEST;   --move on to the request state
					end if;
					
					
									
				when REQUEST =>
				
					r_vehicle <= "010";
					r_pedestrian <= "10";		--request state lights. Amber vehicle light for 5 seconds;
					
					if r_ty > 0 then
						r_ty <= r_ty - 1;
					else
						r_ty <= c_ty;	--reset counter
						r_SM_main <= PEDESTRIAN;   --change to next state
					end if;
					
				
				
				when PEDESTRIAN =>
				
					r_vehicle <= "100";
					r_pedestrian <= "01";		--pedestrians allowed to pass for 10 seconds
					
					if (r_tpedestrian > 0) then
						if i_cntr_stop_l = '1' then
							r_tpedestrian <= r_tpedestrian - 1;
						end if;
					else
						r_tpedestrian <= c_tpedestrian;
						r_SM_main <= DELAY;
					end if;
					
					
					
					---Display the pedestrian 10-second countdown on the 7-segment display---
					
					--check time to drive the 7-segment display
					if r_tpedestrian > 450000000 then
						r_ped_counter <= "00010000";  --10
					elsif r_tpedestrian > 400000000 then
						r_ped_counter <= "00001001";  --9
					elsif r_tpedestrian > 350000000 then
						r_ped_counter <= "00001000";  --8
					elsif r_tpedestrian > 300000000 then
						r_ped_counter <= "00000111";  --7
					elsif r_tpedestrian > 250000000 then
						r_ped_counter <= "00000110";  --6
					elsif r_tpedestrian > 200000000 then
						r_ped_counter <= "00000101";  --5
					elsif r_tpedestrian > 150000000 then
						r_ped_counter <= "00000100";  --4
					elsif r_tpedestrian > 100000000 then
						r_ped_counter <= "00000011";  --3
					elsif r_tpedestrian > 50000000 then
						r_ped_counter <= "00000010";  --2
					elsif r_tpedestrian > 0 then
						r_ped_counter <= "00000001";  --1
					else
						r_ped_counter <= "00000000";
					end if;
					
					
				when DELAY =>
				
					r_ped_counter <= "00000000"; --zero out the pedestrian counter
					
					r_vehicle <= "001";
					r_pedestrian <= "10";
					
					if r_tdelay > 0 then
						r_tdelay <= r_tdelay - 1;
					else
						r_tdelay <= c_tdelay;
						r_SM_main <= IDLE;
					end if;
					
					if i_rqst_l = '0' then
						r_rqst_mem <= '1';
					end if;
					
					
				
				when others =>        --check unknown states to avoid unexpected behaviour. Send to IDLE state
					r_SM_main <= IDLE;
			
			
			end case;
		
		end if;
		
		
	end process;


	---Output signal assignment---
	o_vred <= r_vehicle(2);
	o_vamber <= r_vehicle(1);
	o_vgreen <= r_vehicle(0);
	
	o_pred <= r_pedestrian(1);
	o_pgreen <= r_pedestrian(0);	
	
	o_Segment0_A  <= not w_Segment0_A;
	o_Segment0_B  <= not w_Segment0_B;
	o_Segment0_C  <= not w_Segment0_C;
	o_Segment0_D  <= not w_Segment0_D;
	o_Segment0_E  <= not w_Segment0_E;
	o_Segment0_F  <= not w_Segment0_F;
	o_Segment0_G  <= not w_Segment0_G;
	
	o_Segment1_A  <= not w_Segment1_A;
	o_Segment1_B  <= not w_Segment1_B;
	o_Segment1_C  <= not w_Segment1_C;
	o_Segment1_D  <= not w_Segment1_D;
	o_Segment1_E  <= not w_Segment1_E;
	o_Segment1_F  <= not w_Segment1_F;
	o_Segment1_G  <= not w_Segment1_G;
	
end rtl;