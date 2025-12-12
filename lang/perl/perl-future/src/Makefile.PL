require 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Future',
  'VERSION_FROM' => 'lib/Future.pm',
  'PREREQ_PM' => {
                   'Carp' => '1.25',
                   'List::Util' => '1.29',
                   'Time::HiRes' => 0,
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

