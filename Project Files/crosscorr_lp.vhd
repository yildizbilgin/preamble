-----------------------------
--LONG PREAMBLE CORRELATION
-----------------------------


library IEEE;
use ieee.fixed_pkg.all;

package fp_vector IS
	type sfixed_vector is array (natural range<>) of sfixed(3 downto -4); --defining a vector consists of sfixed numbers
	type sfixed_array is array (natural range <>) of sfixed_vector(1 to 2); --a vector consists of complex numbers such a+bi in the form (a,b) where a and b are sfixed numbers
end;
	
	
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.fixed_pkg.all;
use work.fp_vector.ALL;

entity crosscorr is
	port(clk:in std_logic;
		  rst:in std_logic;
		  Cnl:out sfixed(3 downto -4));
end crosscorr;


architecture Behavioral of crosscorr_lp is

--function to sum two complex numbers in the form such as (a+bi)+(c+di)=(a,b)+(c,d)=(a+c,b+d)=(a+b)+(c+d)i
	function complex_sum (x,y:sfixed_vector(1 to 2)) return sfixed_vector is
		variable s:sfixed_vector(1 to 2);
begin
		s:=(resize(x(1)+y(1),3,-4),resize(x(2)+y(2),3,-4));
return s;
end function complex_sum;

--function to multiplex two complex number in the form such as (a+bi).(c+di)=ac+adi+bci-bd=(ac-bd)+(ad+bc)i=(ac-bd,ad+bc)
	function complex_mux (x,y:sfixed_vector(1 to 2)) return sfixed is
		variable m:sfixed(3 downto -4);
begin
		m:=(resize(((x(1)*y(1)+x(2)*y(2))*(x(1)*y(1)+x(2)*y(2)))+((x(1)*y(2)-x(2)*y(1))*(x(1)*y(2)-x(2)*y(1))),3,-4));
return m;
end function complex_mux;

    signal count2:positive range 1 to 383;
	signal sp:sfixed_array(1 to 16);
	signal cp:sfixed_array(1 to 32);
	signal lp:sfixed_array(1 to 64);
	signal preamble:sfixed_array(1 to 320);
	signal zero:sfixed_vector(1 to 2);
	signal zeros2:sfixed_array(1 to 130);
	signal preamble2:sfixed_array(1 to 450);
	signal Cl:sfixed_vector(1 to 383);
    signal Cll:sfixed_vector(1 to 383);
    signal count: natural range 1 to 500_000;
    signal temp_clk_out: std_logic;

begin
zero<=(to_sfixed(0,16,-16),to_sfixed(0,16,-16));--zero vector to add to the preamble for correlation
zeros2<=(others=>zero);

--process  of 100Hz clock divider
 process(clk)
begin
if (rising_edge(clk)) then
count <= count + 1;
if(count= 500_000) then
temp_clk_out<=not temp_clk_out;
count<=1;
end if;
end if;
end process;

--short preamble values
sp<=(
(to_sfixed(0.05,3,-4),to_sfixed(0.05,3,-4)),(to_sfixed(-0.13,3,-4),to_sfixed(0.00,3,-4)),
(to_sfixed(-0.01,3,-4),to_sfixed(-0.08,3,-4)),(to_sfixed(0.14,3,-4),to_sfixed(-0.01,3,-4)),
(to_sfixed(0.09,3,-4),to_sfixed(0.00,3,-4)),(to_sfixed(0.14,3,-4),to_sfixed(-0.01,3,-4)),
(to_sfixed(-0.01,3,-4),to_sfixed(-0.08,3,-4)),(to_sfixed(-0.13,3,-4),to_sfixed(0.00,3,-4)),
(to_sfixed(0.05,3,-4),to_sfixed(0.05,3,-4)),(to_sfixed(0.00,3,-4),to_sfixed(-0.13,3,-4)),
(to_sfixed(-0.08,3,-4),to_sfixed(-0.01,3,-4)),(to_sfixed(-0.01,3,-4),to_sfixed(0.14,3,-4)),
(to_sfixed(0.00,3,-4),to_sfixed(0.09,3,-4)),(to_sfixed(-0.01,3,-4),to_sfixed(0.14,3,-4)),
(to_sfixed(-0.08,3,-4),to_sfixed(-0.01,3,-4)),(to_sfixed(0.00,3,-4),to_sfixed(-0.13,3,-4)));

--cyclic prefix values
cp<=(
(to_sfixed(-0.08,3,-4),to_sfixed(0.00,3,-4)),(to_sfixed(0.01,3,-4),to_sfixed(-0.09,3,-4)),
(to_sfixed(0.09,3,-4),to_sfixed(-0.11,3,-4)),(to_sfixed(-0.09,3,-4),to_sfixed(-0.12,3,-4)),
(to_sfixed(-0.00,3,-4),to_sfixed(-0.05,3,-4)),(to_sfixed(0.08,3,-4),to_sfixed(0.07,3,-4)),
(to_sfixed(-0.13,3,-4),to_sfixed(0.02,3,-4)),(to_sfixed(-0.12,3,-4),to_sfixed(0.02,3,-4)),
(to_sfixed(-0.04,3,-4),to_sfixed(0.15,3,-4)),(to_sfixed(-0.06,3,-4),to_sfixed(0.02,3,-4)),
(to_sfixed(-0.06,3,-4),to_sfixed(-0.08,3,-4)),(to_sfixed(0.07,3,-4),to_sfixed(-0.01,3,-4)),
(to_sfixed(0.08,3,-4),to_sfixed(-0.09,3,-4)),(to_sfixed(-0.13,3,-4),to_sfixed(-0.07,3,-4)),
(to_sfixed(-0.06,3,-4),to_sfixed(-0.04,3,-4)),(to_sfixed(0.04,3,-4),to_sfixed(-0.09,3,-4)),
(to_sfixed(0.06,3,-4),to_sfixed(0.06,3,-4)),(to_sfixed(0.12,3,-4),to_sfixed(0.00,3,-4)),
(to_sfixed(-0.02,3,-4),to_sfixed(-0.16,3,-4)),(to_sfixed(0.06,3,-4),to_sfixed(0.02,3,-4)),
(to_sfixed(0.02,3,-4),to_sfixed(0.06,3,-4)),(to_sfixed(-0.14,3,-4),to_sfixed(0.05,3,-4)),
(to_sfixed(0.00,3,-4),to_sfixed(0.12,3,-4)),(to_sfixed(0.05,3,-4),to_sfixed(-0.00,3,-4)),
(to_sfixed(0.09,3,-4),to_sfixed(0.03,3,-4)),(to_sfixed(-0.04,3,-4),to_sfixed(0.11,3,-4)),
(to_sfixed(-0.12,3,-4),to_sfixed(0.06,3,-4)),(to_sfixed(0.06,3,-4),to_sfixed(0.09,3,-4)),
(to_sfixed(0.02,3,-4),to_sfixed(-0.03,3,-4)),(to_sfixed(0.09,3,-4),to_sfixed(-0.08,3,-4)),
(to_sfixed(0.04,3,-4),to_sfixed(0.11,3,-4)),(to_sfixed(-0.01,3,-4),to_sfixed(0.12,3,-4)));

--long preamble values
lp<=(
(to_sfixed(-0.01,3,-4),to_sfixed(-0.12,3,-4)),(to_sfixed(0.04,3,-4),to_sfixed(-0.11,3,-4)),
(to_sfixed(0.09,3,-4),to_sfixed(0.08,3,-4)),(to_sfixed(0.02,3,-4),to_sfixed(0.03,3,-4)),
(to_sfixed(0.06,3,-4),to_sfixed(-0.09,3,-4)),(to_sfixed(-0.12,3,-4),to_sfixed(-0.06,3,-4)),
(to_sfixed(-0.04,3,-4),to_sfixed(-0.11,3,-4)),(to_sfixed(0.09,3,-4),to_sfixed(-0.03,3,-4)),
(to_sfixed(0.05,3,-4),to_sfixed(0.00,3,-4)),(to_sfixed(0.00,3,-4),to_sfixed(-0.12,3,-4)),
(to_sfixed(-0.14,3,-4),to_sfixed(-0.05,3,-4)),(to_sfixed(0.02,3,-4),to_sfixed(-0.06,3,-4)),
(to_sfixed(0.06,3,-4),to_sfixed(-0.02,3,-4)),(to_sfixed(-0.02,3,-4),to_sfixed(0.16,3,-4)),
(to_sfixed(0.12,3,-4),to_sfixed(-0.00,3,-4)),(to_sfixed(0.06,3,-4),to_sfixed(-0.06,3,-4)),
(to_sfixed(0.04,3,-4),to_sfixed(0.09,3,-4)),(to_sfixed(-0.06,3,-4),to_sfixed(0.04,3,-4)),
(to_sfixed(-0.13,3,-4),to_sfixed(0.07,3,-4)),(to_sfixed(0.08,3,-4),to_sfixed(0.09,3,-4)),
(to_sfixed(0.07,3,-4),to_sfixed(0.01,3,-4)),(to_sfixed(-0.06,3,-4),to_sfixed(0.08,3,-4)),
(to_sfixed(-0.06,3,-4),to_sfixed(-0.02,3,-4)),(to_sfixed(-0.04,3,-4),to_sfixed(-0.15,3,-4)),
(to_sfixed(-0.12,3,-4),to_sfixed(-0.02,3,-4)),(to_sfixed(-0.13,3,-4),to_sfixed(-0.02,3,-4)),
(to_sfixed(0.08,3,-4),to_sfixed(-0.07,3,-4)),(to_sfixed(-0.00,3,-4),to_sfixed(0.05,3,-4)),
(to_sfixed(-0.09,3,-4),to_sfixed(0.115,3,-4)),(to_sfixed(0.092,3,-4),to_sfixed(0.106,3,-4)),
(to_sfixed(0.012,3,-4),to_sfixed(0.09,3,-4)),(to_sfixed(-0.16,3,-4),to_sfixed(0.00,3,-4)),
(to_sfixed(0.01,3,-4),to_sfixed(-0.09,3,-4)),(to_sfixed(0.09,3,-4),to_sfixed(-0.11,3,-4)),
(to_sfixed(-0.09,3,-4),to_sfixed(-0.12,3,-4)),(to_sfixed(-0.00,3,-4),to_sfixed(-0.05,3,-4)),
(to_sfixed(0.08,3,-4),to_sfixed(0.07,3,-4)),(to_sfixed(-0.13,3,-4),to_sfixed(0.02,3,-4)),
(to_sfixed(-0.12,3,-4),to_sfixed(0.02,3,-4)),(to_sfixed(-0.04,3,-4),to_sfixed(0.15,3,-4)),
(to_sfixed(-0.06,3,-4),to_sfixed(0.02,3,-4)),(to_sfixed(-0.06,3,-4),to_sfixed(0.08,3,-4)),
(to_sfixed(0.07,3,-4),to_sfixed(-0.01,3,-4)),(to_sfixed(0.08,3,-4),to_sfixed(-0.09,3,-4)),
(to_sfixed(-0.13,3,-4),to_sfixed(-0.07,3,-4)),(to_sfixed(-0.06,3,-4),to_sfixed(-0.04,3,-4)),
(to_sfixed(0.04,3,-4),to_sfixed(-0.09,3,-4)),(to_sfixed(0.06,3,-4),to_sfixed(0.06,3,-4)),
(to_sfixed(0.12,3,-4),to_sfixed(0.00,3,-4)),(to_sfixed(-0.02,3,-4),to_sfixed(-0.16,3,-4)),
(to_sfixed(0.06,3,-4),to_sfixed(0.02,3,-4)),(to_sfixed(0.02,3,-4),to_sfixed(0.06,3,-4)),
(to_sfixed(-0.14,3,-4),to_sfixed(0.05,3,-4)),(to_sfixed(0.00,3,-4),to_sfixed(0.12,3,-4)),
(to_sfixed(0.05,3,-4),to_sfixed(-0.00,3,-4)),(to_sfixed(0.09,3,-4),to_sfixed(0.03,3,-4)),
(to_sfixed(-0.04,3,-4),to_sfixed(0.11,3,-4)),(to_sfixed(-0.12,3,-4),to_sfixed(0.06,3,-4)),
(to_sfixed(0.06,3,-4),to_sfixed(0.09,3,-4)),(to_sfixed(0.02,3,-4),to_sfixed(-0.03,3,-4)),
(to_sfixed(0.09,3,-4),to_sfixed(-0.08,3,-4)),(to_sfixed(0.04,3,-4),to_sfixed(0.11,3,-4)),
(to_sfixed(-0.01,3,-4),to_sfixed(0.12,3,-4)),(to_sfixed(0.08,3,-4),to_sfixed(0.00,3,-4)));

preamble<=sp&sp&sp&sp&sp&sp&sp&sp&sp&sp&cp&lp&lp;--preamble structure is constructed by concatenating
preamble2<=preamble&zeros2;--adding zero vector to preamble because we are going to shift the signal during correlation

--process of long preamble and preamble correlation
process(clk)
	variable m:integer range 1 to 64:=1;--index of long preamble 
	variable k:integer range 1 to 383:=1; --index of correlation vector = long preamble+preamble-1=64+320-1=383
	variable corr:sfixed(16 downto -16):=to_sfixed(0,16,-16);--correlation value 
	variable sum:sfixed_vector(1 to 383):=(others=>(to_sfixed(0,16,-16)));--summation of the correlated values for one short preamble index
	variable a:integer range 0 to 382:=0;--shifting value 0 to (correlation vector length-1=383-1=)382
	
begin
	if (rising_edge(clk)) then
		corr:=complex_mux(lp(m),preamble2(m+a));
		sum(k):=sum(k)+corr;
		if (m<64) then
			m:=m+1;
		else
			m:=1;
			if(a<382) then
				a:=a+1;
			end if;
			Cl(k)<=sum(k);
			if (k<383) then
				k:=k+1;
			end if;
		end if;
	end if;
end process;

--normalization is done by dividing every elements of correlation vector by 2^4=16
normalization2: for i in 1 to 383 generate
	Cll(i)<=Cl(i) srl 4;
end generate;

--process to represent every elements of the correlation vector one by one in every clock signal
process(temp_clk_out,rst)
begin
	if (rst='1') then
		count2<=1;
	elsif (rising_edge(temp_clk_out)) then
		if (count2=383) then
			count2<=1;
		else
			count2<=count2+1;
		 end if;
	end if;
end process;
Cnl<=Cll(count2);

end Behavioral;
