library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( Mode : in STD_LOGIC_VECTOR (1 downto 0);     
           CLK100MHZ : in STD_LOGIC;                    
           SW : in STD_LOGIC_VECTOR (11 downto 0);      
           btnOk : in STD_LOGIC;
           btnReset : in STD_LOGIC;

           Anodes : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           Char : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

           LEDRed : out STD_LOGIC := '0';
           LEDGreen : out STD_LOGIC := '0';
           LEDBlue : out STD_LOGIC := '0';
           
           Indicators: out STD_LOGIC_VECTOR(13 downto 0) := (others => '0'));
end top;

architecture Behavioral of top is

    component displ7seg is
    Port ( Clk  : in  STD_LOGIC;
           Rst  : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
           An   : out STD_LOGIC_VECTOR (7 downto 0);    -- selectia anodului activ
           Seg  : out STD_LOGIC_VECTOR (7 downto 0));   -- selectia catozilor (segmentelor) cifrei active
    end component;


    component CompAuto is
        generic(NoBits: integer := 10);
        Port ( Red_duty : out STD_LOGIC;
               Green_duty : out STD_LOGIC;
               Blue_duty : out STD_LOGIC;
               Start : in STD_LOGIC;
               Reset : in STD_LOGIC;
               CLK100MHZ: in std_logic);
    end component;

    component CompTest is
        generic(NoBits: integer := 8);
        Port ( Red_duty : out STD_LOGIC;
               Green_duty : out STD_LOGIC;
               Blue_duty : out STD_LOGIC;
               StartTest : in STD_LOGIC;
               EndTest : out STD_LOGIC;
               Duration : in STD_LOGIC_VECTOR (11 downto 0);
               Reset : in STD_LOGIC;
               CLK100MHZ: in std_logic);
    end component;

    component MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           en : out STD_LOGIC);
    end component;

    component ManualComp is
        Port ( CLK100MHZ : in STD_LOGIC;
               Red_duty : in STD_LOGIC_VECTOR (3 downto 0);
               Green_duty : in STD_LOGIC_VECTOR (3 downto 0);
               Blue_duty : in STD_LOGIC_VECTOR (3 downto 0);
               Red_out : out STD_LOGIC;
               Green_out : out STD_LOGIC;
               Blue_out : out STD_LOGIC);
    end component;

    type STATE_TYPE is (Idle, Manual, Test, Auto, WaitTest, WaitAuto);
    signal state : STATE_TYPE := Idle;

    signal Ok : STD_LOGIC := '0'; 
    signal Reset : STD_LOGIC := '0'; 


    signal Manual_Red_duty : STD_LOGIC := '0';
    signal Manual_Green_duty : STD_LOGIC := '0';
    signal Manual_Blue_duty : STD_LOGIC := '0';

    signal Test_Red_duty : STD_LOGIC := '0';
    signal Test_Green_duty : STD_LOGIC := '0';
    signal Test_Blue_duty : STD_LOGIC := '0';

    signal Auto_Red_duty : STD_LOGIC := '0';
    signal Auto_Green_duty : STD_LOGIC := '0';
    signal Auto_Blue_duty : STD_LOGIC := '0';

    signal StartTest, EndTest, StartAuto: STD_LOGIC := '0';

    signal Data7seg : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

begin
    Indicators(11 downto 0) <= SW(11 downto 0);
    Indicators(13 downto 12) <= Mode;

    proc_update_state: process(Reset, Clk100MHZ)
    begin
        if Reset = '1' then
            state <= Idle;
            StartAuto <= '0';
            StartTest <= '0';
        elsif rising_edge(Clk100MHZ) then
            case state is
                when Idle =>
                    StartTest <= '0';
                    if Ok = '1' then
                        case Mode is    
                            when "00" => state <= Manual;
                            when "01" => 
                                state <= Test;
                                StartTest <= '1';

                            when "10" => 
                                StartAuto <= '1';
                                state <= Auto;
                            when others => state <= Idle;
                        end case;
                    end if;
                    
                when Manual =>
                    if Ok = '1' then
                        state <= Idle;
                    end if;

                when Test =>
                    
                    if EndTest = '1' then
                        state <= Idle;
                        StartTest <= '0';
                    end if;
                    
                when Auto =>
                    
                    if Ok = '1' then
                        StartAuto <= '0';
                        state <= Idle;
                    end if;
                    
                when others => state <= Idle;

            end case;
                    
        end if;
    end process;

    proc_change_state: process(state)
    begin
        case state is
            when Idle =>
                LEDRed <= '0';
                LEDGreen <= '0';
                LEDBlue <= '0';
            
            when Manual =>
                LEDRed <= Manual_Red_duty;
                LEDGreen <= Manual_Green_duty;
                LEDBlue <= Manual_Blue_duty;

            when Test =>
                LEDRed <= Test_Red_duty;
                LEDGreen <= Test_Green_duty;
                LEDBlue <= Test_Blue_duty;

            when Auto =>
                LEDRed <= Auto_Red_duty;
                LEDGreen <= Auto_Green_duty;
                LEDBlue <= Auto_Blue_duty;

            when others =>
                LEDRed <= '0';
                LEDGreen <= '0';
                LEDBlue <= '0';
            
        end case;
    end process;

    mpg_ok: MPG port map(btnOk, CLK100MHZ, Ok);
    mpg_reset: MPG port map(btnReset, CLK100MHZ, Reset);

    comp_manual: ManualComp port map(CLK100MHZ, 
                                     SW(11 downto 8),   -- red
                                     SW(7 downto 4),    -- green
                                     SW(3 downto 0),    -- blue
                                     Manual_Red_duty,
                                     Manual_Green_duty,
                                     Manual_Blue_duty);
                                     
    comp_test: CompTest generic map(8)
                        port map(Test_Red_duty, 
                                 Test_Green_duty, 
                                 Test_Blue_duty,
                                 StartTest, 
                                 EndTest, 
                                 SW(11 downto 0), 
                                 Reset, 
                                 CLK100MHZ);

    comp_auto: CompAuto generic map(4)
                        port map(Auto_Red_duty, 
                                 Auto_Green_duty, 
                                 Auto_Blue_duty,
                                 StartAuto,
                                 Reset, 
                                 CLK100MHZ);


    proc7seg: process(state)
    begin
        case state is
                when Manual =>
                    Data7seg(31 downto 28) <= x"0";
                    Data7seg(27 downto 24) <= x"0";

                    -- red
                    Data7seg(23 downto 20) <= x"0";
                    Data7seg(19 downto 16) <= SW(11 downto 8);

                    -- green
                    Data7seg(15 downto 12) <= x"0";
                    Data7seg(11 downto 8) <= SW(7 downto 4);

                    -- blue
                    Data7seg(7 downto 4) <= x"0";
                    Data7seg(3 downto 0) <= SW(3 downto 0);

                when Test =>
                    Data7seg(31 downto 28) <= x"0";
                    Data7seg(27 downto 24) <= x"1";

                    -- duration
                    Data7seg(11 downto 8) <= SW(11 downto 8);
                    Data7seg(7 downto 4) <= SW(7 downto 4);
                    Data7seg(3 downto 0) <= SW(3 downto 0);

                when Auto =>
                    Data7seg(31 downto 28) <= x"1";
                    Data7seg(27 downto 24) <= x"0";

                    Data7seg(23 downto 0) <= x"000000";

                when others =>
                    Data7seg(31 downto 28) <= x"F";
                    Data7seg(27 downto 24) <= x"F";
                    Data7seg(23 downto 0) <= x"000000";
            end case;
    end process;

    Control7segm: displ7seg port map(CLK100MHZ, Reset, Data7seg, Anodes, Char);


end Behavioral;
