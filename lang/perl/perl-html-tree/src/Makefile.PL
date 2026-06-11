require 5.008;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'HTML::Tree',
  'VERSION_FROM' => 'lib/HTML/Element.pm',
  'PREREQ_PM' => {
                   'Carp' => '0',
                   'Exporter' => '0',
                   'HTML::Entities' => '0',
                   'HTML::Parser' => '3.46',
                   'HTML::Tagset' => '3.02',
                   'Scalar::Util' => '0',
                   'integer' => '0',
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;

