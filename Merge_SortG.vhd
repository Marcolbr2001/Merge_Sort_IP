library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Merge_SortG is
  Generic(
    Word : integer := 32;
    N_Elements : integer := 1024
  );
  Port (
    clk : in std_logic;
    clk_wait : in std_logic;
    reset : in std_logic;
    input : in std_logic_vector(Word-1 downto 0)
    --output : out std_logic_vector(Word-1 downto 0) 
    );
end Merge_SortG;

architecture Behavioral of Merge_SortG is

type signal_register_my_type is array (N_Elements-1 DOWNTO 0) of std_logic_vector(Word-1 DOWNTO 0);
signal SIPO_out, reg_stage2 : signal_register_my_type;
signal reg_stage2_out : signal_register_my_type;
signal reg_stage4, reg_stage4_out : signal_register_my_type;
signal reg_stage8, reg_stage8_out : signal_register_my_type;
signal reg_stage16, reg_stage16_out : signal_register_my_type;
signal reg_stage32, reg_stage32_out : signal_register_my_type;
signal reg_stage64, reg_stage64_out : signal_register_my_type;
signal reg_stage128, reg_stage128_out : signal_register_my_type;
signal reg_stage256, reg_stage256_out : signal_register_my_type;
signal reg_stage512, reg_stage512_out : signal_register_my_type;
signal reg_stage1024, reg_stage1024_out : signal_register_my_type;

procedure merge (signal array_out : out signal_register_my_type; 
                 signal array_in : in signal_register_my_type;
                 constant N_El : in integer;
                 constant partition : in integer) is

variable a,b : integer := 0;

begin


    for i in 0 to (N_El-1)/partition loop
        a:=0;
        b:=0;
        for j in 0 to (partition - 1) loop
            if b >= (partition/2) then
                array_out((partition)*i+j) <= array_in((partition)*i+j);
            elsif a >= (partition/2) and j >= (partition/2) then
                array_out((partition)*i+j) <= array_in((partition)*i+j-(partition/2));
            elsif array_in((partition)*i+j-a) <= array_in((partition)*i+j+(partition/2)-b) then
                array_out((partition)*i+j) <= array_in((partition)*i+j-a);
                b := b + 1;
            elsif array_in((partition)*i+j-a) > array_in((partition)*i+j+(partition/2)-b) then
                array_out((partition)*i+j) <= array_in((partition)*i+j+(partition/2)-b);
                a := a + 1;
            end if;
        end loop;
    end loop;



end procedure merge;


component Rgstr is
  Port (
        clk : in std_logic;
        reset : in std_logic;
        d : in std_logic_vector(Word-1 DOWNTO 0);
        q : out std_logic_vector(Word-1 DOWNTO 0) 
         );
end component;

component Merge_1 is
  Port (
        clk : in std_logic;
        reset : in std_logic;
        in_1 : in std_logic_vector(Word-1 DOWNTO 0);
        in_2 : in std_logic_vector(Word-1 DOWNTO 0);
        
        out_1 : out std_logic_vector(Word-1 DOWNTO 0);
        out_2 : out std_logic_vector(Word-1 DOWNTO 0)
         );
end component;

begin

-- Parallelized input (SIPO) --
SIPO_REG_for : for X in 0 TO N_Elements-1 generate
    SIPO_REG_zero : if X = 0 generate
        SIPO_REG : Rgstr            
                    Port Map
                    (
                    reset => reset,
                    clk => clk,
                    
                    d => input,
                    q => SIPO_out(X)
                    );   
    end generate;
        SIPO_REG : if X /= 0 generate     
            SIPO_REG : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => SIPO_out(X-1),
                        q => SIPO_out(X)
                        );            
        end generate;               
end generate;
-- end SIPO --


--Wait register for sincronous process
WAIT_REG_for : for X in 0 TO N_Elements-1 generate
    WAIT_REG : Rgstr            
        Port Map
        (
        reset => reset,
        clk => clk_wait,
        
        d => SIPO_out(X),
        q => reg_stage2(X)
        );            
    end generate;      
-- end Wait Register --


-- Generating the entire first line of element sorted 2by2
level1_for : for X in 0 TO N_Elements-1 generate
    level1_if : if X mod 2 = 0 generate
        level1_1 : Merge_1 
            port map (
                clk => clk, 
                reset => reset, 
                
                in_1 => reg_stage2(X),--SIPO_out(X), --
                in_2 => reg_stage2(X+1),--SIPO_out(X+1), --
                
                out_1 => reg_stage2_out(X), 
                out_2 => reg_stage2_out(X+1)
                );
    end generate;
end generate;
-- end first line merge --

Process(clk, reset)
begin
     
     if reset='1' then
     
        reg_stage4 <= (Others => (Others => '0'));
        reg_stage8 <= (Others => (Others => '0'));
        reg_stage16 <= (Others => (Others => '0'));
        reg_stage32 <= (Others => (Others => '0'));
        reg_stage64 <= (Others => (Others => '0'));
        reg_stage128 <= (Others => (Others => '0'));
        reg_stage256 <= (Others => (Others => '0'));
        reg_stage512 <= (Others => (Others => '0'));
        reg_stage1024 <= (Others => (Others => '0'));

     --end if ;
     else
     --if(rising_edge(clk))then

        merge(reg_stage4, reg_stage2_out, N_Elements, 4);
        merge(reg_stage8, reg_stage4_out, N_Elements, 8);
        merge(reg_stage16, reg_stage8_out, N_Elements, 16);
        merge(reg_stage32, reg_stage16_out, N_Elements, 32);
        merge(reg_stage64, reg_stage32_out, N_Elements, 64);
        merge(reg_stage128, reg_stage64_out, N_Elements, 128);
        merge(reg_stage256, reg_stage128_out, N_Elements, 256);
        merge(reg_stage512, reg_stage256_out, N_Elements, 512);
        merge(reg_stage1024, reg_stage512_out, N_Elements, 1024);

     end if;
end process;

Reg4by4 : for X in 0 to N_Elements-1 generate
            Reg4by4 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage4(X),
                        q => reg_stage4_out(X)
                        ); 
            end generate; 

Reg8by8 : for X in 0 to N_Elements-1 generate
            Reg8by8 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage8(X),
                        q => reg_stage8_out(X)
                        ); 
            end generate; 

Reg16by16 : for X in 0 to N_Elements-1 generate
            Reg16by16 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage16(X),
                        q => reg_stage16_out(X)
                        ); 
            end generate; 

Reg32by32 : for X in 0 to N_Elements-1 generate
            Reg8by8 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage32(X),
                        q => reg_stage32_out(X)
                        ); 
end generate; 

Reg64by64 : for X in 0 to N_Elements-1 generate
            Reg64by64 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage64(X),
                        q => reg_stage64_out(X)
                        ); 
end generate;

Reg128by128 : for X in 0 to N_Elements-1 generate
            Reg128by128 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage128(X),
                        q => reg_stage128_out(X)
                        ); 
end generate;

Reg256by256 : for X in 0 to N_Elements-1 generate
            Re256by256 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage256(X),
                        q => reg_stage256_out(X)
                        ); 
end generate;

Reg512by512 : for X in 0 to N_Elements-1 generate
            Reg8by8 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage512(X),
                        q => reg_stage512_out(X)
                        ); 
end generate;

Reg1024by1024 : for X in 0 to N_Elements-1 generate
            Reg1024by1024 : Rgstr            
                        Port Map
                        (
                        reset => reset,
                        clk => clk,
                        
                        d => reg_stage1024(X),
                        q => reg_stage1024_out(X)
                        ); 
end generate;

end Behavioral;