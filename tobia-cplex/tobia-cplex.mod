/*********************************************
 * OPL 12.6.0.0 Model
 * Author: pbertoni
 * Creation Date: Nov 7, 2014 at 2:31:39 PM
 *********************************************/

{string} Products = ...;
{string} Resources = ...;

float Returns[Assets][Periods] = ...;
float Capacity[Resources] = ...;
float Demand[Products] = ...;
float InsideCost[Products] = ...;
float OutsideCost[Products]  = ...;
float p;
float z;

dvar float+ AssetsXj[Assets];
dvar float+ AuxiliaryAt[Periods];

minimize
  sum( p in Products ) 
    ( InsideCost[p] * Inside[p] + OutsideCost[p] * Outside[p] );
   
subject to {
  forall( r in Resources )
    ctCapacity: 
      sum( p in Products ) 
        Consumption[p][r] * Inside[p] <= Capacity[r];

  forall(p in Products)
    ctDemand:
      Inside[p] + Outside[p] >= Demand[p];
      
	ctCapital:
		sum( x in AssetsXj )
}