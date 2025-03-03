#!/bin/sh

# color
blank='#00000000'
clear='#E8A2AF'
ring='#161320'
text='#D9E0EE'
wrong='#F28FAD'
verify='#ABE9B3'

greet="Welcome, Back $USER"
wrong_pass="Incorrect, Try Again"
font="Fira Code, Maple Mono, Unifont, monospace"
background="$HOME/.local/share/lock.jpg"

i3lock \
  --nofork \
  --ignore-empty-password \
  --indicator \
  --bar-indicator \
  --bar-pos y+h \
  --bar-max-height 10 \
  --bar-base-width 10 \
  --bar-direction 1 \
  --bar-orientation=horizontal \
  --bar-color=$ring \
  --bar-periodic-step 50 \
  --bar-step 50 \
  \
  --line-color=$ring \
  --ringver-color=$verify \
  --ringwrong-color=$wrong \
  --bshl-color=$clear \
  --keyhl-color=$verify \
  --redraw-thread \
  \
  --clock \
  --time-color=$text \
  --time-str="%I:%M %p" \
  --time-font="$font" \
  --time-size=60 \
  --time-color=$text \
  --date-color=$text \
  --date-str="%A, %d %B" \
  --date-color=$text \
  --date-font="$font" \
  --date-size=18 \
  \
  --verif-font="$font" \
  --verif-size=24 \
  --verif-text="$greet" \
  --verif-color=$verify\
  --wrong-font="$font" \
  --wrong-size=24 \
  --wrong-text="$wrong_pass" \
  --wrong-color=$wrong \
  \
  -i $background \
  --scale \
  --keylayout 1

#   --time-pos="175:668" \
