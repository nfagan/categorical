function conf = cat_buildconfig()

%   CAT_BUILDCONFIG -- Get current build options.
%
%     OUT:
%       - `conf` (struct)

conf = struct();

%
% #define CAT_PRUNE_AFTER_ASSIGN
%
%   if true, calls to setcat() and assign() will also call prune(). In this
%   way, there can be no "dangling" labels left in the object. But this is
%   expensive if the number of rows is very large.
conf.prune_after_assign = false;

end