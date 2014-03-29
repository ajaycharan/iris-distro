function [C, d, volume] = maximize_ellipse_in_polyhedron(A,b,C,d)
import mosek_lownerjohn.lownerjohn_inner;

dim = size(A,2);


if dim == 2
  % the mosek-provided lowenerjohn_inner fails when dim == 2
  [C,d] = lownerjohn_inner([A, zeros(size(A,1),1);
                            0, 0, 1;
                            0, 0, -1;], [b; 1; 1]);
  C = C(1:2,1:2);
  d = d(1:2);
elseif dim == 3
  [C,d] = lownerjohn_inner(A,b);
else 
  % The Mosek code also seems to fail for any dim > 3, 
  % so we'll fall back to CVX
  cvx_begin sdp quiet
    cvx_solver Mosek
    variable C(dim,dim) semidefinite
    variable d(dim)
  %   maximize(log_det(C));
    maximize(det_rootn(C))
  %     maximize(trace(C))
    subject to
      for i = 1:length(b)
        [(b(i) - A(i,:) * d) * eye(dim), C * (A(i,:)');
         (C * (A(i,:)'))', (b(i) - A(i,:) * d)] >= 0;
      end
  cvx_end
end

volume = det(C);

