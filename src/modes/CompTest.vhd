library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CompTest is
    generic(NoBits: integer := 12);
    Port ( Red_duty : out STD_LOGIC;
           Green_duty : out STD_LOGIC;
           Blue_duty : out STD_LOGIC;
           StartTest : in STD_LOGIC;
           EndTest : out STD_LOGIC;
           Duration : in STD_LOGIC_VECTOR (11 downto 0);
           Reset : in STD_LOGIC;
           CLK100MHZ: in std_logic);
end CompTest;

architecture Behavioral of CompTest is

    ----
    constant NoEvents: integer := 3 * (2 ** NoBits);
    constant TIME_SPAN_MS: integer := 10000 / 8; 
    ----

    component PWMClockGen is
        generic(MAX_CNT : integer := 20_000);
        Port ( Clk_in : in STD_LOGIC;       -- 100MHz
               Clk_out : out STD_LOGIC);    -- 5 kHz
    end component;


    component PWMGen is
        generic(NoBits: integer);
        Port ( Duty : in STD_LOGIC_VECTOR (NoBits - 1 downto 0);
               Clk : in STD_LOGIC;
               PWM_Out : out STD_LOGIC);
    end component;

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

    signal Clk_5kHz : STD_LOGIC;

    signal Red_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');
    signal Green_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');
    signal Blue_comp : STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');

    
    type State_type is (Idle, Red, Green, Blue, Done);
    signal state: State_type := Idle;
    
    signal Tick: STD_LOGIC := '0';

begin

    proc_cycle_state: process(Tick, Reset, StartTest)
        
    begin
        if Reset = '1' then
            state <= Idle;
            Red_comp <= (others => '0');
            Green_comp <= (others => '0');
            Blue_comp <= (others => '0');
            EndTest <= '0';
            
        elsif rising_edge(Tick) then
            
            case state is
                when Idle =>
                    EndTest <= '0';
                    Red_comp <= (others => '0');
                    Green_comp <= (others => '0');
                    Blue_comp <= (others => '0');

                    if StartTest = '1' then
                        state <= Red;

                    end if;

                when Red =>
                    if unsigned(Red_comp) = (2 ** NoBits - 1) then
                        Red_comp <= (others => '0');
                        state <= Green;
                    else
                        Red_comp <= std_logic_vector(unsigned(Red_comp) + 1);
                    end if;

                when Green =>
                    if unsigned(Green_comp) = (2 ** NoBits - 1) then
                        Green_comp <= (others => '0');
                        state <= Blue;
                    else
                        Green_comp <= std_logic_vector(unsigned(Green_comp) + 1);
                    end if;

                when Blue =>
                    if unsigned(Blue_comp) = (2 ** NoBits - 1) then
                        Blue_comp <= (others => '0');
                        state <= Done;
                        EndTest <= '1';
                    else
                        Blue_comp <= std_logic_vector(unsigned(Blue_comp) + 1);
                    end if;

                when Done =>
                    if StartTest = '0' then
                        state <= Idle;
                    end if;

                when others =>
                    null;
            end case;

        end if;

    end process;

    
    compTickGen: TickGen generic map(TIME_SPAN_MS, NoEvents)
                         port map(CLK100MHZ, Duration, Reset, Tick);

    clock_gen: PWMClockGen port map(CLK100MHZ, Clk_5kHz);
    pulse_gen_blue: PWMGen generic map(NoBits) port map(Blue_comp, Clk_5kHz, Blue_duty);
    pulse_gen_green: PWMGen generic map(NoBits) port map(Green_comp, Clk_5kHz, Green_duty);
    pulse_gen_red: PWMGen generic map(NoBits) port map(Red_comp, Clk_5kHz, Red_duty);
end Behavioral;
                         


