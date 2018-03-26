use strict;
use warnings;

use Test::More tests => 5;

use_ok( 'Nick::Audio::Gain' );

my $buffer;
my $gain = Nick::Audio::Gain -> new( \$buffer );

ok( defined( $gain ), 'new()' );

my @want_rms = (
    '0.942', '0.817', '0.692', '0.568', '0.443', '0.318', '0.195', '0.076'
);
my @want_max = (
    '1.000', '0.875', '0.750', '0.625', '0.500', '0.375', '0.250', '0.125'
);

my $data = '';
for ( my $val = 32767; $val > 0; $val -= 256 ) {
    $data .= pack 's2', $val, -$val;
}

my @got_rms;
my $len = length $data;
my $block = 64;

$buffer = $data;
for ( my $i = 0; $i < $len; $i += $block ) {
    push @got_rms => sprintf "%.3f", $gain -> get_rms_sub( $i, $block );
}
is_deeply( \@got_rms, \@want_rms, 'get_rms_sub()' );

$#got_rms = -1;
my @got_max;
for (
    my $off = 0;
    $off < $len;
    $off += $block
) {
    $buffer = substr $data, $off, $block;
    push @got_rms => sprintf "%.3f", $gain -> get_rms();
    push @got_max => sprintf "%.3f", $gain -> get_max();
}
is_deeply( \@got_rms, \@want_rms, 'get_rms()' );
is_deeply( \@got_max, \@want_max, 'get_max()' );
