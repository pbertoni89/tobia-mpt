%% Using Quadratic Programming on Portfolio Optimization Problems
% This example shows how to solve portfolio optimization problems using the 
% interior-point quadratic programming algorithm in |quadprog|. The function
% |quadprog| belongs to Optimization Toolbox(TM).
%
% The matrices that define the problems in this example are dense; however, the 
% interior-point algorithm in |quadprog| can also exploit sparsity in the problem 
% matrices for increased speed. See the examples section of Optimization Toolbox 
% documentation for a sparse example.

%   Copyright 2010-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2012/02/21 23:24:53 $

%% The Quadratic Model
% Suppose that there are $n$ different assets. The rate of return of asset
% $i$ is a random variable with expected value $m_i$. The problem is to
% find what fraction $x_i$ to invest in each asset $i$ in order to minimize
% risk, subject to a specified minimum expected rate of return.
%
% Let $C$ denote the covariance matrix of rates of asset returns.
%
% The classical mean-variance model consists of minimizing portfolio risk, as 
% measured by
%
% $$\textstyle\frac{1}{2}x^T C x$$
%
% subject to a set of constraints.
%
% The expected return should be no less than a minimal rate of portfolio return 
% $r$ that the investor desires,
%
% $$\sum_{i=1}^n m_i \; x_i \ge r,$$
%
% the sum of the investment fractions $x_i$'s should add up to a total of one,
%
% $$\sum_{i=1}^n x_i = 1,$$
%
% and, being fractions (or percentages), they should be numbers between zero 
% and one,
%
% $$0 \le x_i \le 1, \;\;\; i = 1 \ldots n.$$
%
% Since the objective to minimize portfolio risk is quadratic, and the 
% constraints are linear, the resulting optimization problem is a quadratic 
% program, or QP.

%% 225-Asset Problem
% Let us now solve the QP with 225 assets. The dataset is from the OR-Library 
% [Chang, T.-J., Meade, N., Beasley, J.E. and Sharaiha, Y.M., "Heuristics for 
% cardinality constrained portfolio optimisation" Computers & Operations 
% Research 27 (2000) 1271-1302].
%
% We load the dataset and then set up the constraints in a format expected by 
% |quadprog|. In this dataset the rates of return $m_i$ range between -0.008489 
% and 0.003971; we pick a desired return $r$ in between, e.g., 0.002 (0.2 percent).

% Load dataset stored in a MAT-file.
load('port5.mat','Correlation','stdDev_return','mean_return') 
% Calculate covariance matrix from correlation matrix.
Covariance = Correlation .* (stdDev_return * stdDev_return');
nAssets = numel(mean_return); r = 0.002;     % number of assets and desired return
Aeq = ones(1,nAssets); beq = 1;              % equality Aeq*x = beq
Aineq = -mean_return'; bineq = -r;           % inequality Aineq*x <= bineq
lb = zeros(nAssets,1); ub = ones(nAssets,1); % bounds lb <= x <= ub
c = zeros(nAssets,1);                        % objective has no linear term; set it to zero

%% Select the Interior Point Algorithm in Quadprog
% In order solve the QP using the interior-point algorithm, we set the option 
% Algorithm to 'interior-point-convex'.

options = optimset('Algorithm','interior-point-convex');

%% Solve 225-Asset Problem
% We now set some additional options, and call the solver quadprog.

% Set additional options: turn on iterative display, and set a tighter optimality termination tolerance.
options = optimset(options,'Display','iter','TolFun',1e-10);

% Call solver and measure wall-clock time.
tic
[x1,fval1] = quadprog(Covariance,c,Aineq,bineq,Aeq,beq,lb,ub,[],options); 
toc

% Plot results.
plotPortfDemoStandardModel(x1)

%% 225-Asset Problem with Group Constraints
% We now add to the model group constraints that require that 30% of the 
% investor's money has to be invested in assets 1 to 75, 30% in assets 76 
% to 150, and 30% in assets 151 to 225. Each of these groups of assets could
% be, for instance, different industries such as technology, automotive,
% and pharmaceutical. The constraints that capture this new requirement are
%
% $$\sum_{i=1}^{75}    x_i \ge 0.3, \qquad$$
% $$\sum_{i=76}^{150}  x_i \ge 0.3, \qquad$$
% $$\sum_{i=151}^{225} x_i \ge 0.3.$$

% Add group constraints to existing equalities. 
Groups = blkdiag(ones(1,nAssets/3),ones(1,nAssets/3),ones(1,nAssets/3));
Aineq = [Aineq; -Groups];         % convert to <= constraint 
bineq = [bineq; -0.3*ones(3,1)];  % by changing signs

% Call solver and measure wall-clock time.
tic
[x2,fval2] = quadprog(Covariance,c,Aineq,bineq,Aeq,beq,lb,ub,[],options);
toc

% Plot results, superimposed to results from previous problem.
plotPortfDemoGroupModel(x1,x2);

%% Summary of Results So Far
% We see from the second bar plot that, as a result of the additional group 
% constraints, the portfolio is now more evenly distributed across the three 
% asset groups than the first portfolio. This imposed diversification also 
% resulted in a slight increase in the risk, as measured by the objective 
% function (see column labelled "f(x)" for the last iteration in the iterative 
% display for both runs).

%% 1000-Asset Problem Using Random Data
% In order to show how |quadprog|'s interior-point algorithm behaves on a
% larger problem, we'll use a 1000-asset randomly generated dataset.
% We generate a random correlation matrix (symmetric, positive-semidefinite, 
% with ones on the diagonal) using the |gallery| function in MATLAB(R).

% Reset random stream for reproducibility.
rng(0,'twister');

nAssets = 1000; % desired number of assets
% Generate means of returns between -0.1 and 0.4.
a = -0.1; b = 0.4;
mean_return = a + (b-a).*rand(nAssets,1);
% Generate standard deviations of returns between 0.08 and 0.6.
a = 0.08; b = 0.6;
stdDev_return = a + (b-a).*rand(nAssets,1);
% Correlation matrix, generated using Correlation = gallery('randcorr',nAssets).
% (Generating a correlation matrix of this size takes a while, so we load
% a pre-generated one instead.)
load('correlationMatrixDemo.mat','Correlation');
% Calculate covariance matrix from correlation matrix.
Covariance = Correlation .* (stdDev_return * stdDev_return');

%% Define and Solve Randomly Generated 1000-Asset Problem
% We now define the standard QP problem (no group constraints here) and solve.

r = 0.15;                                     % desired return
Aeq = ones(1,nAssets); beq = 1;               % equality Aeq*x = beq
Aineq = -mean_return'; bineq = -r;            % inequality Aineq*x <= bineq
lb = zeros(nAssets,1); ub = ones(nAssets,1);  % bounds lb <= x <= ub
c = zeros(nAssets,1);                         % objective has no linear term; set it to zero

% Call solver and measure wall-clock time.
tic
x3 = quadprog(Covariance,c,Aineq,bineq,Aeq,beq,lb,ub,[],options);
toc

%% Summary
% This example illustrates how to use the interior-point algorithm in |quadprog| on 
% a portfolio optimization problem, and shows the algorithm running times on 
% quadratic problems of different sizes. The runs were made on a 64-bit, 8-core, 
% 3 GHz Intel(R) Xeon(R) cpu with 12 gigabytes of memory running Linux(R) operating 
% system.
% 
% More elaborate analyses are possible by using features specifically designed 
% for portfolio optimization in Financial Toolbox(TM).


displayEndOfDemoMessage(mfilename)


