Supplemental Information from the MathWorks webinar "Using MATLAB to Optimize Portfolios with Financial Toolbox"

It is necessary to have MATLAB version R2011a or higher and to have the following toolboxes to run this code: Financial, Statistics, and Optimization.

1. Files the in portfoliodemo.zip folder are
	readme.txt
	@PortfolioDemo/maximizeSharpeRatio.m
	@PortfolioDemo/PortfolioDemo.m
	BlueChipStocks.mat
	part1_intro.m
	part2_strategy.m
	part3_costs.m
	part4_turnover.m
	part5_hedge.m
	part1_intro_plot.m
	webinar.m

2. The BlueChipStocks.mat file contains monthly asset total returns for all demo scripts. It also contains a Map matrix that identifies which assets were part of the index in the "Market" series at each month in the historical period.

3. The main script is webinar.m. It is in "cell" form and each cell opens one of the 5 scripts (part1 to part5).

4. The first script part1_intro.m shows various ways to work with the Portfolio object.

5. The remaining scripts are backtests with example code to do different types of backtests.

6. A helper function part1_intro_plot.m sets up plots to overaly lines and scatter plots on a single plot.