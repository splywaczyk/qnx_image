#!/bin/bash
# QCC Wrapper Script for Bazel
# Sets QNX environment and filters incompatible flags

# Set QNX environment variables
export HOME="${HOME:-/home/qnx}"
source /home/qnx/qnx800/qnxsdp-env.sh > /dev/null 2>&1

# Parse arguments, filtering incompatible flags
V_ARG=""
ARGS=()
DEPFILE=""
OUTPUT_FILE=""
skip_next=false

for arg in "$@"; do
    if $skip_next; then
        case "$skip_next_type" in
            V) V_ARG="$V_ARG $arg" ;;
            MF) DEPFILE="$arg" ;;
            o) OUTPUT_FILE="$arg"; ARGS+=("$arg") ;;
        esac
        skip_next=false
        continue
    fi

    case "$arg" in
        -V)
            V_ARG="-V"
            skip_next=true
            skip_next_type="V"
            ;;
        -MD)
            # Skip -MD flag (not supported by qcc)
            ;;
        -MF)
            skip_next=true
            skip_next_type="MF"
            ;;
        -frandom-seed*)
            # Skip -frandom-seed flag (not supported by qcc)
            ;;
        -o)
            ARGS+=("$arg")
            skip_next=true
            skip_next_type="o"
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# Execute qcc with -V first if present
if [ -n "$V_ARG" ]; then
    "$QNX_HOST/usr/bin/qcc" $V_ARG "${ARGS[@]}"
else
    "$QNX_HOST/usr/bin/qcc" "${ARGS[@]}"
fi

result=$?

# Create dummy dependency file if needed
if [ $result -eq 0 ] && [ -n "$DEPFILE" ] && [ -n "$OUTPUT_FILE" ]; then
    echo "$OUTPUT_FILE:" > "$DEPFILE"
fi

exit $result
