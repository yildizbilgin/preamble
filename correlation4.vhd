package Correlation IS
    TYPE int_vector is ARRAY(integer RANGE <>) OF integer;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Correlation.ALL;

entity correlation4 is
    port (clk:in std_logic;
          C:out int_vector(1 to 5)
          );
end correlation4;

architecture Behavioral of correlation4 is
	constant zeros:integer:=0;
   signal x:int_vector(1 to 4);
   signal h:int_vector(1 to 2);


begin
x<=(-1,2,1,-3);
h<=(2,1);
process (clk,x,h)
	variable x1:int_vector(1 to 7);
	variable sum:integer := 0;
	variable corr:integer;
	variable a:integer:=5;
	variable m:integer range 1 to 2:=1;
	variable k:integer range 1 to 5:=1;
begin
x1:=x&zeros&zeros&zeros;
	if (rising_edge(clk)) then
		corr := h(m)*x1(m+a-1);
		sum := sum + corr;
			if (m<2) then
				m:=m+1;
			else
				m:=1;
				if(a>1) then
					a:=a-1;
				end if;
				C(k) <= sum ;
				sum:=0;
				k:=k+1;
			end if;
	end if;
end process;
end Behavioral;
