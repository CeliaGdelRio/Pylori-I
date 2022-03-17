function [beta, phi, r] = cart2hrr(cart)
%CART2HRR Convierte coordenadas cartesianas en parámetros beta y phi del hrr.
[az, el, r] = cart2sph(cart(1), cart(2), cart(3));
beta = 2*az;
phi = el;
end

