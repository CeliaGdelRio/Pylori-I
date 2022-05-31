function [piJ] = pseudoInverseJacobi(J)
piJ = inv(J' * J) * J';
end

