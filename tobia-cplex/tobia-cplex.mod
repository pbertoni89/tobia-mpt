int nAssets = ...;	// refer to .dat files
int nPeriods = ...;	// refer to .dat files
 
range Assets = 1..nAssets;
range Periods = 1..nPeriods;
range BinaryVariable = 0..1;
range float FloatsBetweenZeroAndOne = 0.0..1.0;

float Returns[Assets][Periods] = ...;	// refer to .dat files
float Probability[Periods];
float p = ...;	// refer to .dat files
float z = ...;	// refer to .dat files
float K = 10000000;	// huge constant

execute UNIFORM_PROBABILITY
{
	for( var i in Periods )
	{
		Probability[i] = 1/nPeriods;
	}
}

dvar float X[Assets] in FloatsBetweenZeroAndOne;
dvar int A[Periods] in BinaryVariable;

maximize
	sum ( t in Periods )
		sum ( j in Assets )
			( Returns[j][t] * X[j] * Probability[t] );
   
subject to
{
	forall( t in Periods )
		ctReturns:
			z - sum ( j in Assets ) ( Returns[j][t] * X[j] ) <= K * A[t];
	
	ctProbability:
		sum ( t in Periods ) ( Probability[t] * A[t] ) <= 1 - p;
	
	ctCapital:
		sum( j in Assets ) ( X[j] ) == 1;
}