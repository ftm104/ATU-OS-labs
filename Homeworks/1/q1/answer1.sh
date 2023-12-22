#!/bin/bash

# Function to send notifications to Telegram
send_telegram_notification() {
    local message="$1"
    # Replace <6870381732:AAF-5jk5zPxUGED3iFh9YXM79KyE3Scffhc> and <sendalogginnotifbot> with your actual Telegram bot token and chat ID
    curl -s -X POST "https://api.telegram.org/bot<YOUR_TELEGRAM_BOT_TOKEN>/sendMessage" -d "chat_id=<YOUR_TELEGRAM_CHAT_ID>&text=$message"
}

# Function to process login events
process_login_event() {
    local username="$1"
    local hostname="$2"
    local ip="$3"
    local remarks="$4"

    local date=$(date +"%Y-%m-%d %H:%M:%S")

    local message="Login Event:
Date: $date
Username: $username
Hostname: $hostname"

    if [ -n "$ip" ]; then
        message+="\nSource IP: $ip"
    fi

    if [ -n "$remarks" ]; then
        message+="\nRemarks: $remarks"
    fi

    send_telegram_notification "$message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help    Show help message"
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Main script logic
while read -r line; do
    if [[ $line == *"session opened"* ]]; then
        # Extract relevant information from the log line
        username=$(echo "$line" | awk '{print $1}')
        hostname=$(echo "$line" | awk '{print $2}')
        ip=$(echo "$line" | awk '{print $11}')
        remarks=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=$11=""; print $0}')

        process_login_event "$username" "$hostname" "$ip" "$remarks"
    fi
done < <(journalctl --since "1 minute ago" _SYSTEMD_UNIT=sshd.service --no-pager)
