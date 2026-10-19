#!/usr/bin/env bash
# Status line: plan usage (5h window and weekly) + reset time
input=$(cat)

fmt_epoch() { # $1=epoch $2=date format; GNU date first, then BSD/macOS date
  LC_TIME=C date -d "@$1" +"$2" 2>/dev/null || LC_TIME=C date -r "$1" +"$2"
}

fmt() { # $1=label $2=pct $3=epoch $4=date format
  [ -z "$2" ] && return
  local pct=$(LC_ALL=C printf "%.0f" "$2") color
  if   [ "$pct" -ge 80 ]; then color='\033[31m'
  elif [ "$pct" -ge 50 ]; then color='\033[33m'
  else color='\033[32m'; fi
  local reset=""
  [ -n "$3" ] && reset=" (resets $(fmt_epoch "$3" "$4"))"
  printf "%s ${color}%s%%\033[0m%s" "$1" "$pct" "$reset"
}

read -r p5 r5 p7 r7 model < <(echo "$input" | jq -r '[
  .rate_limits.five_hour.used_percentage // "",
  .rate_limits.five_hour.resets_at // "",
  .rate_limits.seven_day.used_percentage // "",
  .rate_limits.seven_day.resets_at // "",
  .model.display_name // ""] | map(tostring | if . == "" then "-" else gsub(" ";"_") end) | join(" ")')

for v in p5 r5 p7 r7; do [ "${!v}" = "-" ] && printf -v "$v" ''; done

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
[[ "$dir" == "$HOME"* ]] && dir="~${dir#$HOME}"

out="${model//_/ }"
[ -n "$dir" ] && out="$out | \033[36m$dir\033[0m"

read -r ctx dur_ms < <(echo "$input" | jq -r '[
  .context_window.used_percentage // "-",
  .cost.total_duration_ms // "-"] | map(tostring) | join(" ")')
[ "$ctx" != "-" ] && out="$out | $(fmt "ctx:" "$ctx")"
if [ "$dur_ms" != "-" ]; then
  mins=$(( ${dur_ms%.*} / 60000 ))
  if [ "$mins" -ge 60 ]; then dur="$((mins / 60))h$(printf '%02d' $((mins % 60)))m"; else dur="${mins}m"; fi
  out="$out | $dur"
fi

s5=$(fmt "5h:" "$p5" "$r5" "%H:%M")
s7=$(fmt "Week:" "$p7" "$r7" "%a %d/%m %H:%M")
[ -n "$s5" ] && out="$out | $s5"
[ -n "$s7" ] && out="$out | $s7"
[ -z "$s5$s7" ] && out="$out | limits: waiting for first response"
printf '%b' "$out"
