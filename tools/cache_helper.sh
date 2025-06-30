#!/bin/bash
# Cache management functions for API calls
# Reduces GitHub API rate limiting by caching responses

set -Eeuo pipefail

CACHE_DIR="_cache"
CACHE_TIMESTAMPS_FILE="${CACHE_DIR}/cache_timestamps.txt"

# Initialize cache directory
cache_init() {
    mkdir -p "$CACHE_DIR"
    [[ -f "$CACHE_TIMESTAMPS_FILE" ]] || touch "$CACHE_TIMESTAMPS_FILE"
}

# Check if cache file is valid (within TTL)
cache_is_valid() {
    local cache_file="$1"
    local ttl_hours="${2:-6}"
    local max_age=$((ttl_hours * 3600))
    
    if [[ -f "$cache_file" ]]; then
        local file_age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [[ $file_age -lt $max_age ]]; then
            return 0  # Valid
        fi
    fi
    return 1  # Invalid or doesn't exist
}

# Get data from cache if valid
cache_get() {
    local cache_key="$1"
    local cache_file="${CACHE_DIR}/${cache_key}.txt"
    local ttl_hours="${2:-6}"
    
    cache_init
    
    if cache_is_valid "$cache_file" "$ttl_hours"; then
        echo "# Cache hit: $cache_key ($(stat -c %y "$cache_file"))" >&2
        cat "$cache_file"
        return 0
    else
        echo "# Cache miss: $cache_key" >&2
        return 1
    fi
}

# Store data in cache
cache_store() {
    local cache_key="$1"
    local data="$2"
    local cache_file="${CACHE_DIR}/${cache_key}.txt"
    
    cache_init
    
    echo "$data" > "$cache_file"
    
    # Update timestamp record
    grep -v "^${cache_key}=" "$CACHE_TIMESTAMPS_FILE" > "${CACHE_TIMESTAMPS_FILE}.tmp" 2>/dev/null || true
    echo "${cache_key}=$(date +%s)" >> "${CACHE_TIMESTAMPS_FILE}.tmp"
    mv "${CACHE_TIMESTAMPS_FILE}.tmp" "$CACHE_TIMESTAMPS_FILE"
    
    echo "# Cached: $cache_key" >&2
}

# Clean old cache files
cache_cleanup() {
    local days_old="${1:-7}"
    
    if [[ -d "$CACHE_DIR" ]]; then
        echo "# Cleaning cache files older than $days_old days..." >&2
        find "$CACHE_DIR" -name "*.txt" -type f -mtime +"$days_old" -delete 2>/dev/null || true
    fi
}

# Show cache status
cache_status() {
    echo "# Cache Directory: $CACHE_DIR"
    if [[ -d "$CACHE_DIR" ]]; then
        echo "# Cache files:"
        find "$CACHE_DIR" -name "*.txt" -type f -exec ls -lah {} \; 2>/dev/null || echo "# No cache files found"
    else
        echo "# Cache directory doesn't exist"
    fi
}

# Wrapper for curl with cache support
cached_curl() {
    local cache_key="$1"
    local url="$2"
    local ttl_hours="${3:-6}"
    shift 3
    local curl_args=("$@")
    
    # Try cache first
    if cache_get "$cache_key" "$ttl_hours"; then
        return 0
    fi
    
    # Cache miss - make API call
    echo "# Fetching from API: $url" >&2
    local response
    if response=$(curl -s "${curl_args[@]}" "$url"); then
        cache_store "$cache_key" "$response"
        echo "$response"
        return 0
    else
        echo "# API call failed for: $url" >&2
        return 1
    fi
}

# Check GitHub rate limit before making API calls
check_github_rate_limit() {
    local min_required="${1:-8}"  # Default: need at least 8 requests
    
    echo "# Checking GitHub rate limit before API calls..."
    
    # Get rate limit info from headers
    local rateLimitHeaders
    if ! rateLimitHeaders=$(curl -sI https://api.github.com/users/postgis 2>/dev/null | grep -i x-ratelimit); then
        echo "# Failed to check GitHub rate limit - proceeding with caution"
        return 0  # Allow to continue if check fails
    fi
    
    local rateLimitRemaining
    rateLimitRemaining=$(echo "$rateLimitHeaders" | grep -i 'x-ratelimit-remaining:' | grep -o '[[:digit:]]*' || echo "0")
    
    echo "# GitHub rate limit remaining: $rateLimitRemaining"
    
    if [ "${rateLimitRemaining}" -le "${min_required}" ]; then
        echo
        echo " You do not have enough github requests available to continue!"
        echo " Current remaining: $rateLimitRemaining, required: $min_required"
        echo
        echo " Without logging - the github api is limited to 60 requests per hour"
        echo "    see: https://developer.github.com/v3/#rate-limiting "
        echo " You can check your remaining requests with :"
        echo "    curl -sI https://api.github.com/users/postgis | grep x-ratelimit "
        echo
        echo " ------------------------ "
        echo "$rateLimitHeaders"
        echo
        echo " The limit will be reset at :"
        echo "$rateLimitHeaders" | grep -i 'x-ratelimit-reset:' | cut -d' ' -f2 | xargs -I {} date -d @{} 2>/dev/null || echo "Unable to parse reset time"
        return 1  # Fail - not enough requests
    fi
    
    return 0  # Success - enough requests available
}

# Export functions for use in other scripts
export -f cache_init cache_is_valid cache_get cache_store cache_cleanup cache_status cached_curl check_github_rate_limit