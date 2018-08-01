function tf = csisempty(v)

%   CSISEMPTY -- True for empty cell arrays of strings.
%
%     csisempty( {} ) returns true.
%     csisempty( '' ) returns false, because '' is not an empty cellstr.
%
%     See also csunion, cssetdiff
%
%     IN:
%       - `v` (/any/)
%     OUT:
%       - `tf` (logical)

tf = iscellstr( v ) && numel( v ) == 0;

end