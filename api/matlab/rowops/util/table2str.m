function s = table2str(t, join_with)

%   TABLE2STR -- Convert table rows to string.
%
%     s = table2str( t ); converts each row of the table `t` to a string
%     scalar by first converting values in each column to string, then 
%     joining across columns. Values are prepended with the column name,
%     e.g. ColName=value.
%
%     s = table2str( ..., join_with ); joins strings over columns with the
%     pattern `join_with`. `join_with` is ' | ' by default.
%
%     EX // 
%
%     t = table(rand(4, 1), rand(4, 2), 'va', {'x', 'y'})
%     s = table2str(t)
%
%     See also string, plots.cellstr_join

if ( nargin < 2 ), join_with = ' | '; end

join_with = char( join_with );

validateattributes( t, {'table'}, {}, mfilename, 't' );

s = strings( size(t, 1), 1 );
for idx = 1:size(t, 1)
  s(idx) = row2str( t(idx, :), join_with );
end

end

function s = row2str(t, join_with)

s = "";
for i = 1:size(t, 2)
  tv = t{:, i};
  sp = string( plots.cellstr_join(tv, ', ') );
  if ( isscalar(tv) )
    v = compose( "%s=%s", t.Properties.VariableNames{i}, sp );
  else
    v = compose( "%s=[%s]", t.Properties.VariableNames{i}, sp );
  end
  s = s + v;
  if ( i + 1 <= size(t, 2) ), s = s + join_with; end
end

end