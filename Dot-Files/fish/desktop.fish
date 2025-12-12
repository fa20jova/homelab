# Direct wattage calculation now that energy_uj is readable
function fish_prompt
    set ip (ip route get 1 | awk '{print $7; exit}')

    # Calculate package-level wattage via RAPL
    set s0 (cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
    sleep .1
    set s1 (cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
    if test -z "$s0" -o -z "$s1"
        set wattage "N/A"
    else
        set wattage (math "($s1 - $s0) / 1000000")
        # Ensure formatting accuracy
        set wattage (printf "%.2f" $wattage)
    end

    set top_proc (ps -eo comm,%cpu --sort=-%cpu | awk 'NR==2 {printf "%s (%.1f%%)", $1, $2}')

    set_color cyan; echo -n "["(whoami)"🌐 @$ip] "
    set_color yellow; echo -n "[⚡ $wattage W] "
    set_color red; echo -n "[🔥 $top_proc] "
    set_color green; echo -n (prompt_pwd)
    set_color normal; echo -n " > "
end
alias k='kubectl'
