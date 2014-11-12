clc, clear, close all
format short

max_assets = 80;	% bound complexity
max_periods = 300;	% bound complexity

%300 periodi x 80
%10 pti frontiera efficiente
%p = .8; .9 -> due frontiere

%R = load('SP500.txt');
R = load('TSE_A80_P300.txt');
%R = randn(max_periods, max_assets) * 0.05;		% gaussian(0, 0.05)
%R = abs(randn(max_periods, max_assets) * 0.05);% |gaussian(0, 0.05)|
%R = load('OXM.txt');

[periods, assets] = size(R);

if periods > max_periods
	reduced_periods = randperm(periods);
    reduced_periods = reduced_periods(1:max_periods);
	R = R(reduced_periods, :);
	fprintf('periods have been randomly reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', periods, max_periods);
	periods = max_periods;
end
if assets > max_assets
    reduced_assets = randperm(assets);
    reduced_assets = reduced_assets(1:max_assets);
	R = R(:, reduced_assets); 
	fprintf('assets have been randomly reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', assets, max_assets);
	assets = max_assets;
end

R(any(isnan(R),2),:) = [];  % handle NaNs

if abs(mean(mean(R))-1) < .1	% sort of detrending to have returns relative not to 0% but to 100%.
	R = R - 1;
	fprintf('Returns have been detrended by 1. We are considering marginal rates!\n');
end

Rmean = mean(R); % expected mean return
Rcov = cov(R); % covariance (symm semipos matrix)
Rstdev = std(R);

Rmad = zeros(periods, assets);
for r=1:periods
	Rmad(r,:) = R(r,:) - Rmean;
end

edgeSize = 15;
fprintf('This test uses data for %d shares over %d periods to compute %d portfolios on Markowitz edge.\n', assets, periods, edgeSize)

%% MARKOWITZ
tic
[PortRisk, PortReturn, PortWts] = portopt(Rmean, Rcov, edgeSize, [], [], 'algorithm', 'lcprog');
mrkw_time = toc;
Nports = length(PortRisk);
minRisk = PortWts(1,:)';
fprintf('\nMatlab used %f seconds to calculate %d Markowitz frontier portfolios.', mrkw_time, Nports)
fprintf('\nx*(min risk):\t'), printarray(minRisk,'f')
fprintf('\nminimum risk = %f | return = %f %%\n', PortRisk(1), Rmean*minRisk*100);
maxRet = PortWts(end, :)';
fprintf('\nx*(max return):\t'), printarray(maxRet,'f')
fprintf('\nrisk = %f | maximum return = %f %%\n', PortRisk(end), Rmean*maxRet*100);

plotfrontier(Rstdev, Rmean, PortRisk, PortReturn)

figure('name', 'portfolios');
bar(1:assets, [minRisk, maxRet]);
strMinRisk = strcat('min risk: ', num2str(PortRisk(1)));
strMaxReturn = strcat('max ret:', num2str(PortReturn(end)));
legend(strMinRisk,strMaxReturn);
xlabel('assets'), ylabel('share quota')

save('markowitzReturns', 'PortReturn', '-ascii')
fprintf('returns to be passed to tobia as z values:'); PortReturn'