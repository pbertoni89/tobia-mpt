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

%% cutoff size
if periods > max_periods
	%reduced_periods = randperm(periods);
    %reduced_periods = reduced_periods(1:max_periods);
	reduced_periods = 1:max_periods;
	R = R(reduced_periods, :);
	%fprintf('periods have been randomly reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', periods, max_periods);
	fprintf('periods have been reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', periods, max_periods);
	periods = max_periods;
end
if assets > max_assets
    %reduced_assets = randperm(assets);
    %reduced_assets = reduced_assets(1:max_assets);
	reduced_assets = 1:max_assets;
	R = R(:, reduced_assets); 
	%fprintf('assets have been randomly reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', assets, max_assets);
	fprintf('assets have been reduced from %d to fixed %d to bound complexity.\n Feel free to lift this condition in tester.m.\n', assets, max_assets);
	assets = max_assets;
end

R(any(isnan(R),2),:) = [];  % handle NaNs

%% detrend
% if abs(mean(mean(R))-1) < .1	% sort of detrending to have returns relative not to 0% but to 100%.
% 	R = R - 1;
% 	fprintf('Returns have been detrended by 1. We are considering marginal rates!\n');
% end

Rmean = mean(R); % expected mean return
Rcov = cov(R); % covariance (symm semipos matrix)
Rstd = std(R);

% Rmad = zeros(periods, assets);
% for r=1:periods
% 	Rmad(r,:) = R(r,:) - Rmean;
% end

edgeSize = 10;
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

figure('name', 'portfolios');
bar(1:assets, [minRisk, maxRet]);
strMinRisk = strcat('min risk: ', num2str(PortRisk(1)));
strMaxReturn = strcat('max ret:', num2str(PortReturn(end)));
legend(strMinRisk,strMaxReturn);
xlabel('assets'), ylabel('share quota')

save('markowitzReturns.txt', 'PortReturn', '-ascii')
fprintf('returns to be passed to tobia as z values:\n'); printarray(PortReturn','f')

%% Build Tobia frontier
TobiaWts(:,1) = [0 0 0 0 0 0 0 0 0 0.00026187 0 0 0.96152 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.037908 0 0 0 0 0 0 0 0 0 0 0 0.00030931 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,2) = [0 0 0 0 0 0 0 0 0 0.000092815 0 0 0.93519 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.064383 0 0 0 0 0 0 0 0 0 0 0 0.00033657 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,3) = [0 0 0 0 0 0 0 0 0 0.00012886 0 0 0.91001 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.089389 0 0 0 0 0 0 0 0 0 0 0 0.0004673 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,4) = [0 0 0 0 0 0 0 0 0 0 0 0 0.87567 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.12433 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,5) = [0 0 0 0 0 0 0 0 0 0.000093669 0 0 0.85374 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0027781 0 0 0 0 0 0 0 0 0 0.0011498 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14012 0 0 0 0 0 0 0.0010047 0 0 0 0 0.0011057 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,6) = [0 0 0 0 0 0 0 0 0 0 0 0 0.83591 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000089582 0 0 0 0 0 0 0 0 0 0 0 0.164 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,7) = [0 0 0 0 0.000098951 0 0 0 0 0 0 0 0.80897 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0013073 0 0 0.014484 0 0 0 0 0 0 0 0 0 0 0 0.17514 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,8) = [0 0 0 0 0 0 0 0 0 0.00067549 0 0 0.7412 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0077158 0 0 0 0 0 0 0 0 0 0 0 0.25041 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,9) = [0 0 0 0 0 0 0 0 0 0 0 0 0.74796 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.017307 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0066105 0 0 0 0 0 0 0 0 0 0 0 0.22287 0 0 0 0 0 0.0052519 0 0 0 0];
TobiaWts(:,10)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];
TobiaWts(:,11)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];
TobiaWts(:,12)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];
TobiaWts(:,13)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];
TobiaWts(:,14)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];
TobiaWts(:,15)= [0 0 0 0 0 0 0 0 0 0 0 0 0.74305 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.021778 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.22382 0 0.0015573 0 0 0 0.0098006 0 0 0 0];

%% Frontiers

%plotfrontier(Rstd, Rmean, PortRisk, PortReturn)

%RXStd = std(R*PortWts');
%RXRet = Rmean*PortWts';
% PORTRISK = std( R * PORTWTS' )
% PORTRETURN = mean(R) * PORTWTS'

TobiaRisk = std(R*TobiaWts);
TobiaReturn = Rmean*TobiaWts;

plotfrontiercomparison(Rstd, Rmean, PortRisk, PortReturn, TobiaRisk, TobiaReturn);
