% TIMELINE
%
% 1 -   write a linear program for model (25) of Mansini's paper.
% 
% 2 -   fetch some data and test it. decorate output.
% 
% 3 -   write a linear program for model Tobia.
% 
% 4 -   compare them.
% 
% 5 -   do something with the Portfolio class. try to integrate.

%% Matlab Markowitz estimation

[PortRisk, PortReturn, PortWts] = portopt(Rmean, Rcov)
Nports = length(PortRisk); 
% NumPorts is the number of portfolios generated along the efficient frontier 
% when specific portfolio return values are not requested. 
% The default is 10 portfolios equally spaced between the minimum risk point and the maximum possible return.

minRiskWts = PortWts(1,:);
strMinRisk = strcat('min risk: ', num2str(PortRisk(1)));
maxReturnWts = PortWts(end, :);
strMaxReturn = strcat('max ret:', num2str(PortReturn(end)));

figure('name', 'portfolios');
bar(1:Nassets, [minRiskWts; maxReturnWts]');
legend(strMinRisk,strMaxReturn);

plotfrontier(Rstdev, Rmean, PortRisk, PortReturn)

riskFreeRate = .01;
borrowingRate = .01;
riskAversionCoef = 5;

%hold on
%[RiskyRisk, RiskyReturn, RiskyWts, RiskyFraction, OverallRisk, OverallReturn] = portalloc(PortRisk, PortReturn, PortWts, riskFreeRate, borrowingRate, riskAversionCoef);
%portalloc(PortRisk, PortReturn, PortWts, riskFreeRate, borrowingRate, riskAversionCoef);

% T = 1;
% alpha = 0.5;
% 
% lb = zeros(assets, 1);
% ub = ones(assets, 1);
% 
% mu_0 = 1.0001;
% 
% mu_i = rand(1, assets);
%y_i
%r_jt = 


%% Simple linprog

f = [-5; -4; -6];
A =  [1 -1  1;  3  2  4;    3  2  0];
b = [20; 42; 30];
lb = zeros(3,1);

[x,fval,exitflag,output,lambda] = linprog(f,A,b,[],[],lb);
x'

%% Simple intlinprog

% f = [8 ; 1];
% intcon = 2;
% 
% A = [-1,-2;
%     -4,-1;
%     2,1];
% b = [25;1.25;1.25];
% 
% x = intlinprog(f,intcon,A,b)