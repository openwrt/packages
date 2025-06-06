require 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Struct::Dumb',
  'VERSION_FROM' => 'lib/Struct/Dumb.pm',
  'PREREQ_PM' => {
                   'Scalar::Util' => 0,
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

