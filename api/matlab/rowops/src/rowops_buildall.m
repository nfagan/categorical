function rowops_buildall()

p = fileparts( which(mfilename) );

rowops_build( p, 'rowmean.cpp' );
rowops_build( p, 'rownanmean.cpp' );
rowops_build( p, 'rowstd.cpp' );
rowops_build( p, 'rownanstd.cpp' );
rowops_build( p, 'rowfnz.cpp' );

end