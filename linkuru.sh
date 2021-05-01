#!/bin/sh

echo -e "\033[1;35mLink start!\033[0m"

shopt -s extglob
ignore="@(README*|assets)"

for dir in _config/* ; do
  case "$dir" in
    $ignore) echo -e "\033[33mWarning:\033[0m Ignoring \033[35m$dir\033[0m" ;;
    *) [ -d "$HOME/.config" ] && ln -srbv "$dir"  "$HOME/.config" ;;
  esac
done

for file in * ; do
  case "$file" in
    linkuru.sh) continue ;;
    $ignore) echo -e "\033[33mWarning:\033[0m Ignoring \033[35m$file\033[0m" ;;
    *) [ -f "$file" ] && ln -srbv "$file" "$HOME/.${file:1}" ;;
  esac
done
