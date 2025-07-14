library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWMGen is
    generic(NoBits: integer);
    Port ( Duty : in STD_LOGIC_VECTOR (NoBits - 1 downto 0);
           Clk : in STD_LOGIC;
           PWM_Out : out STD_LOGIC);
end PWMGen;

architecture Behavioral of PWMGen is
    signal count: STD_LOGIC_VECTOR(NoBits - 1 downto 0) := (others => '0');
begin
    process(Clk)
    begin
        if rising_edge(Clk) then
            count <= count + 1;
            if count < Duty then
                PWM_Out <= '1';
            else
                PWM_Out <= '0';
            end if;
        end if;
    end process;

end Behavioral;
