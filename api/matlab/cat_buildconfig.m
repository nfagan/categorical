function conf = cat_buildconfig()

%   CAT_BUILDCONFIG -- Get current build options.
%
%     OUT:
%       - `conf` (struct)

conf = cat_api( 'get_build_config' );
version = cat_api( 'version' );

conf.apiroot = fileparts( which(mfilename) );
conf.version = version;

%
% see: #define CAT_PRUNE_AFTER_ASSIGN
%
%   if true, calls to setcat() and assign() will also call prune(). In this
%   way, there can be no "dangling" labels left in the object. But this is
%   expensive if the number of rows is very large.
% conf.prune_after_assign = false;

% 
% see: #define CAT_USE_PROGENITOR_IDS
%
% conf.use_progenitor_ids = true;

end