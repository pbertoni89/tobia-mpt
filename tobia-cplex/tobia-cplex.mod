/*********************************************
 * OPL 12.6.0.0 Model
 * Author: pbertoni
 *********************************************/

int NAssets = ...;
int NPeriods = ...;
 
range Assets = 1..NAssets;
range Periods = 1..NPeriods;
range BinaryVariable = 0..1;
range float FloatsBetweenZeroAndOne = 0.0..1.0;

float Returns[Assets][Periods] = ...;
float Probability[Periods] = ...;
float p;
float z;
float K;

dvar float+ Xassets[Assets] in FloatsBetweenZeroAndOne;
dvar int+ Aauxiliary[Periods] in BinaryVariable;

maximize
	sum ( t in Periods )
		sum ( j in Assets )
			(( Return[j][t] * Xassets[j] ) * Probability[t] );
   
subject to {

	forall(t in Periods)
		ctReturns:
			z - sum ( j in Assets ) ( Return[j][t] * Xassets[j] ) <= K * Aauxiliary[t];
	
	ctProbability:
		sum ( t in Periods ) ( Probability[t] * Aauxiliary[t] ) <= 1 - p;
	
	ctCapital:
		sum( x in Xassets ) == 1;
}