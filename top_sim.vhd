----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.11.2023 18:47:34
-- Design Name: 
-- Module Name: top_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_sim is
--  Port ( );
end top_sim;

architecture Behavioral of top_sim is

component Merge_SortG is
  Port (
    clk : in std_logic;
    clk_wait : in std_logic;
    reset : in std_logic;
    input : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0) 
    );
end component;

begin
 Merge:Merge_Sort
  Port Map (
    clk => clk;
    clk_wait : in std_logic;
    reset : in std_logic;
    input : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0) 
    );
 process 
end Behavioral;
