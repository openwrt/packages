require 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'IO::Async',
  'VERSION_FROM' => 'lib/IO/Async.pm',
  'PREREQ_PM' => {
                   'Future' => '0.44',
                   'Future::Utils' => '0.18',
                   'Exporter' => '5.57',
                   'File::stat' => 0,
                   'IO::Poll' => 0,
                   'List::Util' => 0,
                   'Socket' => '2.007',
                   'Storable' => 0,
                   'Struct::Dumb' => 0,
                   'Time::HiRes' => 0,
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

