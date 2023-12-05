
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Rgstr is
  Generic(
    Word : integer := 32
  );
  Port (
        clk : in std_logic;
        reset : in std_logic;
        d : in std_logic_vector(Word-1 DOWNTO 0);
        q : out std_logic_vector(Word-1 DOWNTO 0) 
         );
end Rgstr;

architecture Behavioral of Rgstr is

begin

Process(clk, reset)
begin

if reset = '1' then

    q <= (Others => '0');

elsif rising_edge(clk) then

    q <= d;

end if;

end process;

end Behavioral;
