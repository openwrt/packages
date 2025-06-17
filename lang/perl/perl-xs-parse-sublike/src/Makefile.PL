require 5.016;
use ExtUtils::MakeMaker;
if ( ! -e "Sublike.xs" ) {
  die $! unless open SRC, "<lib/XS/Parse/Sublike.xs";
  my $xs = join "", <SRC>;
  close SRC;
  die $! unless open DST, ">Sublike.xs";
  print DST $xs;
  close DST;
}
WriteMakefile
(
  'NAME' => 'XS::Parse::Sublike',
  'VERSION_FROM' => 'lib/XS/Parse/Sublike.pm',
  'PREREQ_PM' => {
                   'ExtUtils::CBuilder' => 0,
                   'File::ShareDir' => '1.00'
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {},
  'INC' => '-I. -Ishare/include -Iinclude -Ihax',
  'C' => ["Sublike.c", glob('src/*.c')],
  'OBJECT' =>'$(O_FILES)',
  'DEFINE' =>'-o $@',
)
;

