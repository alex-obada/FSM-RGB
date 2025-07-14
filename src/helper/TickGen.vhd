library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TickGen is
    generic(Duration_unit_ms: integer := 1000;
            NoEvents: integer); 
    Port (
        CLK100MHZ : in std_logic;
        Duration : in std_logic_vector(11 downto 0);
        Reset : in std_logic;
        Tick : out std_logic
    );
end TickGen;

architecture Behavioral of TickGen is
    constant clocks_per_ms : integer := 100_000;  -- 100 MHz <=> 1 ms = 100_000 clocks
    signal counter: integer  := 0;
begin
    process(CLK100MHZ, Reset)
        variable duration_val : integer;
        variable target_val : integer;
    begin
        if Reset = '1' then
            counter <= 0;
            Tick <= '0';
        elsif rising_edge(CLK100MHZ) then
            
            duration_val := to_integer(unsigned(Duration));
            if duration_val = 0 then
                duration_val := 1;
            end if;

            target_val := (clocks_per_ms / NoEvents) * (Duration_unit_ms * duration_val) ;

            if counter = target_val - 1 then
                counter <= 0;
                Tick <= '1';
            else
                counter <= counter + 1;
                Tick <= '0';
            end if;
        end if;
    end process;

end Behavioral;
