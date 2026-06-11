use 5.014;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Net::Async::HTTP',
  'VERSION_FROM' => 'lib/Net/Async/HTTP.pm',
  'PREREQ_PM' => {
                   'Future' => '0.28',
                   'Future::Utils' => '0.16',
                   'HTTP::Request' => 0,
                   'HTTP::Request::Common' => 0,
                   'HTTP::Response' => 0,
                   'IO::Async::Loop' => '0.59',
                   'IO::Async::Stream' => '0.59',
                   'IO::Async::Timer::Countdown' => 0,
                   'List::Util' => "1.29",
                   'Metrics::Any' => '0.05',
                   'Socket' => '2.010',
                   'Struct::Dumb' => '0.07',
                   'Time::HiRes' => 0,
                   'URI' => 0,
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

