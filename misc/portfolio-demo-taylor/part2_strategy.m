%% part2_strategy - Performance evaluation of maximum return/risk ratio portfolios
%
% Copyright 2011 The MathWorks, Inc.

clc
clear all
close all
load BlueChipStocks

% control parameters for backtest

numportfolio = 20;					% number of portfolios on each efficient frontier
window = 60;						% historical estimation window in months
offset = 3;							% shift in time for each frontier in months
cutoff = 0.4;						% this fraction of data in a series must be non-NaN values
relative = true;					% true if relative returns, false if absolute returns
accumulate = true;					% true if accumulation of assets, false if current universe only

imarket = strcmpi('Market', Asset);	% locate "market" series
icash = strcmpi('Cash', Asset);		% locate "cash" series (riskfree rate proxy)

% bookkeeping

pfactor = 12/offset;				% factor to convert periodicity to annual period

if relative
	criterion = 'Information Ratio';
else
	criterion = 'Sharpe Ratio';
end

% form cumulative map of assets (include all prior active assets that are still listed)

if accumulate
	for t = 2:size(Map,1)
		Map(t,:) = Map(t - 1,:) | Map(t,:);
	end
end

% ex-ante and ex-post analysis

PortDate = [];
PortRisk = [];
PortReturn = [];
PortSigma = [];
PortMean = [];
PerfDate = [];
PerfPort = [];
PerfMarket = [];
PerfCash = [];

for t = window:offset:numel(Date)

	% set up date indices for current period

	startindex = t - window + 1;
	endindex = t;
	
	% select "market" series

	Xmarket = Data(startindex:endindex,imarket);
	
	% select assets that are active on the endindex date
	
	iasset = Map(endindex,:);

	% keep series with sufficient numbers of non-NaN values

	imissing = sum(isnan(Data(startindex:endindex,:))) > cutoff*window;
	
	% form active universe for current endindex date

	iasset = logical(iasset) & ~logical(imissing);
	iasset(end-1:end) = 0;		% last two series are not stocks (not used in this step)
		
	% select data for active universe

	A = Asset(iasset);
	X = Data(startindex:endindex,iasset);
	
	fprintf('Estimation period %s to %s with %d assets ...\n', ...
		datestr(Date(startindex)), datestr(Date(endindex)), numel(A));

	% remove "market" from the data (market-neutral relative returns)

	if relative
		X = X - repmat(Xmarket, 1, numel(A));
	end
	
	% construct portfolio object (use RiskFreeRate if not market-neutral)

	p = PortfolioDemo('AssetList', A, 'Name', sprintf('Universe %s', datestr(Date(endindex))));
	if ~relative
		p = PortfolioDemo(p, 'RiskFreeRate', Data(endindex,icash));
	end
	p = p.setDefaultConstraints;
	p = p.estimateAssetMoments(X, 'MissingData', true);
	
	% estimate portfolios on efficient frontier

	pwgt = p.estimateFrontier(numportfolio);

	% estimate portfolio that maximizes the ratio of relative risk to relative return
	%	if absolute returns, then maximize the Sharpe ratio
	
	[swgt, sbuy, ssell] = p.maximizeSharpeRatio;
	[srsk, sret] = p.estimatePortMoments(swgt);
	    
	disp(p.AssetList(swgt > 1.0e-4));
	
	% enter data for 3D frontier

	PortDate = [ PortDate; Date(endindex) ];
	PortRisk = [ PortRisk; sqrt(pfactor)*(p.estimatePortRisk(pwgt))' ];
	PortReturn = [ PortReturn; pfactor*(p.estimatePortReturn(pwgt))' ];

	PortSigma = [ PortSigma; sqrt(pfactor)*srsk ];
	PortMean = [ PortMean; pfactor*sret ];
	
	% evaluate performance

	if (endindex + offset) <= numel(Date)
		Xret = ret2tick(Data(endindex+1:endindex+offset,:));
		Xret = Xret(end,:) - 1;

		PerfDate = [ PerfDate; Date(endindex+offset) ];
		
		PerfPort = [ PerfPort; Xret(iasset)*swgt ];
		PerfMarket = [ PerfMarket; Xret(imarket) ];
		PerfCash = [ PerfCash; Xret(icash) ];
	end
end

% set up dates across 3D frontier

PortDate = repmat(PortDate, 1, numportfolio);

%% plot 3D frontier

figure(1);
surf(PortDate, PortRisk, PortReturn, ...
	'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceLighting', 'phong');
hold on
plot3(PortDate(:,1), PortSigma, PortMean + 1.0e-6, 'w', 'LineWidth', 3);
datetick('x');
ylabel('Portfolio Risk');
zlabel('Portfolio Returns');
title('\bfTime Evolution of Efficient Frontier');
camlight right
view(30, 30);
hold off

figure(2);
plot([datenum(Date(window)); PerfDate], ret2tick([PerfPort, PerfMarket, PerfCash]));
datetick('x');
title('\bfBacktest Performance of Portfolio Strategy');
ylabel('Cumulative Value of $1 Invested 31-Dec-1984');
legend(criterion, 'Market', 'Cash', 'Location', 'NorthWest');

%% summarize results

perf = [PerfPort, PerfMarket, PerfCash];
pmean = pfactor*mean(perf);
pstdev = sqrt(pfactor)*std(perf);
perfret = ret2tick(perf);
ptotret = (perfret(end,:) .^ (pfactor/size(perf,1))) - 1;
pmaxdd = maxdrawdown(perfret);

fprintf('Results for Backtest Period from %s to %s\n',datestr(PortDate(1,1)),datestr(PortDate(end,1)));
fprintf('%18s %12s %12s %12s %12s\n','','Mean','Std.Dev.','Tot.Ret.','Max.DD');
fprintf('%18s %12g %12g %12g %12g\n',criterion, ...
	100*pmean(1),100*pstdev(1),100*ptotret(1),100*pmaxdd(1));
fprintf('%18s %12g %12g %12g %12g\n','Market', ...
	100*pmean(2),100*pstdev(2),100*ptotret(2),100*pmaxdd(2));
fprintf('%18s %12g %12g %12g %12g\n','Cash', ...
	100*pmean(3),100*pstdev(3),100*ptotret(3),100*pmaxdd(3));
