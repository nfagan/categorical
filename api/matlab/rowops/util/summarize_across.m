function [t, I] = summarize_across(T, across, vs, fs)

%   SUMMARIZE_ACROSS -- Collapse across variables.
%
%     y = summarize_across( t, across_vars, data_var, f )
%
%     applies function `f` to subsets of the variable `data_var` given by
%     the unique rows of table `t`, ignoring `across_vars`. This collapses
%     across `across_vars` but preserves sets defined by the remaining
%     variables in `t`. `f` must return an array whose first-dimension size
%     is equal to 1.
%
%     y = summarize_across( t, across_vars, data_vars, fs )
%
%     for the string array `data_vars` and cell array of function handles
%     `fs` applies functions to corresponding variables in `data_vars`.
%
%     //  EX
%
%     load('carbig');
%     t = rmmissing(table(Model, Origin, MPG, Displacement, Horsepower, Mfg));
%     % compute average horsepower across models, mpgs, displacements
%     summarize_across(t, {'Model', 'MPG', 'Displacement'}, 'Horsepower', @mean)
%
%     See also summarize_within, findeach, rowsets, groupi, splitapply

[across, vs, fs] = summarize_check( across, vs, fs );
[I, t] = summarize_impl( ...
  T, setdiff(T.Properties.VariableNames, [across, vs]), vs, fs );

end