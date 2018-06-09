x = get_example_container();

% x = extend( x, x, x, x, x, x );

y = labeled.from(x);

%%
tic;

pl = plotlabeled();

colors = containers.Map();
colors('cron, high') = 'r';
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
pl.x_order = { 'high', 'low', 'saline' };
pl.panel_order = { 'face', 'image' };
pl.group_order = { 'social', 'outdoors', 'scrambled' };
pl.x_tick_rotation = 0;
pl.add_errors = true;

inputs = { 'dose', {'image'}, {'roi'} };

z = y';

ind = find( z, {'scrambled', 'outdoors'} );
rest = setdiff( 1:size(z, 1), ind );

z(rest, 'image') = 'social';

z = each( z, {'dose', 'image', 'monkey', 'roi'}, @(x) mean(x, 1) );

axs = pl.bar( z, inputs{:} );

ylabel( axs(1), 'Looking duration' );

toc;

%%

tic;

z = only( y', {'scrambled', 'outdoors', 'ugit'} );
setdata( z, [z.data, z.data, z.data] );

pl.x = [];
pl.add_errors = false;
pl.smooth_func = @(x) smooth(x, 1);
pl.add_smoothing = false;
pl.match_y_lims = true;
pl.group_order = { 'outdoors' };

pl.lines( z, 'image', 'roi' );
toc;
%%
tic;

clf( gcf );

pl2 = ContainerPlotter();
pl2.order_groups_by = { 'social' };

z = x;

ind = z.where({'outdoors','scrambled'});
z('image', ~ind) = 'social';

z = each1d( z, {'dose', 'image', 'monkey', 'roi'}, @(x) mean(x, 1) );

pl2.bar( z, inputs{:} );
toc;
