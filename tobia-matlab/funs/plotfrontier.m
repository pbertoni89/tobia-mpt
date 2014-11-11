function [] = plotfrontier( stdev, m , PortRisk, PortReturn )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure('name','Frontier')
scatter(stdev, m)
hold on
plot(PortRisk,PortReturn,'DisplayName','PortReturn vs. PortRisk','XDataSource','PortRisk','YDataSource','PortReturn')
figure(gcf)
xlabel('Risk (Standard Deviation)')
ylabel('Expected Return')
title('Mean-Variance-Efficient Frontier')
grid on

end

