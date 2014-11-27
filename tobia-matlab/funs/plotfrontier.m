function [] = plotfrontier( std, m , PortRisk, PortReturn )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure('name','Frontier')
scatter(std, m)
hold on
plot(PortRisk,PortReturn,'DisplayName','PortReturn vs. PortRisk','XDataSource','PortRisk','YDataSource','PortReturn')
figure(gcf)
xlabel('Risk (Standard Deviation)')
ylabel('Expected Return')
title('Mean-Variance-Efficient Frontier')
grid on

end

