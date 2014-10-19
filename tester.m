clc, clear, close all
format short

maxAssets = 6;		% bound complexity
maxPeriods = 20;	% bound complexity

R = load('OXM.txt'); %SP500.txt %0XM.txt
[periods, assets] = size(R);

if periods > maxPeriods
	R = R(1:maxPeriods, :);
	fprintf('periods has been reduced from %d to %d to bound complexity.\n\tSorry, buy a faster computer :(\n', periods, maxPeriods);
	periods = maxPeriods;
end
if assets > maxAssets
	R = R(:, 1:maxAssets);
	fprintf('assets has been reduced from %d to %d to bound complexity.\n\tSorry, buy a faster computer :(\n', assets, maxAssets);
	assets = maxAssets;
end

R(any(isnan(R),2),:) = [];  % handle NaNs

if abs(mean(mean(R))-1) < .1	% sort of detrending to have returns relative not to 0% but to 100%.
	R = R -1;
	fprintf('experimental detrend of 1\n');
end

Rmean = mean(R); % expected mean return
Rcov = cov(R); % covariance (symm semipos matrix)

Rmad = zeros(periods, assets);
for r=1:periods
	Rmad(r,:) = R(r,:) - Rmean;
end

fprintf('These tests uses data for %d shares over %d periods.\n', assets, periods)

%% PAPAHRISTODOULOUS
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ PAPAHRISTODOULOUS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')

f = (1/periods) * ones(periods, 1);
f = [ f ; zeros(assets, 1) ];

A = [-eye(periods) Rmad];
b = zeros(size(A,1), 1);

Aeq = [zeros(1, periods) ones(1,assets)];
beq = 1;

lb = zeros(periods+assets, 1);
ub = [ Inf(periods,1) ; ones(assets,1) ];

displayOff = optimset('Display','off');
dumbX0 = zeros(size(f));
[x,~] = linprog(f,A,b,Aeq,beq,lb,ub,dumbX0,displayOff);
x_papa = x(periods+1:end);
ER_papa = Rmean * x_papa * 100;	% percent
fprintf('\nx*:\t'), printarray(x_papa,'f')
fprintf('\nrisk(stdev) = %f | return(mean) = %f %%\n', std(x_papa), ER_papa);

%% MARKOWITZ
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ MARKOWITZ MATLAB STANDARD IMPLEMENTATION ~~~~~~~~\n')
tic
[PortRisk, PortReturn, PortWts] = portopt(Rmean, Rcov);
mrkw_time = toc;
Nports = length(PortRisk);
minRisk = PortWts(1,:)';
fprintf('\nMatlab used %f seconds to calculate %d Markowitz frontier portfolios.', mrkw_time, Nports)
fprintf('\nx*(min risk):\t'), printarray(minRisk,'f')
fprintf('\nminimum risk = %f | return = %f %%\n', PortRisk(1), Rmean*minRisk*100);
maxRet = PortWts(end, :)';
fprintf('\nx*(max return):\t'), printarray(maxRet,'f')
fprintf('\nrisk = %f | maximum return = %f %%\n', PortRisk(end), Rmean*maxRet*100);

%% TOBIA
z = 0.0001;
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA (z=%d%%) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n', z*100)

p = .5;
[I, x_tobia, ~, i, feasible, max_Zi_hist] = greedytobia(R, z, p);
if feasible == 1
	fprintf('\nI*:\t'), printarray(I,'d')
	fprintf('\nx*:\t'), printarray(x_tobia,'f')
	ER_tobia = Rmean * x_tobia * 100; % percent
	fprintf('\nrisk(stdev) = %f | return(mean) = %f %%\n', std(x_tobia), ER_tobia);
	figure('name', 'Evolution of objective function over iterations');
	plot(1:length(max_Zi_hist), max_Zi_hist)
else
	fprintf('\n This problem is not feasible. Ran %d iterations\n', i);
end

%% TOBIA OVER Z
min_z = .001;
max_z = .1;
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA over z ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')

trials = 10;
z_axis = linspace(min_z, max_z, trials);
risk_axis = zeros(1, trials);
return_axis = zeros(1, trials);
iter_axis = zeros(1, trials);
solutions = zeros(assets, trials);
tic
for i = 1 : trials
	[~, x, ~, iter, feasible] = greedytobia(R, z_axis(i), p);
	if feasible ==1
		solutions(:,i) = x;
		risk_axis(i) = std(x);
		return_axis(i) = Rmean * x;
		iter_axis(i) = iter;
	end
	if mod(i, (trials/10))==0
		fprintf('%d%% ', (i/trials)*100)
	end
end
tobia_time = toc;
fprintf('\nMatlab used %f seconds to calculate %d Tobia portfolios.\n', tobia_time, trials)
fprintf('\nz was linearly spanned from %f to %f.\n', min_z, max_z)

figure('name', ' Tobia greedy algorithm over different trials: results')
plot(z_axis, risk_axis, 'r'), hold on
plot(z_axis, return_axis, 'b'), legend('risk', 'return'), xlabel('z')

figure('name', 'Tobia greedy algorithm over different trials: iterations')
bar(z_axis, iter_axis, 'r'), legend('iterations of algorithm'), xlabel('z')