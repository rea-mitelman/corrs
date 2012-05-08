function v=sum_2nd_diags_old(mat)
%sums the secondary diagonals. This is useful for JPSTH matrix, whose sum
% (or average?) of secondary diagonals is the cross-correlation function
[m,n]=size(mat);
if m~=n
    error('This function works only for square marices')
end

v=zeros(1,2*m-1);
diag_degs=(-m+1):(m-1);
for ii = 1:2*m-1
    v(ii)=sum(diag(mat,diag_degs(ii)));
end




% This is an awkward way of doing this...
% [m,n]=size(mat);
% if m~=n
%     error('This function works only for square marices')
% end
% m_rot=rot90(mat,-1);
% lv=2*m-1;
% v=zeros(1,lv);
% for ii = (-m+1):(m-1)
%     v_add=zeros(1,lv);
%     this_diag=diag(m_rot,ii);
%     v_add(abs(ii)+1 : 2 : (abs(ii)+length(this_diag)*2)-1)=this_diag;
%     v=v+v_add;
% end