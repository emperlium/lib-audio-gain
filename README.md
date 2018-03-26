# lib-audio-gain

Module for retrieving gain information from PCM audio data.

## Dependencies

None.

## Note

Currently limited to 16 bit audio.

## Installation

    perl Makefile.PL
    make test
    sudo make install

## Example

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

## METHODS

### new()

Instantiates a new Nick::Audio::Gain object.

Takes one argument, the scalar that'll contain PCM audio to be analysed.

### get\_max()

Returns the float value (0 to 1) of the peak sample in the PCM scalar.

### get\_rms()

Returns the float value (0 to 1) of the root mean square peak of audio in the PCM scalar.

### get\_rms\_sub()

As **get\_rms**, but takes two parameters - the byte offsets to begin and end anaylsing the audio.
