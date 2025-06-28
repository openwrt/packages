use 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'IO::Async::SSL',
  'VERSION_FROM' => 'lib/IO/Async/SSL.pm',
  'PREREQ_PM' => {
                   'Future' => '0.33',
                   'IO::Async::Loop' => '0.66',
                   'IO::Async::Handle' => '0.29',
                   'IO::Async::Protocol::Stream' => 0,
                   'IO::Async::Stream' => '0.59',
                   'IO::Socket::SSL' => '2.003',
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

