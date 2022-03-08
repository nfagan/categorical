%%  bar plots with error lines

f = fcat.example();
d = fcat.example( 'smalldata' );

% panels are dose, bars are roi's, grouped by monkey. 
[I, id, C] = rowsets( 3, f, 'dose', 'monkey', 'roi' );

clf;
plots.simplest_barsets( d, I, id, plots.cellstr_join(C) );
plots.onelegend( gcf );

%%  bar plots with error lines and individual data points overlaid

f = fcat.example();
d = fcat.example( 'smalldata' );

% panels are dose, bars are roi's, grouped by image, with points labeled by subject (monkey). 
% Use a mask to plot only a couple of image types.
[I, id, C] = rowsets( 4, f, 'dose', 'image', 'roi', {'monkey', 'roi'} ...
  , 'mask', find(f, {'outdoors', 'scrambled', 'ugin'}) ...
);

clf;
plots.simplest_barsets( d, I, id, plots.cellstr_join(C), 'add_points', true );
plots.onelegend( gcf );

%%  bar plots with error lines and individual session-averaged data points overlaid

% Above, there's too many points to show all the data effectively, so first 
% take an average within each session.

f = fcat.example();
d = fcat.example( 'smalldata' );

if ( 0 )
  % alternatively, plot session level averages to begin with.
  [f, I] = retaineach( f, {'session', 'image', 'roi'} );
  d = rowifun( @mean, I, d );
end

[I, id, C] = rowsets( 5, f ...
  , 'dose', 'image', 'roi' ...  % panels are dose, bars are roi's, grouped by image
  , 'session' ...               % take means within each session (x dose x image x roi)
  , {'monkey', 'roi'} ...       % label points based on subject and roi
  , 'mask', find(f, {'outdoors', 'scrambled', 'ugin'}) ...
);

sesh_data = rowdistribute( nan(size(d)), I, rowifun(@mean, I, d) );

clf;
plots.simplest_barsets( d, I, id, plots.cellstr_join(C) ...
  , 'add_points', true ...
  , 'point_col', 5 ...
  , 'point_data', sesh_data ...
);

plots.onelegend( gcf );

%%  boxplots

f = fcat.example();
d = fcat.example( 'smalldata' );

% panels are 'image', groups are 'dose'
[I, id, C] = rowsets( 2, f, 'image', 'dose', 'mask', find(f, {'outdoors', 'scrambled', 'ugit'}) );
[PI, PL] = plots.nest2( id, I, plots.cellstr_join(C) );

clf;
axs = plots.panels( numel(PI), true );
plots.simple_boxsets( axs, d, PI, PL );

%%

