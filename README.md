Tobia portfolio optimization
======================

This is intended to implement and test some new research papers in MPT.

##Files of interest

- ./**tobia-matlab**/
  - *tobiamarkowitzcomparison.m* |   unique matlab script of interest after review of Nov, 6th.

- ./**tobia-cplex**/ contains a loadable IBM CPLEX project.
  - *tobia-cplex.mod* 	|   the model.
  - *tobia-cplex.dat* 	|   the data entry.
  - *tobia-cplex.ops*		|	optimization settings. (Untouched from default)
  - *TSE_A80_P300.xlsx* 	|	data entry for our tests. Matrix of returns for 80 shares over 300 periods. **warning**: spreadsheets **won't** work on Linux systems!
  
- ./**logs**/
  - *p_<x>_z_<y>.txt*	| CPLEX log of a run with p = x ; z = y, flavoured with some header informations.
  - *benchmarks.xlsx*	| benchmarks on a test machine (described inside): recordings of a) times b) objective function values.