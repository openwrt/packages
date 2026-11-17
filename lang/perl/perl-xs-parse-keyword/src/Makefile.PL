require 5.014;
use ExtUtils::MakeMaker;
if ( ! -e "Keyword.xs" ) {
  die $! unless open SRC, "<lib/XS/Parse/Keyword.xs";
  my $xs = join "", <SRC>;
  close SRC;
  die $! unless open DST, ">Keyword.xs";
  print DST $xs;
  close DST;
}
WriteMakefile
(
  'NAME' => 'XS::Parse::Keyword',
  'VERSION_FROM' => 'lib/XS/Parse/Keyword.pm',
  'PREREQ_PM' => {
                   'ExtUtils::CBuilder' => 0,
                   'ExtUtils::ParseXS' => '3.16',
                   'File::ShareDir' => '1.00'
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {},
  'INC' => '-I. -I./hax -I./src -Ishare-infix/include -Ishare-keyword/include',
  'C' => ["Keyword.c", glob('src/*.c')],
  'OBJECT' =>'$(O_FILES)',
  'DEFINE' =>'-o $@',
)
;

