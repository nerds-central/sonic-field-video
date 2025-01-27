#!/bin/zsh
# Description:
# Ingest from OBS where a green screen has been used
# We upscale 4 times the normal peak to use all the bit depth during
# processing then the final output scripts converts this back down to
# something youtube likes.
#
# Args:
# <video in name> <offset-time of audio> <green cut e.g. -1>
#
# Out:
# <in name-green>.nut
#

. $(dirname "$0")/encoding.sh
voff=$( fps_round $2 )
cmd="${exe} -ss '${voff}' -i '${1}' -i '${1}' ${enc} -filter_complex \"
zscale,
setpts=PTS-STARTPTS,
zscale,
despill=
    expand=0:
    green=${3}:
    blue=0:
    red=0:
    brightness=0,
zscale,
format=gbrpf32le,
zscale=
    size=3840x2160:
    rin=full:
    r=full:
    npl=3000:
    tin=bt709:
    min=bt709:
    pin=bt709:
    t=smpte2084:
    m=2020_ncl:
    c=left:
    p=2020
[v]
\" -map '[v]' -map '1:a' -map_metadata -1 '${1%.*}-green.nut'"
echo
echo '================================================================================'
echo Will Run ${cmd}
echo '================================================================================'
echo
echo $cmd > run.sh
. ./run.sh

cmd="${exe} -i '${1}' ${audio_enc} '${1%.*}-green.wav'"
echo
echo '================================================================================'
echo Will Run ${cmd}
echo '================================================================================'
echo
echo $cmd > run.sh
. ./run.sh

rm run.sh

render_complete
