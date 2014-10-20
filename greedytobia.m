function [ Ii, x , Zi, i, feasible, max_Zi_hist ] = greedytobia( R, z)
%GREEDYTOBIA Gives a greedy solution for the Portfolio Optimization problem.
%   R is a (TxJ) matrix of relative returns of J securities over T periods (or in T different scenarios, which is equivalent).
%	z is the minimum return desired by the decision maker
%	p is the probability with which the z fact will occurr, i.e., Pr( vopt >= z).
%	pdf is the probability distribution function of the T scenarios.
%	max_Zi_hist is a vector with the historic data of maximum Zi reached over iterations.
	[~, T] = size(R);
	
	stop = 0;
	%maxIter = 10*T + 2;	% seems unuseful. at most T iterations will be needed
	max_Zi_hist = [];	% historical improvement
	onesT = ones(1,T);	% preallocating for speed
	zerosT = zeros(1,T);	% preallocating for speed
	unfeasible = -2;	% preallocating for readibility
	i = 1;			% see row 263 of tobia.pdf
	Ii = zerosT;		% see row 263 of tobia.pdf
	
%	fprintf('starting greedy with z = %2.2f%%\n', z)
	while stop==0 %&& i < maxIter
		
		Iprev = Ii;
		
		Fi = zerosT;
		for t=1:T
			if Iprev(t) == 0	% t in [1,T] \ I
				Iprev(t) = 1;
				[~, ~, flag] = lptobia(R, z, Iprev);
				Iprev(t) = 0; 
				if flag ~= unfeasible
					Fi(t) = 1;
				end
			end
		end
		
%		fprintf('\nFi = '), printarray(Fi, 'd'), fprintf('\n')
		if Fi == zerosT
			stop = 1;
			Ii = Iprev;	% returning Iprev as the final Ii
		else
			max_Zi = - Inf;
			ti = 0;
%			fprintf('Ip = '), printarray(Iprev,'d'), fprintf('\n')
			for t=1:T
				if Fi(t) == 1			% t in Fi
					if Iprev(t) == 1	% don't need to unify
						[~, Zi, flag] = lptobia(R, z, Iprev);
					else
						Iprev(t) = 1;	% tmp add of t
						[~, Zi, flag] = lptobia(R, z, Iprev);
						Iprev(t) = 0;	% end of tmp add
					end

					if flag ~= unfeasible
						if Zi > max_Zi
%							fprintf('UP(%d) : %2.16f > %2.16f\n', t, Zi, max_Zi)
							ti = t;
							max_Zi = Zi;
						end
					end
				end
			end
			
			if ti > 0
				Ii(ti) = 1;
%				fprintf('\nadded %d\nIi = ', ti), printarray(Ii, 'd'), fprintf('\n')
				max_Zi_hist = [ max_Zi_hist max_Zi];
			end
			
			if Ii == onesT
				stop = 1;
			else
				i=i+1;
			end
		end
%		fprintf('\n ------ end of %d --------\n', i-1)
	end
	
%	fprintf('final Ii = '), printarray(Iprev,'d')
	[x, Zi, flag] = lptobia(R, z, Ii);
	if flag == unfeasible
		feasible = 0; %fprintf(' is UNfeasible\n')
	else
		feasible = 1; %fprintf(' is Feasible\n')
	end
	max_Zi_hist = - max_Zi_hist;	% since we inverted f_obj for linprog compliance !
	Zi = - Zi;			% since we inverted f_obj for linprog compliance !
end

