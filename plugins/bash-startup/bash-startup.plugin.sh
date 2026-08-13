# Configuration for opening a new terminal window 

# Print a blank line for better readability
echo -e '\n'

# Display a random fortune in Spanish if available
if command -v fortune >/dev/null 2>&1; then
    fortune es 2>/dev/null || fortune 2>/dev/null || true
fi

# Print the username "jdrestre" in a slanted font with colors using figlet and lolcat if available
if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
        figlet jdrestre -f slant | lolcat && echo -e '\n'
    else
        figlet jdrestre -f slant && echo -e '\n'
    fi
else
    echo -e "=== jdrestre terminal ===\n"
fi

# Set the bold style for text
bold=$(tput bold 2>/dev/null || echo "")

# Script to Display Date and Time with Adjusted Week Number for Year-End

# Get the current date and time information in local timezone for Medellín, Colombia
current_date=$(date "+Today is: %A, %d %B %Y%nTime: %H:%M:%S")

# Get the week of the year and day of the year
week_of_year=$(date "+%V")
day_of_year=$(date "+%j")

# Get the current year
year=$(date "+%Y")

# Check if today is December 31 and adjust the week number to 52 according to ISO-8601
if [ "$(date +%m-%d)" == "12-31" ]; then
  week_of_year="52"
fi

# Display the date and time information with adjusted week number
echo -e "\033[1m$current_date\nWeek of the year: $week_of_year\nDay of the year: $day_of_year\033[0m"

# Execute geek ephemeris validator if file exists
EPHEMERIS_SCRIPT="$HOME/.oh-my-bash/custom/plugins/bash-startup/.geek_ephemeris/dayValidator.sh"
if [ -x "$EPHEMERIS_SCRIPT" ]; then
    "$EPHEMERIS_SCRIPT"
elif [ -f "$EPHEMERIS_SCRIPT" ]; then
    bash "$EPHEMERIS_SCRIPT"
fi

