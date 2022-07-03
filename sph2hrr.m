function [beta, phi, r] = sph2hrr(sph)
%SPH2HRR Convierte coordenadas esféricas en parámetros beta y phi del hrr.
beta = 2*sph(1);
phi = sph(2);
r = sph(3);
end

