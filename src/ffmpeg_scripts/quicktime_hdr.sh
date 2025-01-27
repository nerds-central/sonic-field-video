#!/bin/zsh

# Description:
# Produce quicktime viewable HDR.
#
# Args:
# <video in>
#
# Out:
# <*.mov
#
#
#

zmodload zsh/mathfunc

# My Mac screen at max bightness
# master_pl=500
# The value normally used - stick with this for now.
master_pl=500
# Compute the meta date value for it.
master_pl=$((${master_pl} *  10000))

# Mastering values based on Rec2020
green="G($((int(0.17/0.00002))),$((int(0.797/0.00002))))"
red="R($((int(0.708/0.00002))),$((int(0.292/0.00002))))"
blue="B($((int(0.313/0.00002))),$((int(0.046/0.00002))))"
whpt="WP($((int(0.3127/0.00002))),$((int(0.3290/0.00002))))"
luma="L(${master_pl},1)"
master="${green}${blue}${red}${whpt}${luma}"

# Guess - need to figure out how to compute this.
max_cll='0,0'

. $(dirname "$0")/encoding.sh
lut=$(get_lut finish-4)
$(dirname "$0")/ffmpeg -y \
    -i "$1"\
    -c:v libx265 \
    -x265-params "repeat-headers=1:hdr-opt=1:colorprim=bt2020:transfer=smpte2084:colormatrix=bt2020nc:master-display=${master}:max-cll=${max_cll}:hdr10=1:dhdr10-info=metadata.json" \
    -tag:v hvc1 \
    -b:v 200M \
    -preset medium \
    -pix_fmt yuv420p10le \
    -r ${r} \
    -sws_flags +accurate_rnd+full_chroma_int+full_chroma_inp \
    -colorspace bt2020nc \
    -color_primaries bt2020 \
    -color_trc smpte2084 \
    -color_range 2 \
    -dst_range 1 \
    -src_range 1 \
    -chroma_sample_location left \
    -fflags +igndts \
    -fflags +genpts \
    -vf "
zscale=
    rin=full:
    r=full,
format=gbrp16le,
lut3d=
    file='${lut}':
    interp=tetrahedral,
zscale=
    rin=full:
    r=full
" ${1%.*}.mov

