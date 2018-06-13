function rowops_test_run(func)

try
  func();
  fprintf( '\n OK: "%s" passed.', func2str(func) );
catch err
  fprintf( '\n "%s" failed with the following message:\n %s' ...
    , func2str(func), err.message );
end

end