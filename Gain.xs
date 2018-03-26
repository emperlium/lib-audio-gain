#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

double const PCM_MAX_VALUE = ( 1 << 15 ) - 1;

struct nickaudiogain {
    SV *scalar_in;
};

typedef struct nickaudiogain NICKAUDIOGAIN;

MODULE = Nick::Audio::Gain  PACKAGE = Nick::Audio::Gain

static NICKAUDIOGAIN *
NICKAUDIOGAIN::new_xs( scalar_in )
        SV *scalar_in;
    CODE:
        Newxz( RETVAL, 1, NICKAUDIOGAIN );
        RETVAL -> scalar_in = SvREFCNT_inc(
            SvROK( scalar_in )
            ? SvRV( scalar_in )
            : scalar_in
        );
    OUTPUT:
        RETVAL

void
NICKAUDIOGAIN::DESTROY()
    CODE:
        SvREFCNT_dec( THIS -> scalar_in );
        Safefree( THIS );

float
NICKAUDIOGAIN::get_max()
    INIT:
        STRLEN len_in;
        unsigned char *pcm = SvPV( THIS -> scalar_in, len_in );
        int16_t samp;
        int16_t max = 0;
    CODE:
        if (
            ! SvOK( THIS -> scalar_in )
        ) {
            XSRETURN_UNDEF;
        }
        for ( int i = 0; i < len_in; i += 2 ) {
            samp = pcm[i] + ( ( int16_t )pcm[ i + 1 ] << 8 );
            if ( samp < 0 ) {
                samp *= -1;
            }
            if ( samp > max ) {
                max = samp;
            }
        }
        RETVAL = max / PCM_MAX_VALUE;
    OUTPUT:
        RETVAL

float
NICKAUDIOGAIN::get_rms()
    INIT:
        STRLEN len_in;
        unsigned char *pcm = SvPV( THIS -> scalar_in, len_in );
        unsigned long long accum = 0;
        int16_t samp;
    CODE:
        if (
            ! SvOK( THIS -> scalar_in )
        ) {
            XSRETURN_UNDEF;
        }
        for ( int i = 0; i < len_in; i += 2 ) {
            samp = pcm[i] + ( ( int16_t )pcm[ i + 1 ] << 8 );
            accum += samp * samp;
        }
        RETVAL = sqrt(
            accum / ( len_in / 2 )
        ) / PCM_MAX_VALUE;
    OUTPUT:
        RETVAL

float
NICKAUDIOGAIN::get_rms_sub( from, to )
        int from;
        int to;
    INIT:
        STRLEN len_in;
        unsigned char *pcm = SvPV( THIS -> scalar_in, len_in );
        unsigned long long accum = 0;
        int16_t samp;
    CODE:
        if (
            ! SvOK( THIS -> scalar_in )
        ) {
            XSRETURN_UNDEF;
        }
        to += from;
        if ( to > len_in ) {
            to = len_in;
        }
        for ( int i = from; i < to; i += 2 ) {
            samp = pcm[i] + ( ( int16_t )pcm[ i + 1 ] << 8 );
            accum += samp * samp;
        }
        RETVAL = sqrt(
            accum / ( ( to - from ) / 2 )
        ) / PCM_MAX_VALUE;
    OUTPUT:
        RETVAL
