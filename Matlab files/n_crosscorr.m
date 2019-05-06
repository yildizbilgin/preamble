 function normC=n_crosscorr(x,y)
L=length(x)+length(y)-1;
a=L;
y1=[zeros(1,length(y)-1),y,zeros(1,length(x)-1)];
corr=0;
C=0;
csum=0;
for k=1:L
    

    
    for m=1:length(x)
 
     
     corr=conj(x(m)).*y1(m+a-1);
     csum=corr+csum;

end

a=a-1;
C(k)=csum;
csum=0;
end
normC=C./max(C(:));
end