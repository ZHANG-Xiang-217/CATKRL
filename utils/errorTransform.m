function y=errorTransform(delta)

% if delta>=0 && delta<=0.9
%    y=delta/(1-delta); 
% end
% if delta>0.9
%    y=10*delta; 
% end

if delta>=0
   y=delta/(1-delta+1e-4); 
end

if delta==-1
   y=delta; 
end

end