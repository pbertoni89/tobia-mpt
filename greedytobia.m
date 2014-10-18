function [ Ii, x , ZI, i, feasible ] = greedytobia( P, z, p)
%GREEDYTOBIA Gives a greedy solution for the Portfolio Optimization problem.
%   P is a (TxJ) matrix of relative returns of J securities over T periods (or in T different scenarios, which is equivalent).
%	z is the minimum return desired by the decision maker
%	p is the probability with which the z fact will occurr, i.e., Pr( vopt >= z).
%	pdf is the probability distribution function of the T scenarios.
	[T, ~] = size(P);
	i = 1;
	Ii = zeros(1, T);
	Iprev = zeros(1, T);
	stop = 0;
	maxIter = 10;
	feasible = 0;
	Zprev = - Inf;
	Zi = - Inf;
	
	while stop==0 && i < maxIter
		
		Fi = zeros(1, T);
		for t=1:T
			if Iprev(t) == 0	% t in [1,T] \ I
				Iprev(t) = 1;
				[x, ~, flag] = lptobia(P, z, Iprev);
				Iprev(t) = 0; 
				if flag == -2
					fprintf('N(%d) ', t);
					Zprev = - Inf;
				else
					fprintf('F(%d) ', t);
					Fi(t) = 1;
				end
			end
		end

		if Fi == zeros(1,T)
			fprintf('\nstop since Fi = zero vector\n')
			stop = 1;
			if Zprev > - Inf
				feasible = 1;
			end
		else
			max_Ztemp = - Inf;
			ti = 0;
			for t=1:T
				if Fi(t) == 1			% t in Fi
					if Iprev(t) == 1	% don't need to unify
						[x, ZI, flag] = lptobia(P, z, Iprev);
					else
						Iprev(t) = 1;		% tmp add of t
						[x, ZI, flag] = lptobia(P, z, Ii);
						Ii(t) = 0;		% end of tmp add
					end
					
	%				fprintf('I(%d)', t), printarray(find(I), 'd')
					if flag == -2
						ZI = - Inf;
					else
						if ZI > max_Ztemp
							fprintf('UP : %f > %f\n', zt, max_zi);
							Ii(ti) = 0;
							ti = t;
							Ii(ti) = 1;
							max_Ztemp = ZI;
						else
							fprintf('DW : %f < %f\n', zt, max_zi);
						end
					end
				end
			end
			
			if Ii == ones(1,T)
				stop = 1;
				fprintf('\nend of %d: stop since I = one vector\n', i)
			else
				fprintf('\nend of %d: I = ', i), printarray(Ii,'d'), disp('')
				i=i+1;
			end
		end
	end
	
	if ZI > - Inf
		fprintf('\ncomputing real sol with Ii = '), printarray(Ii)
		[x, ZI, ~] = lptobia(P, z, Ii);
		feasible = 1;
	end
end

