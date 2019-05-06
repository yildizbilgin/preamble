close all;
clear all;
clc;



onalti=[(0.023+0.023j)  (-0.132 +0.002j)  (-0.013-0.079j)  (0.143-0.013j)...%short preamble imaginer and real values
 (0.092+0.000j)  (0.143-0.013j)  (-0.013-0.079j)      (-0.132+0.002j)...
(0.046+0.046j) (0.002-0.132j)  (-0.079-0.013j)        (-0.013+0.143j)...
 (0.000 +0.092j) (-0.013+0.143j)  (-0.079-0.013j)     (0.002 -0.132j)];
otuziki=[(-0.078+0.000j)  (0.012-0.098j)  (0.092-0.106j)     (-0.092-0.115j)... %cyclic prefix 
 (-0.003-0.054j) (0.075+0.074j)  (-0.127+0.021j)  (-0.122+0.017j)...
 (-0.035+0.151j)  (-0.056+0.022j ) (-0.060-0.081j)  (0.070-0.014j)...
 (0.082-0.092j)  (-0.131-0.065j)  (-0.057-0.039j)  (0.037-0.098j)...
 (0.062+0.062j)  (0.119+0.004j)  (-0.022-0.161j)  (0.059+0.015j)...
 (0.024+0.059)  (-0.137+0.047j)  (0.001+0.115j)  (0.053-0.004j)...
 (0.098+0.026j)  (-0.038+0.106j) (-0.115+0.055j)  (0.060+0.088j)...
 (0.021-0.028j)  (0.097-0.083j)  (0.040+0.111j)  (-0.005+0.120j) ];
altmisdort=[(0.156+0.000j) (-0.005+(-0.120j))  (0.040+(-0.111j))  (0.097+0.083j)...%long preamble imaginer and real values
  (0.021+0.028j)  (0.060+(-0.088j))  (-0.115+(-0.055j))  (-0.038+(-0.106j))...
  (0.098+(-0.026j))  (0.053+0.004j) (0.001-0.115j) (-0.137-0.047j)...
  (0.024+(-0.059j))  (0.059-0.015j)  (-0.022+0.161j)  (0.119-0.004j)...
  (0.062+(-0.062j))  (0.037+0.098j)  (-0.057+0.039j)  (-0.131+0.065j)...
  (0.082+0.092j)  (0.070+0.014j)  (-0.060+0.081j)  (-0.056-0.022j)...
  (-0.035+(-0.151j))  (-0.122+(-0.017j))  (-0.127+(-0.021j))  (0.075+(-0.074j))...
  (-0.003+(0.054j))  (-0.092+0.115j)  (0.092+0.106j)  (0.012+0.098j)...
  (-0.156+0.000j)  (0.012+(-0.098j))  (0.092+(-0.106j))  (-0.092+(-0.115j))...
  (-0.003+(-0.054j))  (0.075+0.074j)  (-0.127+0.021j)  (-0.122+0.017j)...
  (-0.035+0.151j)  (-0.056+0.022j)  (-0.060-0.081j)  (0.070+(-0.014j))...
  (0.082+(-0.092j))  (-0.131+(-0.065j))  (-0.057+(-0.039j))  (0.037+(-0.098j))...
  (0.062+0.062j)  (0.119+0.004j)  (-0.022+(-0.161j))  (0.059+0.015j)...
  (0.024+0.059j)  (-0.137+0.047j)  (0.001+0.115j)  (0.053+(-0.004j))...
  (0.098+0.026j)  (-0.038+0.106j)  (-0.115+0.055j)  (0.060+0.088j)...
  (0.021+(-0.028j))  (0.097+(-0.083j))  (0.040+0.111j)  (-0.005+0.120j)];
x=[onalti onalti onalti onalti onalti onalti onalti onalti onalti onalti otuziki altmisdort altmisdort ];

y=[onalti zeros(1,304)];%we add zeros to equal our correlation terms



y1=[zeros(1,length(y)-1),y,zeros(1,length(x)-1)];

w=length(x)+length(y)-1;
a=w;
r_xy=0;
r1=0

rkatsayisi1=0
 for L=1:w%for loop calculates correlation coefficients
 for m=1:length(x)
    r_xy=conj(x(m)).*y1(m+a-1);
    r1=r_xy+r1;
    
 end
 a=a-1;
 rkatsayisi1(L)=r1;

 
 
 r1=0;
 end
figure(1);
 stem(rkatsayisi1./max(rkatsayisi1));...%We plot our corrrelation between IEEE 802.11a preamble 
                                         %and short preamble


 title('short preamble correlation ');
 axis([300 600 0 1])
 
 

 r2=0;

r_xy=0;

 yy=[altmisdort zeros(1,256)];
 y11=[zeros(1,length(yy)-1),yy,zeros(1,length(x)-1)];
ww=length(x)+length(yy)-1;
 a=ww;
 for L=1:ww%for loop calculates correlation coefficients
 for m=1:length(x)
    r_xy=conj(x(m)).*y11(m+a-1);
    r2=r_xy+r2;
    
 end
 a=a-1;
 rkatsayisi2(L)=r2;

 
 
 r2=0;
 end
figure(2);
 
 
stem(rkatsayisi2./max(rkatsayisi2));%We plot our corrrelation between IEEE 802.11a preamble 
                                         %and long preamble

 
 title ('long preamble correlation');
axis([300 600 0 1])



abs(real(b))



