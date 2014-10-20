function [ x, Z_I, flag ] = lptobia( R, z, I )
%LPTOBIA Kernel of the P.O. model by Tobia.
%   R is a (TxJ) matrix of relative returns of J securities over T periods (or in T different scenarios, which is equivalent).
%	z is the minimum return desired by the decision maker
%	p is the probability with which the z fact will occurr, i.e., Pr( vopt >= z).
%	pdf is the probability distribution function of the T scenarios.

	[J, T] = size(R);
	pdf = (1/T) * ones(1, T);		% uniform scenario probability
	f =  - pdf * R';				% see row 228 of tobia.pdf
									% minus since we are maximizing

	Iactive = ones(1,T) - I;		% see row 231 of tobia.pdf
	actives = length(Iactive);		% n° of inequalities, too
	A = zeros(actives, J);			% preallocating for speed
	rowA = 1;
	for i=1:T
		if Iactive(i) == 1			% see row 231 of tobia.pdf
			A(rowA,:) = - R(:,i);	% see row 231 of tobia.pdf
			rowA = rowA+1;
		end
	end
	b = - z * ones(actives, 1);		% see row 231 of tobia.pdf
	
	Aeq = ones(1, J);				% see row 232 of tobia.pdf
	beq = 1;						% see row 231 of tobia.pdf

	lb = zeros(1, J);				% see row 233 of tobia.pdf
	ub = ones(1, J);				% see row 233 of tobia.pdf
	
	displayOff = optimset('Display','off');	% avoid annoying outputs
	[x, Z_I, flag] = linprog(f,A,b,Aeq,beq,lb,ub,[],displayOff);
end