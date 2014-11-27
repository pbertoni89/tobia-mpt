function [] = plotfrontiercomparison( std, m , PortRisk, PortReturn, TobiaRisk, TobiaReturn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure('name','Frontier Comparison')
scatter(std, m)
hold on
plot(PortRisk,PortReturn,  'Color', [0 1 0], 'DisplayName','PortReturn vs. PortRisk','XDataSource','PortRisk','YDataSource','PortReturn')
plot(TobiaRisk,TobiaReturn,'Color', [1 0 0], 'DisplayName','PortReturn vs. PortRisk','XDataSource','PortRisk','YDataSource','PortReturn')
figure(gcf)
xlabel('Risk (Standard Deviation)')
ylabel('Expected Return')
title('Mean-Variance-Efficient Frontier')
grid on
%legend('\{(\mu,\sigma)\}_{ASSETS}','\{(\mu,\sigma)\}_{MARKOWITZ}','\{(\mu,\sigma)\}_{TOBIA}')
%axis([.004 .065 .996 1.003])
end

