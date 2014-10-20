%% part4_turnover - Impact of Turnover on Portfolio Optimization
%
% Copyright 2011 The MathWorks, Inc.

load BlueChipStocks

% control parameters for backtest

numportfolio = 20;					% number of portfolios on each efficient frontier
window = 60;						% historical estimation window in months
offset = 3;							% shift in time for each frontier in months
cutoff = 0.4;						% this fraction of data in a series must be non-NaN values
relative = true;					% true if relative returns, false if absolute returns
accumulate = true;					% true if accumulation of assets, false if current universe only

buycost = 0.0020;					% proportional cost to purchase shares
sellcost = 0.0020;					% proportional cost to sell shares
maxturnover = 0.4;					% upper bound for portfolio turnover (annual)

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

% ex-ante analysis

PortDate = [];
PortRisk = [];
PortReturn = [];
PortSigma = [];
PortMean = [];

PerfDate = [];
GrossPerfPort = [];
ExtrinsicPerfPort = [];
IntrinsicPerfPort = [];
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
		datestr(Date(startindex)), datestr(Date(endindex)),numel(A));

	% map prior portfolios into current universe
	
	if t > window
		pinit = zeros(numel(iasset0),1);
		qinit = zeros(numel(iasset0),1);
		rinit = zeros(numel(iasset0),1);
		
		% adjust prior portfolio weights for prior period's returns
		retinit = Xret(iasset0);
		
		pinit(iasset0) = (1/(1 + retinit*pwgt))*((1 + retinit') .* pwgt);
		qinit(iasset0) = (1/(1 + retinit*qwgt))*((1 + retinit') .* qwgt);
		rinit(iasset0) = (1/(1 + retinit*rwgt))*((1 + retinit') .* rwgt);
	end

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
	if t > window
		if sum(pinit(iasset)) < 0.99		% lift turnover constraint if asset kicked out
			p = p.setTurnover(min(1, maxturnover), pinit(iasset));
		else
			p = p.setTurnover(maxturnover/pfactor, pinit(iasset));
		end
	end
	
	% set up portfolio objects for net returns
	
	q = p;		% extrinsic net returns
	
	r = p.setCosts(buycost, sellcost, 0);		% intrinsic net returns
	if t > window
		if sum(rinit(iasset)) < 0.99		% lift turnover constraint if asset kicked out
			r = r.setTurnover(min(1, maxturnover), rinit(iasset));
		else
			r = r.setTurnover(maxturnover/pfactor, rinit(iasset));
		end
	end
	
	% estimate portfolios on turnover-constrained frontier
	
	fwgt = r.estimateFrontier(numportfolio);
	
	% estimate portfolio that maximizes the ratio of relative risk to relative return
	%	if absolute returns, then maximize the Sharpe ratio
	
	pwgt = p.maximizeSharpeRatio;
	[prsk, pret] = p.estimatePortMoments(pwgt);
	
	qwgt = q.maximizeSharpeRatio;
	[qrsk, qret] = q.estimatePortMoments(qwgt);

	rwgt = r.maximizeSharpeRatio;
	[rrsk, rret] = r.estimatePortMoments(rwgt);
	
	% enter data for 3D frontier
	
	PortDate = [ PortDate; Date(endindex) ];
	PortRisk = [ PortRisk; sqrt(pfactor)*(p.estimatePortRisk(fwgt))' ];
	PortReturn = [ PortReturn; pfactor*(p.estimatePortReturn(fwgt))' ];

	PortSigma = [ PortSigma; sqrt(pfactor)*rrsk ];
	PortMean = [ PortMean; pfactor*rret ];

	% evaluate performance

	if (endindex + offset) <= numel(Date)
		Xret = ret2tick(Data(endindex+1:endindex+offset,:));
		Xret = Xret(end,:) - 1;

		PerfDate = [ PerfDate; Date(endindex+offset) ];
		
		% gross portfolio return
		if t > window
			pcurrent = zeros(numel(iasset),1);
			pcurrent(iasset) = pwgt;
			pbuy = max(0, pcurrent - pinit);
			psell = max(0, pinit - pcurrent);
			pcost = 0;
			pturnover = pturnover + 0.5*(sum(pbuy) + sum(psell));
		else
			pcost = 0;
			pturnover = 0;
		end
		GrossPerfPort = [ GrossPerfPort; Xret(iasset)*pwgt ];

		% extrinsic net portfolio return
		if t > window
			qcurrent = zeros(numel(iasset),1);
			qcurrent(iasset) = qwgt;
			qbuy = max(0, qcurrent - qinit);
			qsell = max(0, qinit - qcurrent);
			qcost = buycost*sum(qbuy) + sellcost*sum(qsell);
			qturnover = qturnover + 0.5*(sum(qbuy) + sum(qsell));
		else
			qcost = 0;
			qturnover = 0;
		end
		ExtrinsicPerfPort = [ ExtrinsicPerfPort; (Xret(iasset)*qwgt - qcost) ];
	
		% intrinsic net portfolio return
		if t > window
			rcurrent = zeros(numel(iasset),1);
			rcurrent(iasset) = rwgt;
			rbuy = max(0, rcurrent - rinit);
			rsell = max(0, rinit - rcurrent);
			rcost = buycost*sum(rbuy) + sellcost*sum(rsell);
			rturnover = rturnover + 0.5*(sum(rbuy) + sum(rsell));
		else
			rcost = 0;
			rturnover = 0;
		end
		IntrinsicPerfPort = [ IntrinsicPerfPort; (Xret(iasset)*rwgt - rcost) ];

		PerfMarket = [ PerfMarket; Xret(imarket) ];
		PerfCash = [ PerfCash; Xret(icash) ];
	end
	
	% save information from current period to be used in next period
	
	iasset0 = iasset;
end

% set up dates across 3D frontier

PortDate = repmat(PortDate, 1, numportfolio);

%% plot results

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
plot([datenum(Date(window)); PerfDate], ...
	ret2tick([GrossPerfPort, ExtrinsicPerfPort, IntrinsicPerfPort, PerfMarket, PerfCash]));
datetick('x');
title('\bfBacktest Performance of Portfolio Strategy');
ylabel('Cumulative Value of $1 Invested 31-Dec-1984');
legend('Gross', 'Extrinsic', 'Intrinsic', 'Market', 'Cash', 'Location', 'NorthWest');

%% summarize results

perf = [GrossPerfPort, ExtrinsicPerfPort, IntrinsicPerfPort, PerfMarket, PerfCash];
pmean = pfactor*mean(perf);
pstdev = sqrt(pfactor)*std(perf);
perfret = ret2tick(perf);
ptotret = (perfret(end,:) .^ (pfactor/size(perf,1))) - 1;
pmaxdd = maxdrawdown(perfret);

fprintf('Results for Backtest Period from %s to %s\n',datestr(Date(window)),datestr(PerfDate(end)));
fprintf('%14s %12s %12s %12s %12s %12s\n','','Mean','Std.Dev.','Tot.Ret.','Max.DD','Turnover');
fprintf('%14s %12g %12g %12g %12g %12g\n','Gross', ...
	100*pmean(1),100*pstdev(1),100*ptotret(1),100*pmaxdd(1),100*pfactor*pturnover/numel(PerfDate));
fprintf('%14s %12g %12g %12g %12g %12g\n','Extrinsic Net', ...
	100*pmean(2),100*pstdev(2),100*ptotret(2),100*pmaxdd(2),100*pfactor*qturnover/numel(PerfDate));
fprintf('%14s %12g %12g %12g %12g %12g\n','Intrinsic Net', ...
	100*pmean(3),100*pstdev(3),100*ptotret(3),100*pmaxdd(3),100*pfactor*rturnover/numel(PerfDate));
fprintf('%14s %12g %12g %12g %12g\n','Market', ...
	100*pmean(4),100*pstdev(4),100*ptotret(4),100*pmaxdd(4));
fprintf('%14s %12g %12g %12g %12g\n','Cash', ...
	100*pmean(5),100*pstdev(5),100*ptotret(5),100*pmaxdd(5));
