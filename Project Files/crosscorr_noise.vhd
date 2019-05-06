----------------------------------------------------------------------------------
-- CORRELATION OF PREAMBLE WITH NOISE 
----------------------------------------------------------------------------------

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

entity crosscorr_noise is
	port(clk:in std_logic;
		  rst:in std_logic;
		  C:out sfixed(3 downto -4));
end crosscorr_noise;

architecture Behavioral of crosscorr_noise is
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
	signal count3:positive range 1 to 335;
	signal sp:sfixed_array(1 to 16);
	signal cp:sfixed_array(1 to 32);
	signal lp:sfixed_array(1 to 64);
	signal preamble:sfixed_array(1 to 320);
	signal preamble_w_noise,noise:sfixed_array(1 to 320);
	signal zero:sfixed_vector(1 to 2);
	signal zeros1:sfixed_array(1 to 30);
	signal preamble3:sfixed_array(1 to 350);
	signal Cn:sfixed_vector(1 to 335);
	signal Cnn:sfixed_vector(1 to 335);
begin

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

zero<=(to_sfixed(0,3,-4),to_sfixed(0,3,-4));--zero vector to add to the preamble for correlation
zeros1<=(others=>zero);

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

--additive white gaussian noise samples with 0 mean and variance of 1 which are created in Matlab.
noise<=(
(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),(to_sfixed(0.055,16,-16),to_sfixed(-0.052,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(0.018,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.019,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.025,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(-0.025,16,-16),to_sfixed(0.016,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),
(to_sfixed(0.036,16,-16),to_sfixed(0.035,16,-16)),(to_sfixed(0.020,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(-0.004,16,-16),to_sfixed(-0.012,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(-0.013,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(0.048,16,-16),to_sfixed(0.053,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.040,16,-16),to_sfixed(0.017,16,-16)),
(to_sfixed(0.038,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.022,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.034,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.009,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.043,16,-16),to_sfixed(0.025,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.003,16,-16),to_sfixed(0.023,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.021,16,-16),to_sfixed(0.028,16,-16)),
(to_sfixed(-0.013,16,-16),to_sfixed(0.000,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(0.015,16,-16),to_sfixed(0.035,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(-0.036,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.016,16,-16),to_sfixed(-0.037,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(0.010,16,-16)),
(to_sfixed(0.031,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(0.022,16,-16),to_sfixed(0.026,16,-16)),
(to_sfixed(0.022,16,-16),to_sfixed(-0.012,16,-16)),(to_sfixed(-0.002,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.036,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(-0.033,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.009,16,-16)),(to_sfixed(0.028,16,-16),to_sfixed(-0.003,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.028,16,-16),to_sfixed(0.012,16,-16)),
(to_sfixed(0.044,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(0.009,16,-16),to_sfixed(0.030,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.006,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(0.045,16,-16)),(to_sfixed(0.036,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(-0.003,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.012,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.035,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.047,16,-16)),(to_sfixed(-0.042,16,-16),to_sfixed(0.007,16,-16)),
(to_sfixed(0.030,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(-0.038,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(-0.007,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(-0.011,16,-16),to_sfixed(0.009,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.001,16,-16)),
(to_sfixed(0.007,16,-16),to_sfixed(0.007,16,-16)),(to_sfixed(0.034,16,-16),to_sfixed(0.020,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.031,16,-16)),(to_sfixed(-0.013,16,-16),to_sfixed(-0.015,16,-16)),
(to_sfixed(-0.026,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.033,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(0.050,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(-0.017,16,-16),to_sfixed(0.008,16,-16)),
(to_sfixed(0.026,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(-0.063,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.000,16,-16)),
(to_sfixed(-0.045,16,-16),to_sfixed(0.018,16,-16)),(to_sfixed(-0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.0048,16,-16)),(to_sfixed(0.038,16,-16),to_sfixed(-0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(0.036,16,-16)),(to_sfixed(0.016,16,-16),to_sfixed(-0.028,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.029,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.013,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(0.015,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.020,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),(to_sfixed(0.055,16,-16),to_sfixed(-0.052,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(0.018,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.019,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.025,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(-0.025,16,-16),to_sfixed(0.016,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),
(to_sfixed(0.036,16,-16),to_sfixed(0.035,16,-16)),(to_sfixed(0.020,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(-0.004,16,-16),to_sfixed(-0.012,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(-0.013,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(0.048,16,-16),to_sfixed(0.053,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.040,16,-16),to_sfixed(0.017,16,-16)),
(to_sfixed(0.038,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.022,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.034,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.009,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.043,16,-16),to_sfixed(0.025,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.003,16,-16),to_sfixed(0.023,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.021,16,-16),to_sfixed(0.028,16,-16)),
(to_sfixed(-0.013,16,-16),to_sfixed(0.000,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(0.015,16,-16),to_sfixed(0.035,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(-0.036,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.016,16,-16),to_sfixed(-0.037,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(0.010,16,-16)),
(to_sfixed(0.031,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(0.022,16,-16),to_sfixed(0.026,16,-16)),
(to_sfixed(0.022,16,-16),to_sfixed(-0.012,16,-16)),(to_sfixed(-0.002,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.036,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(-0.033,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.009,16,-16)),(to_sfixed(0.028,16,-16),to_sfixed(-0.003,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.028,16,-16),to_sfixed(0.012,16,-16)),
(to_sfixed(0.044,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(0.009,16,-16),to_sfixed(0.030,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.006,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(0.045,16,-16)),(to_sfixed(0.036,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(-0.003,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.012,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.035,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.047,16,-16)),(to_sfixed(-0.042,16,-16),to_sfixed(0.007,16,-16)),
(to_sfixed(0.030,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(-0.038,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(-0.007,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(-0.011,16,-16),to_sfixed(0.009,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.001,16,-16)),
(to_sfixed(0.007,16,-16),to_sfixed(0.007,16,-16)),(to_sfixed(0.034,16,-16),to_sfixed(0.020,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.031,16,-16)),(to_sfixed(-0.013,16,-16),to_sfixed(-0.015,16,-16)),
(to_sfixed(-0.026,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.033,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(0.050,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(-0.017,16,-16),to_sfixed(0.008,16,-16)),
(to_sfixed(0.026,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(-0.063,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.000,16,-16)),
(to_sfixed(-0.045,16,-16),to_sfixed(0.018,16,-16)),(to_sfixed(-0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.0048,16,-16)),(to_sfixed(0.038,16,-16),to_sfixed(-0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(0.036,16,-16)),(to_sfixed(0.016,16,-16),to_sfixed(-0.028,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.029,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.013,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(0.015,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.020,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),(to_sfixed(0.055,16,-16),to_sfixed(-0.052,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(0.018,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.019,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.025,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(-0.025,16,-16),to_sfixed(0.016,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),
(to_sfixed(0.036,16,-16),to_sfixed(0.035,16,-16)),(to_sfixed(0.020,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(-0.004,16,-16),to_sfixed(-0.012,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(-0.013,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(0.048,16,-16),to_sfixed(0.053,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.040,16,-16),to_sfixed(0.017,16,-16)),
(to_sfixed(0.038,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.022,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.034,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.009,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.043,16,-16),to_sfixed(0.025,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(0.031,16,-16)),(to_sfixed(0.003,16,-16),to_sfixed(0.023,16,-16)),
(to_sfixed(0.001,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.021,16,-16),to_sfixed(0.028,16,-16)),
(to_sfixed(-0.013,16,-16),to_sfixed(0.000,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.011,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(0.015,16,-16),to_sfixed(0.035,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(-0.036,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.016,16,-16),to_sfixed(-0.037,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(0.010,16,-16)),
(to_sfixed(0.031,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(0.022,16,-16),to_sfixed(0.026,16,-16)),
(to_sfixed(0.022,16,-16),to_sfixed(-0.012,16,-16)),(to_sfixed(-0.002,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(-0.017,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.036,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.011,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(-0.033,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(-0.029,16,-16)),
(to_sfixed(0.013,16,-16),to_sfixed(-0.009,16,-16)),(to_sfixed(0.028,16,-16),to_sfixed(-0.003,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.028,16,-16),to_sfixed(0.012,16,-16)),
(to_sfixed(0.044,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(0.009,16,-16),to_sfixed(0.030,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.006,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(0.045,16,-16)),(to_sfixed(0.036,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(-0.003,16,-16),to_sfixed(-0.018,16,-16)),(to_sfixed(0.012,16,-16),to_sfixed(-0.019,16,-16)),
(to_sfixed(-0.035,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.047,16,-16)),(to_sfixed(-0.042,16,-16),to_sfixed(0.007,16,-16)),
(to_sfixed(0.030,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(0.007,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(-0.038,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(-0.007,16,-16),to_sfixed(0.005,16,-16)),(to_sfixed(-0.026,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(-0.011,16,-16),to_sfixed(0.009,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.001,16,-16)),
(to_sfixed(0.007,16,-16),to_sfixed(0.007,16,-16)),(to_sfixed(0.034,16,-16),to_sfixed(0.020,16,-16)),
(to_sfixed(-0.017,16,-16),to_sfixed(-0.031,16,-16)),(to_sfixed(-0.013,16,-16),to_sfixed(-0.015,16,-16)),
(to_sfixed(-0.026,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.033,16,-16),to_sfixed(0.003,16,-16)),
(to_sfixed(0.050,16,-16),to_sfixed(-0.008,16,-16)),(to_sfixed(-0.017,16,-16),to_sfixed(0.008,16,-16)),
(to_sfixed(0.026,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(-0.011,16,-16),to_sfixed(0.032,16,-16)),
(to_sfixed(-0.063,16,-16),to_sfixed(-0.001,16,-16)),(to_sfixed(-0.012,16,-16),to_sfixed(0.000,16,-16)),
(to_sfixed(-0.045,16,-16),to_sfixed(0.018,16,-16)),(to_sfixed(-0.001,16,-16),to_sfixed(-0.011,16,-16)),
(to_sfixed(-0.002,16,-16),to_sfixed(0.0048,16,-16)),(to_sfixed(0.038,16,-16),to_sfixed(-0.005,16,-16)),
(to_sfixed(0.006,16,-16),to_sfixed(0.036,16,-16)),(to_sfixed(0.016,16,-16),to_sfixed(-0.028,16,-16)),
(to_sfixed(0.010,16,-16),to_sfixed(0.026,16,-16)),(to_sfixed(-0.020,16,-16),to_sfixed(0.029,16,-16)),
(to_sfixed(-0.014,16,-16),to_sfixed(0.013,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(0.015,16,-16)),
(to_sfixed(0.021,16,-16),to_sfixed(-0.020,16,-16)),(to_sfixed(0.011,16,-16),to_sfixed(-0.023,16,-16)),
(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),(to_sfixed(0.055,16,-16),to_sfixed(-0.052,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.012,16,-16)),(to_sfixed(0.018,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(0.028,16,-16),to_sfixed(-0.022,16,-16)),(to_sfixed(0.004,16,-16),to_sfixed(0.019,16,-16)),
(to_sfixed(-0.001,16,-16),to_sfixed(0.025,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(-0.001,16,-16)),
(to_sfixed(-0.025,16,-16),to_sfixed(0.016,16,-16)),(to_sfixed(0.014,16,-16),to_sfixed(-0.014,16,-16)),
(to_sfixed(0.036,16,-16),to_sfixed(0.035,16,-16)),(to_sfixed(0.020,16,-16),to_sfixed(-0.007,16,-16)),
(to_sfixed(0.029,16,-16),to_sfixed(0.014,16,-16)),(to_sfixed(-0.004,16,-16),to_sfixed(-0.012,16,-16)),
(to_sfixed(0.011,16,-16),to_sfixed(-0.013,16,-16)),(to_sfixed(0.006,16,-16),to_sfixed(0.005,16,-16)),
(to_sfixed(0.015,16,-16),to_sfixed(0.002,16,-16)),(to_sfixed(-0.008,16,-16),to_sfixed(0.049,16,-16)),
(to_sfixed(0.048,16,-16),to_sfixed(0.053,16,-16)),(to_sfixed(-0.030,16,-16),to_sfixed(-0.019,16,-16))
);


preamble<=sp&sp&sp&sp&sp&sp&sp&sp&sp&sp&cp&lp&lp;--preamble structure is constructed by concatenating

--adding noise to the preamble
add_noise:for i in 1 to 320 generate
preamble_w_noise(i)<=complex_sum(preamble(i),noise(i));
end generate;
preamble3<=preamble_w_noise&zeros1;

--process of short preamble and preamble with noise correlation
process(clk)
	variable m:integer range 1 to 16:=1;
	variable k:integer range 1 to 335:=1;
	variable corr:sfixed(16 downto -16):=to_sfixed(0,16,-16);
	variable sum:sfixed_vector(1 to 335):=(others=>(to_sfixed(0,16,-16)));
	variable a:integer range 0 to 334:=0;
	
begin
	if (rising_edge(clk)) then
		corr:=complex_mux(sp(m),preamble3(m+a));
		sum(k):=sum(k)+corr;
		if (m<16) then
			m:=m+1;
		else
			m:=1;
			if(a<334) then
				a:=a+1;
			end if;
			Cn(k)<=sum(k);
			if (k<335) then
				k:=k+1;
			end if;
		end if;
	end if;
end process;

--normalization is done by dividing every elements of correlation vector by 2^4=16
normalization3: for i in 1 to 639 generate
	Cnn(i)<=Cn(i) srl 4;
end generate;

--process to represent every elements of the correlation vector one by one in every clock signal
process(temp_clk_out,rst)
begin
	if (rst='1') then
		count3<=1;
	elsif (rising_edge(clk)) then
		if (count3=335) then
			count3<=1;
		else
			count3<=count3+1;
		 end if;
	end if;
end process;
C<=Cnn(count3);
end Behavioral;

