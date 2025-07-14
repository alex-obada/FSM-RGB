library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PWMClockGen is
    generic(MAX_CNT : integer := 20_000);
    Port ( Clk_in : in STD_LOGIC;       -- 100MHz
           Clk_out : out STD_LOGIC);    
end PWMClockGen;

architecture Behavioral of PWMClockGen is
    signal counter : integer range 0 to MAX_CNT - 1 := 0;
    signal clk_state : STD_LOGIC := '0';
begin
    process(Clk_in)
    begin
        if rising_edge(Clk_in) then
            if counter = MAX_CNT - 1 then
                counter <= 0;
                clk_state <= not clk_state;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    Clk_out <= clk_state;

end Behavioral;
