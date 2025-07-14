library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ManualComp is
    Port ( CLK100MHZ : in STD_LOGIC;
           Red_duty : in STD_LOGIC_VECTOR (3 downto 0);
           Green_duty : in STD_LOGIC_VECTOR (3 downto 0);
           Blue_duty : in STD_LOGIC_VECTOR (3 downto 0);
           Red_out : out STD_LOGIC;
           Green_out : out STD_LOGIC;
           Blue_out : out STD_LOGIC);
end ManualComp;

architecture Behavioral of ManualComp is
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

begin

    clock_gen: PWMClockGen port map(CLK100MHZ, Clk_5kHz);
    pulse_gen_blue: PWMGen generic map(4) port map(Blue_duty, Clk_5kHz, Blue_out);
    pulse_gen_green: PWMGen generic map(4) port map(Green_duty, Clk_5kHz, Green_out);
    pulse_gen_red: PWMGen generic map(4) port map(Red_duty, Clk_5kHz, Red_out);
end Behavioral;
