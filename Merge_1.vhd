library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Merge_1 is
  Generic(
    Word : integer := 32
  );
  Port (
        clk : in std_logic;
        reset : in std_logic;
        in_1 : in std_logic_vector(Word-1 DOWNTO 0);
        in_2 : in std_logic_vector(Word-1 DOWNTO 0);
        
        out_1 : out std_logic_vector(Word-1 DOWNTO 0);
        out_2 : out std_logic_vector(Word-1 DOWNTO 0)
         );
end Merge_1;

architecture Behavioral of Merge_1 is

begin

process (clk, reset)
begin
    if reset = '1' then
        out_1 <= (Others => '0');
        out_2 <= (Others => '0');
    elsif rising_edge(clk) then
        if (in_1 <= in_2) then
            out_1 <= in_1;
            out_2 <= in_2;
        else
            out_1 <= in_2;
            out_2 <= in_1;
        end if;
    end if;
end process;

end Behavioral;
