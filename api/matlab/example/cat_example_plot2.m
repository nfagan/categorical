fcat.addpath();
y = labeled( fcat.example('smalldata'), fcat.example() );

%%

pl = plotlabeled();

colors = containers.Map();
colors('cron') = 'r';
colors('kubrick') = 'g';
colors('hitch') = 'b';
colors('lager') = [1, 0.25, 1];

pl.fig = figure(1);
pl.add_points = true;
pl.marker_size = 5;
pl.marker_type = '*';
pl.points_are = 'monkey';
pl.points_color_map = colors;
pl.add_legend = true;
pl.one_legend = true;
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
