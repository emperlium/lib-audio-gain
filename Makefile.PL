use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Nick::Audio::Gain',
    VERSION_FROM        => 'lib/Nick/Audio/Gain.pm',
    AUTHOR              => 'Nick Peskett',
    TEST_REQUIRES       => {
        'Test::More' => 0
    }
);
