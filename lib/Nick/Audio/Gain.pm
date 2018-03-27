package Nick::Audio::Gain;

use strict;
use warnings;

use XSLoader;
use Carp;

our $VERSION;

BEGIN {
    $VERSION = '0.01';
    XSLoader::load 'Nick::Audio::Gain' => $VERSION;
}

=head1 NAME

Nick::Audio::Gain - Module for retrieving gain information from PCM audio data.

=head1 SYNOPSIS

    use Nick::Audio::Gain;
    use Nick::Audio::FLAC;

    use POSIX 'log10';

    my $buffer;
    my $gain = Nick::Audio::Gain -> new( \$buffer );
    my $flac = Nick::Audio::FLAC -> new(
        'test.flac', 'buffer_out' => \$buffer
    );

    my( $max, $cnt, $rms, $tmp );
    $max = $cnt = $rms = 0;

    while ( $flac -> read() ) {
        $cnt ++;
        $rms += $gain -> get_rms() ** 2;
        $tmp = $gain -> get_max();
        $tmp > $max
            and $max = $tmp;
    }

    printf(
        "Peak: %.2f\nRMS dB: %.2f\n",
        $max, -20 * log10( 1 / sqrt( $rms / $cnt ) )
    );

=head1 METHODS

=head2 new()

Instantiates a new Nick::Audio::Gain object.

Takes one argument, the scalar that'll contain PCM audio to be analysed.

=head2 get_max()

Returns the float value (0 to 1) of the peak sample in the PCM scalar.

=head2 get_rms()

Returns the float value (0 to 1) of the root mean square peak of audio in the PCM scalar.

=head2 get_rms_sub()

As B<get_rms>, but takes two parameters - the byte offsets to begin and end anaylsing the audio.

=cut

sub new {
    my( $class, $buffer ) = @_;
    return Nick::Audio::Gain -> new_xs( $buffer );
}

1;
