#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2021  igo95862

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, version 2.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set -eu

# Targets
LATENCY_MS=4
MIN_GRANULARITY_MS=0.4
WAKEUP_GRANULARITY_MS=0.5
MIGRATION_COST_MS=0.25
BANDWIDTH_SIZE_MS=3
NR_MIGRATE=64

calcf() {
    fmt=$1; shift
    IFS=,; gawk "BEGIN { printf \"$fmt\", $* }"
}

# Number of processing units
NPROC="$(nproc)"

# Linux uses this algorithm to multiply miliseconds
MODIFIER="$( calcf "%d" "10 ** 6 * (1 + int(log(${NPROC}) / log(2)))" )"

# Files
LATENCY_NS_FILE="/sys/kernel/debug/sched/latency_ns"
MIN_GRANULARITY_NS_FILE="/sys/kernel/debug/sched/min_granularity_ns"
WAKEUP_GRANULARITY_NS_FILE="/sys/kernel/debug/sched/wakeup_granularity_ns"
MIGRATION_COST_NS_FILE="/sys/kernel/debug/sched/migration_cost_ns"
BANDWIDTH_SIZE_US_FILE="/proc/sys/kernel/sched_cfs_bandwidth_slice_us"
NR_MIGRATE_FILE="/sys/kernel/debug/sched/nr_migrate"

# Legacy Files
if [ ! -f "$LATENCY_NS_FILE" ]; then
    echo "Detected kernel <5.13. Using legacy locations."
    LATENCY_NS_FILE="/proc/sys/kernel/sched_latency_ns"
    MIN_GRANULARITY_NS_FILE="/proc/sys/kernel/sched_min_granularity_ns"
    WAKEUP_GRANULARITY_NS_FILE="/proc/sys/kernel/sched_wakeup_granularity_ns"
    MIGRATION_COST_NS_FILE="/proc/sys/kernel/sched_migration_cost_ns"
    NR_MIGRATE_FILE="/proc/sys/kernel/sched_nr_migrate"
fi

# Origial Values
O_LATENCY_NS="$( cat "$LATENCY_NS_FILE" )"
O_MIN_GRANULARITY_NS="$( cat "$MIN_GRANULARITY_NS_FILE" )"
O_WAKEUP_GRANULARITY_NS="$( cat "$WAKEUP_GRANULARITY_NS_FILE" )"
O_MIGRATION_COST_NS="$( cat "$MIGRATION_COST_NS_FILE" )"
O_BANDWIDTH_SIZE_US="$( cat "$BANDWIDTH_SIZE_US_FILE" )"
O_NR_MIGRATE="$( cat "$NR_MIGRATE_FILE" )"

# Updates
calcf "%d" "${LATENCY_MS} * ${MODIFIER}" > "$LATENCY_NS_FILE"
calcf "%d" "${MIN_GRANULARITY_MS} * ${MODIFIER}" > "$MIN_GRANULARITY_NS_FILE"
calcf "%d" "${WAKEUP_GRANULARITY_MS} * ${MODIFIER}" > "$WAKEUP_GRANULARITY_NS_FILE"
calcf "%d" "${MIGRATION_COST_MS} * ${MODIFIER}" > "$MIGRATION_COST_NS_FILE"
calcf "%d" "${BANDWIDTH_SIZE_MS} * 1000" > "$BANDWIDTH_SIZE_US_FILE"
calcf "%d" "$NR_MIGRATE" > "$NR_MIGRATE_FILE"

# New Values
N_LATENCY_NS="$( cat "$LATENCY_NS_FILE" )"
N_MIN_GRANULARITY_NS="$( cat "$MIN_GRANULARITY_NS_FILE" )"
N_WAKEUP_GRANULARITY_NS="$( cat "$WAKEUP_GRANULARITY_NS_FILE" )"
N_MIGRATION_COST_NS="$( cat "$MIGRATION_COST_NS_FILE" )"
N_BANDWIDTH_SIZE_US="$( cat "$BANDWIDTH_SIZE_US_FILE" )"
N_NR_MIGRATE="$( cat "$NR_MIGRATE_FILE" )"

# Output Changes
calcf "Targeted preemption latency for CPU-bound tasks: %.3fms -> %.3fms\n" \
    "$O_LATENCY_NS / 10 ** 6" \
    "$N_LATENCY_NS / 10 ** 6"

calcf "Minimal preemption granularity for CPU-bound tasks: %.3fms -> %.3fms\n" \
    "$O_MIN_GRANULARITY_NS / 10 ** 6" \
    "$N_MIN_GRANULARITY_NS / 10 ** 6"

calcf "Wake-up granularity: %.3fms -> %.3fms\n" \
    "$O_WAKEUP_GRANULARITY_NS / 10 ** 6" \
    "$N_WAKEUP_GRANULARITY_NS / 10 ** 6"

calcf "Task migration cost: %.3fms -> %.3fms\n" \
    "$O_MIGRATION_COST_NS / 10 ** 6" \
    "$N_MIGRATION_COST_NS / 10 ** 6"

calcf "Amount of runtime to allocate from global to local pool: %.3fms -> %.3fms\n" \
    "$O_BANDWIDTH_SIZE_US / 10 ** 3" \
    "$N_BANDWIDTH_SIZE_US / 10 ** 3"

calcf "Number of tasks to iterate in a single balance run: %d -> %d\n" \
    "$O_NR_MIGRATE" \
    "$N_NR_MIGRATE"
