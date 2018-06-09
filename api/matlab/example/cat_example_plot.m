
y = labeled( fcat.example('smalldata'), fcat.example() );

%%
tic;

pl = plotlabeled();

colors = containers.Map();
colors('cron') = 'r';
colors('kubrick') = 'g';
colors('hitch') = 'b';
% colors('lager') = 'y';

pl.fig = figure(1);
pl.add_points = true;
pl.marker_size = 8;
pl.marker_type = '*';
pl.points_are = 'monkey';
pl.points_color_map = colors;
pl.add_legend = true;
pl.one_legend = true;
% pl.y_lims = [ 1800, 2300 ];

pl.error_func = @plotlabeled.sem;
pl.color_func = @hsv;
pl.x_order = { 'saline', 'low', 'high' };
pl.panel_order = { 'face', 'image' };
pl.group_order = { 'social', 'outdoors', 'scrambled' };
pl.x_tick_rotation = 0;
pl.add_errors = true;

z = y';

ind = find( z, {'scrambled', 'outdoors'} );
rest = setdiff( 1:size(z, 1), ind );

z(rest, 'image') = 'social';

each( z, {'dose', 'image', 'monkey', 'roi'}, @(x) mean(x, 1) );

axs = pl.bar( z, 'dose', {'image'}, {'roi'} );

ylabel( axs(1), 'Looking duration' );

toc;

%%

z = only( y', {'scrambled', 'outdoors', 'ugit'} );
setdata( z, [z.data, z.data, z.data] );

pl.x = [];
pl.add_errors = false;
pl.smooth_func = @(x) smooth(x, 1);
pl.add_smoothing = false;
pl.match_y_lims = true;
pl.group_order = { 'outdoors' };

pl.lines( z, 'image', 'roi' );
