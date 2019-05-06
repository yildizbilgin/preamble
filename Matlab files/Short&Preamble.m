%Correlation Between noise with Preamble IEEE 802.11a & short preamble
clear all;close all;clc; 
onalti=[0.046+0.046i -0.1324+0.0023i -0.0135-0.0785i 0.1428-0.0127i 0.092 0.1428-0.0127i -0.0135-0.0785i -0.1324+0.0023i...
    0.046+0.046i 0.0023-0.1324i -0.0785-0.0135i -0.0127+0.1428i 0.092i -0.0127+0.1428i -0.0785-0.0135i 0.0023-0.1324i];%short preamble IEEE 802.11a 


otuziki=[(-0.078+0.000j)  (0.012-0.098j)  (0.092-0.106j)     (-0.092-0.115j)...%cyclix prefix  IEEE 802.11a preamble
 (-0.003-0.054j) (0.075+0.074j)  (-0.127+0.021j)  (-0.122+0.017j)...
 (-0.035+0.151j)  (-0.056+0.022j ) (-0.060-0.081j)  (0.070-0.014j)...
 (0.082-0.092j)  (-0.131-0.065j)  (-0.057-0.039j)  (0.037-0.098j)...
 (0.062+0.062j)  (0.119+0.004j)  (-0.022-0.161j)  (0.059+0.015j)...
 (0.024+0.059)  (-0.137+0.047j)  (0.001+0.115j)  (0.053-0.004j)...
 (0.098+0.026j)  (-0.038+0.106j) (-0.115+0.055j)  (0.060+0.088j)...
 (0.021-0.028j)  (0.097-0.083j)  (0.040+0.111j)  (-0.005+0.120j) ]; 
altmisdort=[(0.156+0.000j) (-0.005+(-0.120j))  (0.040+(-0.111j))  (0.097+0.083j)...%long preamble  IEEE 802.11a preamble
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
preamble=[onalti onalti onalti onalti onalti onalti onalti onalti onalti onalti otuziki altmisdort altmisdort ];%IEE 802.11a preamble


sample=100;
st=0.11;%our noise standart deviation constant
a1=0;
std_signal=std(onalti);
for c=1:48%calculation part of correlation
     
   for t=1:sample
       
       nois = st/(sqrt(2)).*((wgn(1,16,0))+(i*wgn(1,16,0)));%noise generation with chageable standart deviation

      x1=onalti;
       y1=nois+onalti;%WE add noise for short preamble
       payda1=0.0413;
              payda2=sum((abs(y1)).^2)^2;
              
             % std_signal=std((y1));
          
                  
      a1(t)=abs((y1)*(x1')).^2;
      
     a2(t)=abs((y1)*(y1')).^2;
 
     



   end
   var1(c)=var(a1./payda1);
     var2(c)=var(a2./payda2);
  k=sum(a1)/payda1;
  m=sum(a2)/payda2;
  n=sum(var1)/payda1;
  p=sum(var2)/payda2;
corrMatlab1(c)=k/sample;
varcorrMatlab1(c)=var(a1)/(sample*payda1);

corrMatlab2(c)=m/sample;
varcorrMatlab2(c)=var(a2)/(sample*payda2);
 crossteori(c)=1;
  ototeori(c)=(std_signal^4)/(((std_signal^2)+(st^2))^2);

 st=st-0.0025;%st=st+0.005 st-0.0001
 
end
  
 
 st2=0.030;
  hs=0;


  nois=st2/sqrt(2).*((wgn(1,320,0))+(i*wgn(1,320,0)));
 y2=preamble+nois;

 hs=abs(xcorr(onalti,y2))./sqrt(0.0413);%we calculate correlation between short preamble and  noise with preamble

  
  
  plot(hs);
  
  
  

  