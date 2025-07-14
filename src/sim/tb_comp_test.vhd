

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_comp_test is
--  Port ( );
end tb_comp_test;

architecture Behavioral of tb_comp_test is
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

    signal Red_duty : STD_LOGIC;
    signal Green_duty : STD_LOGIC;
    signal Blue_duty : STD_LOGIC;
    signal StartTest : STD_LOGIC := '0';
    signal EndTest : STD_LOGIC := '0';
    signal Duration : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
    signal Reset : STD_LOGIC := '0';
    signal CLK100MHZ:  std_logic;
begin

    clk_proc: process
    begin
        CLK100MHZ <= '0';
        wait for 5 ns;
        CLK100MHZ <= '1';
        wait for 5 ns;
    end process;

    comp_test: CompTest port map ( Red_duty, Green_duty, Blue_duty, StartTest, EndTest, Duration, Reset, CLK100MHZ);
    
end Behavioral;
