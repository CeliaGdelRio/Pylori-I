function m = manipulability(J)
%MANIPULABILITY Returns the Yoshikawa's manipulability parameter.
%   manipulability(J) - Manipulability for a given Jacobian Matrix.
m = sqrt(det(J*J'));
end

