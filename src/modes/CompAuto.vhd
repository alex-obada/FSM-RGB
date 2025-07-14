library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CompAuto is
    generic(NoBits: integer := 10);
    Port ( Red_duty : out STD_LOGIC;
           Green_duty : out STD_LOGIC;
           Blue_duty : out STD_LOGIC;
           Start : in STD_LOGIC;
           Reset : in STD_LOGIC;
           CLK100MHZ: in std_logic);
end CompAuto;

architecture Behavioral of CompAuto is

    ----
    constant NoEvents: integer := 6 * (2 ** NoBits);
    constant TIME_SPAN_MS: integer := 10000 / 2; 
    ----

    component PWMClockGen is
        Port ( Clk_in : in STD_LOGIC;       -- 100MHz
               Clk_out : out STD_LOGIC);    -- 5 kHz
    end component;

    component PWMGen is
        generic(NoBits: integer);
        Port ( Duty : in STD_LOGIC_VECTOR (NoBits - 1 downto 0);
               Clk : in STD_LOGIC;
               PWM_Out : out STD_LOGIC);
    end component;

    signal Clk_5kHz : STD_LOGIC;


    component TickGen is
        generic(Duration_unit_ms: integer := 1000; -- 1s
                NoEvents: integer); 
        Port (
            CLK100MHZ : in std_logic;
            Duration : in std_logic_vector(11 downto 0);
            Reset : in std_logic;
            Tick : out std_logic
        );
    end component;

    signal Red_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');
    signal Green_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');
    signal Blue_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');

    
    type State_Type is (Red, G_Up, R_Down, B_Up, G_Down, R_Up, B_Down);
    signal state : State_Type := Red;
    signal counter: STD_LOGIC_VECTOR(NoBits - 1 downto 0);
    
    signal Tick: STD_LOGIC := '0';

begin

    proc_update_state: process(Tick, Reset)
    begin
        if Reset = '1' then
            state <= Red;
            Red_comp <= (others => '0');
            Green_comp <= (others => '0');
            Blue_comp <= (others => '0');
            counter <= (others => '0');
        elsif rising_edge(Tick) then
            case state is
                    
                when Red =>                                    
                    if Start = '1' then
                        counter <= (others => '0');
                        
                        Red_comp <= (others => '1');
                        Green_comp <= counter;
                        Blue_comp <= (others => '0');
                        
                        state <= G_Up;
                    end if;

                when G_Up =>
                    if unsigned(counter) = (2 ** NoBits - 1) then
                        counter <= (others => '1');

                        Red_comp <= counter;
                        Green_comp <= (others => '1');
                        Blue_comp <= (others => '0');

                        state <= R_Down;
                    else
                        counter <= std_logic_vector(unsigned(counter) + 1);
                        Green_comp <= counter;
                    end if;

                when R_Down =>
                    if unsigned(counter) = 0 then
                        counter <= (others => '0');
                        
                        Red_comp <= (others => '0');
                        Green_comp <= (others => '1');
                        Blue_comp <= counter;

                        state <= B_Up;
                    else
                        counter <= std_logic_vector(unsigned(counter) - 1);
                        Red_comp <= counter;
                    end if;

                when B_Up =>
                    if unsigned(counter) = (2 ** NoBits - 1) then
                        counter <= (others => '1');
                        
                        Red_comp <= (others => '0');
                        Green_comp <= counter;
                        Blue_comp <= (others => '1');

                        state <= G_Down;
                    else
                        counter <= std_logic_vector(unsigned(counter) + 1);
                        Blue_comp <= counter;
                    end if;

                when G_Down =>
                    if unsigned(counter) = 0 then
                        counter <= (others => '0');
                        
                        Red_comp <= counter;
                        Green_comp <= (others => '0');
                        Blue_comp <= (others => '1');

                        state <= R_Up;
                    else
                        counter <= std_logic_vector(unsigned(counter) - 1);
                        Green_comp <= counter;
                    end if;


                when R_Up =>
                    if unsigned(counter) = (2 ** NoBits - 1) then
                        counter <= (others => '1');
                        
                        Red_comp <= (others => '1');
                        Green_comp <= (others => '0');
                        Blue_comp <= counter;

                        state <= B_Down;
                    else
                        counter <= std_logic_vector(unsigned(counter) + 1);
                        Red_comp <= counter;
                    end if;

                when B_Down =>
                    if unsigned(counter) = 0 then
                        counter <= (others => '0');
                        
                        Red_comp <= (others => '1');
                        Green_comp <= counter;
                        Blue_comp <= (others => '0');

                        state <= G_Up;
                    else
                        counter <= std_logic_vector(unsigned(counter) - 1);
                        Blue_comp <= counter;
                    end if;
                
                when others => state <= Red;
            end case;
        end if;

    end process;


    compTickGen: TickGen generic map(TIME_SPAN_MS, NoEvents)
                         port map(CLK100MHZ, x"000", Reset, Tick);

    clock_gen: PWMClockGen port map(CLK100MHZ, Clk_5kHz);
    pulse_gen_blue: PWMGen generic map(NoBits) port map(Blue_comp, Clk_5kHz, Blue_duty);
    pulse_gen_green: PWMGen generic map(NoBits) port map(Green_comp, Clk_5kHz, Green_duty);
    pulse_gen_red: PWMGen generic map(NoBits) port map(Red_comp, Clk_5kHz, Red_duty);
end Behavioral;
                         


