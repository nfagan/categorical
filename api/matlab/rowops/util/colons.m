function cs = colons(n)

%   COLONS -- N-length vector of colons.
%
%     cs = colons( N ) is a 1xN cell array of colons (':').
%
%     See also rowop, fcat

c = {':'};

try
  cs = c(ones(1, n));
catch err
  throw( err );
end

end