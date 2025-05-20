require 5.016;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Future::AsyncAwait',
  'VERSION_FROM' => 'lib/Future/AsyncAwait.pm',
  'PREREQ_PM' => {
                   'Future' => '0.50',
                   'XS::Parse::Keyword' => '0.13',
                   'XS::Parse::Sublike' => '0.31',
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {},
  'INC' => '-I. -Ishare/include -Ihax -I'.$ENV{STAGING_PREFIX}.'/share/perl/include',
  'XSMULTI' => 1,
)
;

