function fish_prompt
   
    set ip (ip route get 1 | awk '{print $7; exit}')

    
    set wattage (cat /sys/class/power_supply/BAT0/power_now 2>/dev/null | awk '{ printf "%.2f", $1 / 1000000 }')

   
    set top_proc (ps -eo comm,%cpu --sort=-%cpu | awk 'NR==2 {printf "%s (%.1f%%)", $1, $2}')

    # Prompt output
    set_color cyan
    echo -n "["(whoami)"🌐 @$ip] "
    set_color yellow
    echo -n "[⚡ $wattage W] "
    set_color red
    echo -n "[🔥 $top_proc] "
    set_color green
    echo -n (prompt_pwd)
    set_color normal
    echo -n " > "
end
