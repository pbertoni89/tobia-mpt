function [ Ii, x , Zi, i, feasible, max_Zi_hist ] = greedytobia( P, z, p)
%GREEDYTOBIA Gives a greedy solution for the Portfolio Optimization problem.
%   P is a (TxJ) matrix of relative returns of J securities over T periods (or in T different scenarios, which is equivalent).
%	z is the minimum return desired by the decision maker
%	p is the probability with which the z fact will occurr, i.e., Pr( vopt >= z).
%	pdf is the probability distribution function of the T scenarios.
%	max_Zi_hist is a vector with the historic data of maximum Zi reached over iterations.
	[T, ~] = size(P);
	i = 1;
	Ii = zeros(1, T);
	
	stop = 0;
	maxIter = 10;
	feasible = 0;

	max_Zi_hist = [];
	
	while stop==0 && i < maxIter
		
		Iprev = Ii;
		
		Fi = zeros(1, T);
		for t=1:T
			if Iprev(t) == 0	% t in [1,T] \ I
				Iprev(t) = 1;
				[~, ~, flag] = lptobia(P, z, Iprev);
				Iprev(t) = 0; 
				if flag ~= -2
					Fi(t) = 1;
					if flag ~= 1
						flag
					end
				end
			end
		end
		
		fprintf('\nFi = '), printarray(Fi, 'd'), fprintf('\n')
		if Fi == zeros(1,T)
			stop = 1;
			[x, ~, flag] = lptobia(P, z, Iprev);
			if flag == -2
				feasible = 0;
			else
				feasible = 1;
			end
		else
			max_Ztemp = - Inf;
			ti = 0;
			for t=1:T
				if Fi(t) == 1			% t in Fi
					if Iprev(t) == 1	% don't need to unify
						[x, Zi, flag] = lptobia(P, z, Iprev);
					else
						Iprev(t) = 1;	% tmp add of t
						[x, Zi, flag] = lptobia(P, z, Iprev);
						Iprev(t) = 0;		% end of tmp add
					end

					if flag == -2
						Zi = - Inf;
					else
						if Zi > max_Ztemp
							fprintf('\nUP(%d) : %f > %f', ti, Zi, max_Ztemp);
							ti = t;
							max_Ztemp = Zi;
						end
					end
				end
			end
			
			if ti > 0
				Ii(ti) = 1;
				fprintf('\nadded %d to Ii = ', ti), printarray(Ii, 'd'), fprintf('\n')
				max_Zi_hist = [ max_Zi_hist max_Ztemp];
			end
			
			if Ii == ones(1,T)
				stop = 1;
				[x, ~, flag] = lptobia(P, z, Ii);
				if flag == -2
					feasible = 0;
				else
					feasible = 1;
				end
			else
				i=i+1;
			end
		end
		fprintf('\n ------ end of %d --------\n', i-1)
	end
	
	[x, Zi, flag] = lptobia(P, z, Ii);
	if flag == -2
		fprintf('\n\nTHIS IS NOT POSSIBLE !!!!!')
	end
end

