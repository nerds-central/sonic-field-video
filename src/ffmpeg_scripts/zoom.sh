#!/bin/zsh

# Description:
#
# Zoom a clip
#
# Args:
# <clip>  <zoom to (e.g. 1.1)> <lr offset> <tb offset>
# lr offset = position to zoom to 0 = left, 0.5 = middle
# tb offset = position to zoom to 0 = top, 0.5 = middle
# Tidy up an image for 4K
# 
# Out:
# <*-zoom>.nut
#

size=$((960*${2}))x$((540*${2}))

. $(dirname "$0")/encoding.sh

len=$($(dirname "$0")/get_length.sh "${1}")
size=$((960*${2}))x$((540*${2}))
cx=$((960*${2}*${4}))
cy=$((540*${2}*${5}))
scaler=$(( (${3}-1.0)/(${len}*${r}) ))
echo "Frame scaler = ${scaler}"

cmd="${exe} -y -i '${1}' -i '${1}' ${enc} -ss 0 -to ${len} -filter_complex \
\"
[0:v]
zscale=
    rin=full:
    r=full,
format=yuv444p16le,
geq=
    lum='lum((X-${cx})/(1+${scaler}*N)+${cx}, (Y-${cy})/(1+${scaler}*N)+${cy})':
    cr='cr((X-${cx})/(1+${scaler}*N)+${cx}, (Y-${cy})/(1+${scaler}*N)+${cy})':
    cb='cb((X-${cx})/(1+${scaler}*N)+${cx}, (Y-${cy})/(1+${scaler}*N)+${cy})',
zscale=
    rin=full:
    r=full
[v]
\" -map '[v]' -map 1:a -map_metadata -1 '${1%.*}-zoom.nut'"
echo
echo '================================================================================'
echo Will Run ${cmd}
echo '================================================================================'
echo
echo $cmd > run.sh
. ./run.sh

. $(dirname "$0")/review.sh "${1%.*}-zoom.nut"
