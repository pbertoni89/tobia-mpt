clc, clear, close all
format short

max_assets = 6;		% bound complexity
max_periods = 12;	% bound complexity

%R = load('SP500.txt');
R = load('OXM.txt');

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
[x, ~] = linprog(f, A, b, Aeq, beq, lb, ub, dumbX0, displayOff);
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
z = 0.001;
R = R';		% don't forget bout it !!!!!!!!!!!
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA (z=%2.2f%%) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n', z*100)

p = .5;
[I, x_tobia, ~, i, feasible, max_Zi_hist] = greedytobia(R, z);
if feasible == 1
	fprintf('\nI*:\t'), printarray(I,'d')
	fprintf('\nx*:\t'), printarray(x_tobia,'f')
	ER_tobia = Rmean * x_tobia * 100; % percent
	fprintf('\nrisk(stdev) = %f | return(mean) = %f %%\n', std(x_tobia), ER_tobia);
	if ~isempty(max_Zi_hist)
		figure('name', 'Evolution of objective function over iterations');
		title_str = sprintf('z=%2.2f%%', z*100); title(title_str)
		axis([ 1, length(max_Zi_hist), min(max_Zi_hist)*.9, max(max_Zi_hist)*1.1])
		plot(1:length(max_Zi_hist), max_Zi_hist)
	end
else
	fprintf('\n This problem is not feasible. Ran %d iterations\n', i);
end

%% TOBIA OVER Z
min_z = -.001;
max_z = +.0015;
trials = 50;
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA linear span %2.2f%% -> %2.2f%%, %d trials ~~~~\n\n', min_z*100, max_z*100, trials)
z_axis = linspace(min_z, max_z, trials);
risk_axis = zeros(1, trials);
return_axis = zeros(1, trials);
iter_axis = zeros(1, trials);
solutions = zeros(assets, trials);
tic
for i = 1 : trials
	[~, x, ~, iter, feasible, ~] = greedytobia(R, z_axis(i));
	if feasible == 1
		solutions(:,i) = x;
		risk_axis(i) = std(x);
		return_axis(i) = Rmean * x * 100;
		iter_axis(i) = iter;
	end
	if mod(i, (trials/10)) == 0
		fprintf('%d%% ', (i/trials)*100)
	end
end
fprintf('\nMatlab used %f seconds to calculate %d Tobia portfolios.\n', toc, trials)

figure('name', ' Tobia greedy algorithm over Z axis: results')
subplot(3,1,1), plot(z_axis, risk_axis,'ro', 'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',5), legend('risk')
subplot(3,1,2), plot(z_axis, return_axis,'ro', 'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',5), legend('return')
subplot(3,1,3), plot(z_axis, iter_axis, 'ro','LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5), legend('iterations')