#!/bin/bash

# UTC 24-Hour Timeline Display
# Works on both macOS and Linux

# Colors (if terminal supports it)
if [[ -t 1 ]]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    BLUE='\033[34m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
else
    BOLD=''
    DIM=''
    RESET=''
    BLUE=''
    GREEN=''
    YELLOW=''
fi

# Function to clear screen (cross-platform)
clear_screen() {
    if command -v tput > /dev/null 2>&1; then
        tput clear
    else
        printf '\033[2J\033[H'
    fi
}

# Function to get UTC time
get_utc_time() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -u '+%H:%M:%S'
    else
        # Linux
        date -u '+%H:%M:%S'
    fi
}

# Function to get current hour and minute for positioning
get_time_position() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local hour=$(date -u '+%H')
        local minute=$(date -u '+%M')
    else
        # Linux
        local hour=$(date -u '+%H')
        local minute=$(date -u '+%M')
    fi
    
    # Remove leading zero for calculation
    hour=$((10#$hour))
    minute=$((10#$minute))
    
    # Calculate position (0-72 characters wide timeline)
    # 72 chars / 24 hours = 3 chars per hour
    local position=$((hour * 3 + minute / 20))
    echo $position
}

# Function to get time in different timezones
get_timezone_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "UTC: $(TZ=UTC date)"
        echo "한국: $(TZ=Asia/Seoul date)"
        echo "미국 동부: $(TZ=America/New_York date)"
        echo "미국 서부: $(TZ=America/Los_Angeles date)"
    else
        # Linux
        echo "UTC: $(TZ=UTC date)"
        echo "한국: $(TZ=Asia/Seoul date)"
        echo "미국 동부: $(TZ=America/New_York date)"
        echo "미국 서부: $(TZ=America/Los_Angeles date)"
    fi
}

# Function to create timeline with current time indicator
create_timeline() {
    local current_time=$(get_utc_time)
    local position=$(get_time_position)
    
    # Show timezone information at the top
    get_timezone_info
    printf "\n"
    
    printf "            24-HOUR UTC TIMELINE\n"
    printf "\n"
    printf " 00     03    06    09    12    15    18    21    24\n"
    printf " │      │     │     │     │     │     │     │     │\n"
    
    # Create the dot timeline
    printf " │"
    for i in {0..47}; do
        if [ $i -eq $((position * 2 / 3)) ]; then
            printf "${GREEN}●${RESET}"
        elif [ $((i % 6)) -eq 0 ]; then
            printf "${YELLOW}•${RESET}"
        else
            printf "·"
        fi
    done
    printf "│\n"
    
    # Create the arrow and time display
    printf " │"
    for i in {0..47}; do
        if [ $i -eq $((position * 2 / 3)) ]; then
            printf "${GREEN}↓${RESET}"
        else
            printf " "
        fi
    done
    printf "│\n"
    
    # Show current time
    printf " │"
    local time_display="$current_time"
    local time_start=$(((position * 2 / 3) - ${#time_display} / 2))
    if [ $time_start -lt 0 ]; then
        time_start=0
    fi
    
    for i in {0..47}; do
        if [ $i -ge $time_start ] && [ $i -lt $((time_start + ${#time_display})) ]; then
            local char_index=$((i - time_start))
            printf "${GREEN}${time_display:$char_index:1}${RESET}"
        else
            printf " "
        fi
    done
    printf "│\n"
    
    printf "\n"
    printf " Trading Sessions:\n"
    printf " ┌─────────────────────────────────────────────────────┐\n"
    printf " │ Asian Session      │ 00:00-08:00 UTC                │\n"
    printf " │ European Session   │ 07:00-16:00 UTC                │\n"
    printf " │ North American     │ 13:00-22:00 UTC                │\n"
    printf " │ Golden Time        │ 13:00-16:00 UTC (Overlap)      │\n"
    printf " └─────────────────────────────────────────────────────┘\n"
    printf "\n"
    printf " Press Ctrl+C to exit\n"
    printf "\n"
}

# Main loop
main() {
    echo "Starting UTC Timeline Display..."
    echo "Works on macOS and Linux"
    sleep 1
    
    # Trap Ctrl+C for clean exit
    trap 'echo -e "\n\nGoodbye!"; exit 0' INT
    
    while true; do
        clear_screen
        create_timeline
        sleep 1
    done
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
