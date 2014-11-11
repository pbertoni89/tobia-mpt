Tobia portfolio-optimization
======================

This is intended to implement and test some new research papers in MPT.

##Files of interest

- ./**datasets**/
  - TSE.txt |   data entry for our tests. Matrix of returns for 80 shares over 300 periods.
  - TSE.xls |   ibidem. **warning**: spreadsheet OPL import **won't** work on Linux systems!!! :@

- ./**tobia-matlab**/
  - tobiamarkowitzcomparison.m |   unique matlab script of interest after review of Nov, 6th.

- ./**tobia-cplex**/ contains a loadable IBM CPLEX project.
  - tobia-cplex.mod |   the model.
  - tobia-cplex.dat |   the data entry.
