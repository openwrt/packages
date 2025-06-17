use 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Metrics::Any',
  'VERSION_FROM' => 'lib/Metrics/Any.pm',
  'PREREQ_PM' => {
                   'List::Util' => '1.29',
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

