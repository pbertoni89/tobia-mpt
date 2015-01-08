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
[MarkoRisk, MarkoReturn, MarkoWts] = portopt(Rmean, Rcov, edgeSize, [], [], 'algorithm', 'lcprog');
mrkw_time = toc;
minRisk = MarkoWts(1,:)';
fprintf('\nMatlab used %f seconds to calculate %d Markowitz frontier portfolios.', mrkw_time, edgeSize)
fprintf('\nx*(min risk):\t'), printarray(minRisk,'f')
fprintf('\nminimum risk = %f | return = %f %%\n', MarkoRisk(1), Rmean*minRisk*100);
maxRet = MarkoWts(end, :)';
fprintf('\nx*(max return):\t'), printarray(maxRet,'f')
fprintf('\nrisk = %f | maximum return = %f %%\n', MarkoRisk(end), Rmean*maxRet*100);

figure('name', 'Markowitz assets');
bar(1:assets, [minRisk, maxRet]);
strMinRisk = strcat('min risk: ', num2str(MarkoRisk(1)));
strMaxReturn = strcat('max ret:', num2str(MarkoReturn(end)));
legend(strMinRisk,strMaxReturn);
xlabel('assets'), ylabel('share quota')

save('markowitzReturns.txt', 'MarkoReturn', '-ascii')
fprintf('returns to be passed to tobia as z values:\n'); printarray(MarkoReturn','f')

%% Build Tobia frontier
% these are computed with p = 0.51 because a higher p would result in unfeasible (integer) problems
TobiaWts(:,1) = [0 0 0.0024305 0 0 0 0.00071293 0 0 0 0 0 0 0 0 0.00023006 0 0.98224 0 0.0034598 0 0 0 0.00062662 0 0.00048172 0 0.000061495 0 0.001871 0 0 0 0 0 0 0.00038464 0.000055357 0 0 0.0053835 0 0 0 0 0 0 0.000096256 0 0 0.00035758 0.00024068 0 0 0 0 0 0.0012743 0 0 0 0 0 0 0 0 0 0 0 0 0.000095189 0 0 0 0 0 0 0 0 0];
TobiaWts(:,2) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.96262 0 0 0 0 0 0.004951 0 0 0 0.0032476 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.024116 0 0 0 0 0 0 0 0 0 0 0.0014738 0 0 0.0035934 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,3) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.92972 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.059018 0 0 0 0 0 0 0 0 0 0 0.0074667 0 0 0.0037981 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,4) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.91027 0 0 0 0 0 0 0 0.00060422 0 0 0 0 0 0.0013403 0 0 0 0 0 0 0 0 0 0 0 0 0.082281 0 0 0 0 0 0.0055074 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,5) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.89236 0 0 0 0 0 0 0 0.0041994 0 0.0020984 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.099164 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0020554 0 0 0.00011794 0 0 0 0 0 0];
TobiaWts(:,6) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.8693 0 0 0 0 0 0 0 0.0052789 0 0.0026089 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.12281 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,7) = [0 0 0.000053483 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.84647 0 0 0 0 0 0.00082159 0 0.0053252 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.14733 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,8) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.8218 0 0 0 0 0 0.00095966 0 0.0062076 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.17095 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000084065 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,9) = [0 0 0 0 0 0 0 0 0 0 0 0 0 0.00009443 0 0 0 0.78599 0 0 0 0 0 0.00059003 0 0.016039 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.19165 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0056358 0 0 0 0 0 0 0 0 0 0 0];
TobiaWts(:,10)= [0 0 0 0 0 0 0 0.0022915 0 0 0 0 0 0 0 0.0029097 0 0.75454 0 0 0 0 0 0.0034509 0 0.0082623 0 0.0045493 0 0 0 0.00017514 0 0 0 0 0 0 0 0 0 0 0 0 0.21717 0 0 0 0 0 0 0 0 0 0 0.0031958 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00075295 0 0 0.0026985 0 0 0 0 0 0];

%% Frontiers

%plotfrontier(Rstd, Rmean, PortRisk, PortReturn)

% RXStd = std(R*PortWts');
% RXRet = Rmean*PortWts';
% PORTRISK = std( R * PORTWTS' )
% PORTRETURN = mean(R) * PORTWTS'

TobiaRisk = std(R*TobiaWts);
TobiaReturn = Rmean*TobiaWts;

plotfrontiercomparison(Rstd, Rmean, MarkoRisk, MarkoReturn, TobiaRisk, TobiaReturn);

figure('name','Comparison of Marko-Tobia returns');
plot(MarkoReturn, MarkoReturn,'r'), hold on
xlabel('Expected Return'), ylabel('Expected Return')
plot(MarkoReturn, TobiaReturn), legend('\mu_{Marko}', '\mu{Tobia}')

figure('name','Comparison of Marko-Tobia risks');
plot(MarkoReturn, MarkoRisk,'r'), hold on
xlabel('Expected Return'), ylabel('Standard Deviation')
plot(MarkoReturn, TobiaRisk), legend('\sigma_{Marko}', '\sigma{Tobia}')

figure('name','Tobia assets')
bar(1:assets, TobiaWts);
xlabel('assets'), ylabel('share quota')
