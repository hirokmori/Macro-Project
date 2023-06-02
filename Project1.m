clc
clear all
close all

startdate = '01/01/1994';
enddate = '01/01/2020';

f = fred

JP = fetch(f,'JPNRGDPEXP',startdate,enddate)
jp = log(JP.Data(:,2));

UK = fetch(f,'CLVMNACSCAB1GQUK',startdate,enddate)
uk = log(UK.Data(:,2));

q = JP.Data(:,1);

T = size(uk,1);

%Hodrick=Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauUKGDP = A\uk;
tauJPGDP = A\jp;

% detrended GDP
uktilde = uk-tauUKGDP;
jptilde = jp-tauJPGDP;

%plot detrended GDP
dates = 1994:1/4:2020.4/4;
figure
title('Detrended log(real GDP) 1994Q1-2020Q4'); hold on
plot(q, uktilde,'b', q, jptilde, 'r')
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
uksd = std(uktilde)*100;
jpsd = std(jptilde)*100;
ukrho = corrcoef(uktilde(2:T),uktilde(1:T-1)); ukrho = ukrho(1,2);
jprho = corrcoef(jptilde(2:T),jptilde(1:T-1)); jprho = jprho(1,2);
corr_uk_jp = corrcoef(uktilde(1:T),jptilde(1:T)); corr_uk_jp = corr_uk_jp(1,2);

disp(['Percent standard deviation of detrended log real GDP for UK: ', num2str(uksd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for JP: ', num2str(jpsd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP: ', num2str(jprho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corr_uk_jp),'.']);