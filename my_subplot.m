function my_subplot(siz,p_i,p_j)
% my_subplot(m,n,p_i,p_j)
% Similar to subplot function, but chooses the (p_i,p_j) location within
% the m x n figure, instead of the convention used in the subplot function.

subplot(siz(1),siz(2),sub2ind(siz,p_i,p_j))