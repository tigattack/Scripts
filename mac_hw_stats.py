#!/usr/local/bin/python3
"""Get macOS CPU & GPU temps and fan speeds."""

# Imports
import math
import struct
import subprocess

# Define constants
SMC_KEYS = {
    "cpu_temp": "TCXC",
    "gpu_temp": "TCGC",
    "fan": {
        0: {"current": "F0Ac", "min": "F0Mn", "max": "F0Mx"},
        1: {"current": "F1Ac", "min": "F1Mn", "max": "F1Mx"},
    },
}


def smc_query(smc_key: str):
    """Helper function to query SMC information."""
    # Query the given SMC key
    query_result = subprocess.check_output(["/usr/local/bin/smc", "-k", smc_key, "-r"])
    # Convert to string
    query_result = query_result.decode("utf-8")
    # Return query
    return query_result


def truncate(number, digits) -> float:
    """Function to truncate numbers.
    https://stackoverflow.com/a/37697840/5209106"""
    stepper = 10.0 ** digits
    truncated_figure = math.trunc(stepper * number) / stepper
    return truncated_figure


def fan_info():
    """Function to retrieve fan speed information."""

    # Define constants
    fan_dat = {}

    def byte_convert(byte: int) -> float:
        """Converts a byte as an int to a float."""
        # Convert int to bytearray
        databyte = bytearray(byte)
        # Convert bytearray to float
        datafloat = struct.unpack("<f", databyte)[0]
        # Return float
        return datafloat

    def fan_count() -> int:
        """Helper function to return the number of fans in the system."""
        # Query fans
        query_result = subprocess.check_output(["/usr/local/bin/smc", "-f"]).decode("utf-8")
        # Parse output
        query_result = query_result.split("\n", 1)[0]
        # Parse output further, this time as an int
        query_result = int(query_result.split(": ", 1)[1])
        # Return query
        return query_result

    for i in range(0, fan_count()):

        # Get fan data
        fan_current_raw = smc_query(SMC_KEYS["fan"][i]["current"])
        fan_min_raw = smc_query(SMC_KEYS["fan"][i]["min"])
        fan_max_raw = smc_query(SMC_KEYS["fan"][i]["max"])

        # Parse bytes from output as ints
        fan_current_ints = [
            int(fan_current_raw[23:25], 16),
            int(fan_current_raw[26:28], 16),
            int(fan_current_raw[29:31], 16),
            int(fan_current_raw[32:34], 16),
        ]
        fan_min_ints = [
            int(fan_min_raw[23:25], 16),
            int(fan_min_raw[26:28], 16),
            int(fan_min_raw[29:31], 16),
            int(fan_min_raw[32:34], 16),
        ]
        fan_max_ints = [
            int(fan_max_raw[23:25], 16),
            int(fan_max_raw[26:28], 16),
            int(fan_max_raw[29:31], 16),
            int(fan_max_raw[32:34], 16),
        ]

        # Convert list of ints to a single float
        fan_current = byte_convert(fan_current_ints)
        fan_min = byte_convert(fan_min_ints)
        fan_max = byte_convert(fan_max_ints)

        # Calculate fan speed percentage
        fan_percent = (fan_current - fan_min) / (fan_max - fan_min) * 100

        # Truncate all results to 1 decimal place. Truncation is only required for fan_current,
        # which by is returned with 12 decimal places by default. However, all results are
        # truncated for the sake of reliability.
        fan_current = truncate(fan_current, 1)
        fan_min = truncate(fan_min, 1)
        fan_max = truncate(fan_max, 1)
        fan_percent = truncate(fan_percent, 1)

        # Add info to dict
        fan_dat[(i + 1)] = {
            "current": fan_current,
            "current_pct": fan_percent,
            "min": fan_min,
            "max": fan_max,
        }

    # Return fan information
    return fan_dat


def cpu_temp() -> float:
    """Function to retrieve CPU temperature."""
    # Query CPU temperature
    temp = smc_query(SMC_KEYS["cpu_temp"])

    # Parse output
    temp = temp.split("]", 1)[1]

    # Parse output further, this time as a float
    temp = float(temp.split("(", 1)[0].strip())

    # Truncate result to 1 decimal place
    temp = truncate(temp, 1)

    # Return CPU temperature
    return temp


def gpu_temp() -> float:
    """Function to retrieve GPU temperature."""

    # Query GPU temperature
    temp = smc_query(SMC_KEYS["gpu_temp"])

    # Parse output
    temp = temp.split("]", 1)[1]

    # Parse output further, this time as a float
    temp = float(temp.split("(", 1)[0].strip())

    # Truncate result to 1 decimal place
    temp = truncate(temp, 1)

    # Return GPU temperature
    return temp


# Define main function
def main():
    """Main function."""

    stats = {"cpu_temp": cpu_temp(), "gpu_temp": gpu_temp(), "fan": fan_info()}

    print(stats)


if __name__ == "__main__":
    main()
