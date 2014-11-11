%% Introducing the Portfolio Object
%
% Robert Taylor
%
% The MathWorks, Inc.
%
% This script demonstrates the features of the new Portfolio object in Financial Toolbox.
% Specifically, the script illustrates the two-fund theorem, transaction costs, turnover
% constraints, maximum Sharpe and information ratios, and how to set up a 130-30 portfolio.
%
% Copyright 2011 The MathWorks, Inc.

%% Set up the Data
%
% Get asset and market data and set up time series for asset, market, and cash returns. Select a
% time period from the data to use for estimation of asset return moments. Also compute moments of
% market and cash returns.

clc
close all
clear all
load BlueChipStocks

% Select start and end dates for historical estimation period

startindex = find(datenum('30-jan-1998') == Date);
endindex = find(datenum('31-dec-2004') == Date);

assetindex = logical(Map(endindex,:));

AssetList = Asset(assetindex);

% Set up date and return arrays

Date = Date(startindex:endindex);
AssetReturns = Data(startindex:endindex,assetindex);
MarketReturns = Data(startindex:endindex,end-1);
CashReturns = Data(startindex:endindex,end);

% Compute returns and risks for market and cash returns

mret = mean(MarketReturns);
mrsk = std(MarketReturns);
cret = mean(CashReturns);
crsk = std(CashReturns);

%% Create a Portfolio object
%
% Create a Portfolio object with the Portfolio constructor and estimate the mean and covariance of
% asset returns with the method |estimateAssetMoments|. Include the risk-free rate using the most
% recent cash return and specify an equally-weighted initial portfolio with the method
% |setInitPort|. The first figure shows the distribution of risk and return for the assets in the
% universe along with market, cash, and equal-weight risks and returns.

p = Portfolio('AssetList', AssetList, 'RiskFreeRate', CashReturns(end));
p = p.estimateAssetMoments(AssetReturns, 'missingdata', true);

% Set up an equal-weight initial portfolio

p = p.setInitPort(1/p.NumAssets);
[ersk, eret] = p.estimatePortMoments(p.InitPort);

% Plot asset, market, cash, and equal-weight return moments

part1_intro_plot('Asset Risks and Returns', ...
	{'scatter', mrsk, mret, {'Market'}}, ...
	{'scatter', crsk, cret, {'Cash'}}, ...
	{'scatter', ersk, eret, {'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Set up a "Standard" Portfolio Optimization Problem
%
% Set up a "default" portfolio optimization problem with the |setDefaultConstraints| method that
% requires fully-invested long-only portfolios (non-negative weights that must sum to 1). Given this
% initial problem, estimate the efficient frontier with the methods |estimateFrontier| and
% |estimatePortMoments|, where |estimateFrontier| estimates efficient portfolios and
% |estimatePortMoments| estimates risks and returns for portfolios. The figure overlays the
% efficient frontier on the previous plot.

p = p.setDefaultConstraints;
pwgt = p.estimateFrontier(20);
[prsk, pret] = p.estimatePortMoments(pwgt);

% Plot efficient frontier

part1_intro_plot('Efficient Frontier', ...
	{'line', prsk, pret}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Illustrate the Tangent Line to the Efficient Frontier
%
% Tobin's mutual fund theorem says that the portfolio allocation problem can be viewed as a decision
% to allocate between a riskless asset and a risky portfolio. In the mean-variance framework, cash
% serves as a proxy for a riskless asset and an efficient portfolio on the efficient frontier serves
% as the risky portfolio such that any allocation between cash and this portfolio dominates all
% other portfolios on the efficient frontier. This portfolio is called a tangency portfolio because
% it is located at the point on the efficient frontier where a tangent line that originates at the
% riskless asset touches the efficient frontier.

%%
% Given that the Portfolio object already has the risk-free rate, obtain the tangent line by
% creating a copy of the Portfolio object with a budget constraint that permits allocation between
% 0% and 100% in cash. Note that the plot, which shows the efficient frontier with Tobin's
% allocations includes the tangent line to the efficient frontier.

q = p.setBudget(0,1);

qwgt = q.estimateFrontier(20);
[qrsk, qret] = q.estimatePortMoments(qwgt);

% Plot efficient frontier with tangent line (0 to 1 cash)

part1_intro_plot('Efficient Frontier with Tangent Line', ...
	{'line', prsk, pret}, ...
	{'line', qrsk, qret, [], [], 1}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Obtain Range of Risks and Returns
%
% To obtain efficient portfolios with target values of either risk or return, it is necessary to
% obtain the range of risks and returns among all portfolios on the efficient frontier. This can be
% accomplished with the |estimateFrontierLimits| method.

[rsk, ret] = p.estimatePortMoments(p.estimateFrontierLimits);
rsk = sqrt(12)*rsk;
ret = 12*ret;

display(rsk);
display(ret);

%% Find a Portfolio with a Targeted Return and Targeted Risk
%
% Given the range of risks and returns, demonstrate the location of portfolios on the efficient
% frontier that have target values for return and risk using the methods |estimateFrontierByReturn|
% and |estimateFrontierByRisk|.

TargetReturn = 0.20;		% input target annualized return and risk here
TargetRisk = 0.15;

if TargetReturn < ret(1) || TargetReturn > ret(2)
	error('TargetReturn is outside current range of available returns [ %g, %g ].', ...
		ret(1), ret(2));
end
if TargetRisk < rsk(1) || TargetRisk > rsk(2)
	error('TargetRisk is outside current range of available risks [ %g, %g ].', ...
		rsk(1), rsk(2));
end	

awgt = p.estimateFrontierByReturn(TargetReturn/12);
[arsk, aret] = p.estimatePortMoments(awgt);

bwgt = p.estimateFrontierByRisk(TargetRisk/sqrt(12));
[brsk, bret] = p.estimatePortMoments(bwgt);

% Plot efficient frontier with targeted portfolios

part1_intro_plot('Efficient Frontier with Targeted Portfolios', ...
	{'line', prsk, pret}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', arsk, aret, {sprintf('%g%% Return',100*TargetReturn)}}, ...
	{'scatter', brsk, bret, {sprintf('%g%% Risk',100*TargetRisk)}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%%
% To see what these targeted portfolios look like, use the dataset object to set up "blotters" that
% contain the portfolio weights and asset names (which are obtained from the Portfolio object).

aBlotter = dataset({100*awgt(awgt > 0),'Weight'}, 'obsnames', p.AssetList(awgt > 0));

fprintf('Portfolio with %g%% Target Return\n', 100*TargetReturn);
disp(aBlotter);

bBlotter = dataset({100*bwgt(bwgt > 0),'Weight'}, 'obsnames', p.AssetList(bwgt > 0));

fprintf('Portfolio with %g%% Target Risk\n', 100*TargetRisk);
disp(bBlotter);

%% Transactions Costs
%
% The Portfolio object makes it possible to account for transaction costs as part of the
% optimization problem. Although individual costs can be set for each assets, use the scalar
% expansion features of the Portfolio object's methods to set up uniform transaction costs and
% compare efficient frontiers with gross versus net portfolio returns.

BuyCost = 0.0020;
SellCost = 0.0020;

q = p.setCosts(BuyCost, SellCost);

[qwgt, qbuy, qsell] = q.estimateFrontier(20);
[qrsk, qret] = q.estimatePortMoments(qwgt);

% Plot efficient frontiers with gross and net returns

part1_intro_plot('Efficient Frontier with and without Transaction Costs', ...
	{'line', prsk, pret, {'Gross'}, ':b'}, ...
	{'line', qrsk, qret, {'Net'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

disp(sum(qbuy));
disp(sum(qsell));

%% Turnover Constraint
%
% In addition to transaction costs, the Portfolio object can handle turnover constraints. The
% following example demonstrates that a turnover constraint may prevent a single step from a initial
% portfolio to the efficient frontier without the turnover constraint. Note that the sum of
% purchases and sales from the |estimateFrontier| method confirms that the turnover constraint has
% been satisfied.

BuyCost = 0.0020;
SellCost = 0.0020;
Turnover = 0.2;

q = p.setCosts(BuyCost, SellCost);
q = q.setTurnover(Turnover);

[qwgt, qbuy, qsell] = q.estimateFrontier(20);
[qrsk, qret] = q.estimatePortMoments(qwgt);

% Plot efficient frontier with turnover constraint

part1_intro_plot('Efficient Frontier with Turnover Constraint', ...
	{'line', prsk, pret, {'Unconstrained'}, ':b'}, ...
	{'line', qrsk, qret, {sprintf('%g%% Turnover', 100*Turnover)}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

disp(sum(qbuy));
disp(sum(qsell));

%% Subclassing the Portfolio Object
%
% The Sharpe ratio is a measure of return-to-risk that plays an important role in portfolio
% analysis. Specifically, a portfolio the maximizes the Sharpe ratio is also the tangency portfolio
% on the efficient frontier from the mutual fund theorem. To illustrate how to maximize the Sharpe
% ratio, create a subclass of the Portfolio object called PortfolioDemo and add a method
% |maximizeSharpeRatio|. Since this object inherits all the properties and methods of the Portfolio
% object, little more need be done to set up a portfolio optimization problem.

p = PortfolioDemo('AssetList', AssetList, 'RiskFreeRate', CashReturns(end));
p = p.estimateAssetMoments(AssetReturns, 'missingdata', true);
p = p.setDefaultConstraints;
p = p.setInitPort(1/p.NumAssets);

%% Maximize the Sharpe Ratio
%
% The maximum Sharpe ratio portfolio is located on the efficient frontier and the dataset object is
% used to list the assets in the portfolio.

swgt = p.maximizeSharpeRatio;
[srsk, sret] = p.estimatePortMoments(swgt);

% Plot efficient frontier with portfolio that attains maximum Sharpe ratio

part1_intro_plot('Efficient Frontier with Maximum Sharpe Ratio Portfolio', ...
	{'line', prsk, pret}, ...
	{'scatter', srsk, sret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

% Assets in the maximum Sharpe ratio portfolio

Blotter = dataset({100*swgt(swgt > 0),'Weight'}, 'obsnames', AssetList(swgt > 0));

fprintf('Portfolio with Maximum Sharpe Ratio');
disp(Blotter);

%% Confirm that Maximum Sharpe Ratio is a Maximum
%
% The following plot demonstrates that this portfolio indeed maximizes the Sharpe ratio among all
% portfolios on the efficient frontier.

psratio = (pret - p.RiskFreeRate) ./ prsk;
ssratio = (sret - p.RiskFreeRate) / srsk;

subplot(2,1,1);
plot(prsk, pret, 'LineWidth', 2);
hold on
scatter(srsk, sret, 'g', 'filled');
title('\bfEfficient Frontier');
xlabel('Portfolio Risk');
ylabel('Portfolio Return');
hold off

subplot(2,1,2);
plot(prsk, psratio, 'LineWidth', 2);
hold on
scatter(srsk, ssratio, 'g', 'filled');
title('\bfSharpe Ratio');
xlabel('Portfolio Risk');
ylabel('Sharpe Ratio');
hold off

%% Illustrate that Sharpe is the Tangent Portfolio
%
% In addition, this plot demonstrates that the portfolio that maximizes the Sharpe ratio is also a
% tangency portfolio (in this case, the budget constraint is opened up to permit between 0% and 100%
% in cash).

q = p.setBudget(0,1);

qwgt = q.estimateFrontier(20);
[qrsk, qret] = q.estimatePortMoments(qwgt);

% Plot that shows Sharpe ratio portfolio is the tangency portfolio

clf
part1_intro_plot('Efficient Frontier with Maximum Sharpe Ratio Portfolio', ...
	{'line', prsk, pret}, ...
	{'line', qrsk, qret, [], [], 1}, ...
	{'scatter', srsk, sret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Maximum Information Ratio
%
% A related ratio is the information ratio which uses relative returns. The following plot
% demonstrates (using the PortfolioDemo object) how the |maximizeSharpeRatio| methods can also be
% used to maximized the information ratio.

RelativeReturns = AssetReturns - repmat(MarketReturns,1,size(AssetReturns,2));

r = PortfolioDemo('AssetList', AssetList);
r = r.estimateAssetMoments(RelativeReturns, 'missingdata', true);
r = r.setDefaultConstraints;

rwgt = r.estimateFrontier(20);
[rrsk, rret] = r.estimatePortMoments(rwgt);

swgt = r.maximizeSharpeRatio;
[srsk, sret] = r.estimatePortMoments(swgt);

% Plot efficient frontier

part1_intro_plot('Efficient Frontier', ...
	{'line', rrsk, rret}, ...
	{'scatter', srsk, sret, {'Information'}}, ...
	{'scatter', sqrt(diag(r.AssetCovar)), r.AssetMean, r.AssetList, '.r'});

%% Confirm that Maximum Information Ratio is a Maximum
%
% As with the Sharpe ratio, the following plot demonstrates that this portfolio indeed maximizes the
% information ratio among all portfolios on the efficient frontier.

rsratio = rret ./ rrsk;
ssratio = sret/srsk;

subplot(2,1,1);
plot(rrsk, rret, 'LineWidth', 2);
hold on
scatter(srsk, sret, 'g', 'filled');
title('\bfEfficient Frontier');
xlabel('Portfolio Risk');
ylabel('Portfolio Return');
hold off

subplot(2,1,2);
plot(rrsk, rsratio, 'LineWidth', 2);
hold on
scatter(srsk, ssratio, 'g', 'filled');
title('\bfInformation Ratio');
xlabel('Portfolio Risk');
ylabel('Information Ratio');
hold off

%% 130/30 Fund Structure
%
% Finally, the turnover constraint can be used to set up a 130-30 portfolio structure. Since this
% approach does not guarantee that all portfolios on the efficient frontier are actually 130-30
% portfolios, it is necessary to check to identify which portfolios are feasible.

Leverage = 0.3;

q = p.setTurnover(0.5*(1 + 2*Leverage), 0);
q = q.setBounds(-Leverage, (1 + Leverage));

[qwgt, qbuy, qsell] = q.estimateFrontier(20);
[qrsk, qret] = q.estimatePortMoments(qwgt);

[qswgt, qsbuy, qssell] = q.maximizeSharpeRatio;
[qsrsk, qsret] = q.estimatePortMoments(qswgt);

% Plot efficient frontier for a 130-30 fund structure with tangency portfolio

clf
part1_intro_plot('Efficient Frontier with Maximum Sharpe Ratio Portfolio', ...
	{'line', prsk, pret, {'Standard'}, 'b:'}, ...
	{'line', qrsk, qret, {'130-30'}, 'b'}, ...
	{'scatter', qsrsk, qsret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

disp(sum(qbuy));
disp(sum(qsell));

Blotter = dataset({100*qswgt(abs(qswgt) > 1.0e-4), 'Weight'}, ...
	{100*qsbuy(abs(qswgt) > 1.0e-4), 'Long'}, ...
	{100*qssell(abs(qswgt) > 1.0e-4), 'Short'}, ...
	'obsnames', AssetList(abs(qswgt) > 1.0e-4));

fprintf('%g-%g Portfolio with Maximum Sharpe Ratio', 100*(1 + Leverage), 100*Leverage);
disp(Blotter);

disp([ sum(Blotter.Weight), sum(Blotter.Long), sum(Blotter.Short) ]);

fprintf('end of part 1')


%% References
%
% # R. C. Grinold and R. N. Kahn, Active Portfolio Management, 2nd ed., 2000.
% # H. M. Markowitz, �Portfolio Selection,� Journal of Finance, Vol. 1, No. 1, March 1952, pp.
% 77-91.
% # H. M. Markowitz, Portfolio Selection: Efficient Diversification of Investments, John Wiley &
% Sons, Inc., 1959.
% # W. F. Sharpe, �Mutual Fund Performance,� Journal of Business, Vol. 39, No. 1, Part 2, January
% 1966, pp. 119�138.
% # J. Tobin, "Liquidity Preference as Behavior Towards Risk," Review of Economic Studies, Vol. 25,
% No.1, 1958, pp. 65-86.
% # J. L. Treynor and F. Black. �How to Use Security Analysis to Improve Portfolio Selection,�
% Journal of Business, Vol. 46, No. 1, January 1973, pp. 68-86.
