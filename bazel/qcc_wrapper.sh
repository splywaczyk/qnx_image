#!/bin/bash
# QCC Wrapper Script for Bazel
# Sets required QNX environment variables and reorders arguments for qcc

# Set HOME if not set (Bazel may not set it)
export HOME="${HOME:-/home/qnx}"

# Set QNX environment variables manually (sourcing doesn't work well in Bazel sandbox)
export QNX_HOST="/home/qnx/qnx800/host/linux/x86_64"
export QNX_TARGET="/home/qnx/qnx800/target/qnx"
export QNX_CONFIGURATION="/home/qnx/.qnx"
export QNX_CONFIGURATION_EXCLUSIVE="/home/qnx/.qnx"
export PATH="$QNX_HOST/usr/bin:$PATH"

# Extract -V argument and its value, then rebuild args with -V first
# Also filter out problematic flags that QNX qcc doesn't support
V_ARG=""
OTHER_ARGS=()
SKIP_NEXT=false
SKIP_TYPE=""
DEPFILE=""
OUTPUT_FILE=""

for arg in "$@"; do
    if [ "$SKIP_NEXT" = true ]; then
        if [ "$SKIP_TYPE" = "V" ]; then
            V_ARG="$V_ARG $arg"
        elif [ "$SKIP_TYPE" = "MF" ]; then
            # Save the dependency file path for later
            DEPFILE="$arg"
        elif [ "$SKIP_TYPE" = "OUTPUT" ]; then
            OUTPUT_FILE="$arg"
            OTHER_ARGS+=("$arg")
        fi
        SKIP_NEXT=false
        SKIP_TYPE=""
    elif [ "$arg" = "-V" ]; then
        V_ARG="-V"
        SKIP_NEXT=true
        SKIP_TYPE="V"
    elif [ "$arg" = "-MD" ]; then
        # Skip -MD flag
        continue
    elif [ "$arg" = "-MF" ]; then
        # Skip -MF and its next argument (the filename), but save it
        SKIP_NEXT=true
        SKIP_TYPE="MF"
    elif [[ "$arg" == -frandom-seed* ]]; then
        # Skip -frandom-seed flag
        continue
    elif [ "$arg" = "-o" ]; then
        OTHER_ARGS+=("$arg")
        # Next arg is the output file
        SKIP_NEXT=true
        SKIP_TYPE="OUTPUT"
    else
        OTHER_ARGS+=("$arg")
    fi
done

# Execute qcc with -V first, then other arguments
if [ -n "$V_ARG" ]; then
    "$QNX_HOST/usr/bin/qcc" $V_ARG "${OTHER_ARGS[@]}"
    RESULT=$?
else
    "$QNX_HOST/usr/bin/qcc" "${OTHER_ARGS[@]}"
    RESULT=$?
fi

# Create a dummy dependency file if one was requested
if [ $RESULT -eq 0 ] && [ -n "$DEPFILE" ] && [ -n "$OUTPUT_FILE" ]; then
    echo "$OUTPUT_FILE:" > "$DEPFILE"
fi

exit $RESULT
