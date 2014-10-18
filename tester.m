clc, clear, close all
format short

R = load('OXM.txt'); %SP500.txt
[Nperiods, Nassets] = size(R);

R(any(isnan(R),2),:) = [];  % handle NaNs

Rmean = mean(R); % expected mean return
Rcov = cov(R); % covariance (symm semipos matrix)
Rstdev = std(R);

Rmad = zeros(Nperiods, Nassets);
for r=1:Nperiods
	Rmad(r,:) = R(r,:) - Rmean;
end

fprintf('These tests uses data for %d shares over %d periods.\n', Nassets, Nperiods)

%% PAPAHRISTODOULOUS
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ PAPAHRISTODOULOUS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')

f = (1/Nperiods) * ones(Nperiods, 1);
f = [ f ; zeros(Nassets, 1) ];

A = [-eye(Nperiods) Rmad];
b = zeros(size(A,1), 1);

Aeq = [zeros(1, Nperiods) ones(1,Nassets)];
beq = 1;

lb = zeros(Nperiods+Nassets, 1);
ub = [ Inf(Nperiods,1) ; ones(Nassets,1) ];

displayOff = optimset('Display','off');
dumbX0 = zeros(size(f));
[x,~] = linprog(f,A,b,Aeq,beq,lb,ub,dumbX0,displayOff);
x_papa = x(Nperiods+1:end);
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
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA (z=1%%) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')

z = 0.01;
p = .5;
[I,x_tobia,~,~, feasible] = greedytobia(R,z,p);
if feasible == 1
	fprintf('\nI*:\t'), printarray(I,'d')
	fprintf('\nx*:\t'), printarray(x_tobia,'f')
	ER_tobia = Rmean * x_tobia * 100; % percent
	fprintf('\nrisk(stdev) = %f | return(mean) = %f %%\n', std(x_tobia), ER_tobia);
else
	fprintf('\n This problem is not feasible\n');
end

min_z = .001;
max_z = .01;
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~ TOBIA over z ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n')

trials = 10;
z_axis = linspace(min_z, max_z, trials);
risk_axis = zeros(1, trials);
return_axis = zeros(1, trials);
iter_axis = zeros(1, trials);
tic
for i = 1 : trials
	[~,x,~,iter,feasible] = greedytobia(R, z_axis(i), p);
	if feasible ==1
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
