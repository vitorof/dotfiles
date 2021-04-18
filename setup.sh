#!/bin/sh

for dir in ./.config/* ; do
  dir=${dir%*/}
  dir=${dir##*/}
  if [ -d "$HOME/.config/$dir" ]; then
    echo "Found existing $dir config. Backing it up to $HOME/.config/$dir~"
  fi
done
