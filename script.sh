#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2021  igo95862

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set -eEu -o pipefail
shopt -s extdebug
IFS=$'\n\t'

LATENCY_MS=4
MIN_GRANULARITY_MS=0.4
WAKEUP_GRANULARITY_MS=0.5
MIGRATION_COST_MS=0.25
BANDWIDTH_SIZE_MS=3


echo "Targeted preemption latency for CPU-bound tasks: ${LATENCY_MS}ms"
echo "Minimal preemption granularity for CPU-bound tasks: ${MIN_GRANULARITY_MS}ms"
echo "Wake-up granularity: ${WAKEUP_GRANULARITY_MS}ms"
echo "Task migration cost: ${MIGRATION_COST_MS}ms"
echo "Amount of runtime to allocate from global to local pool: ${BANDWIDTH_SIZE_MS}ms"

call_gawk() {
  printf '%s' "$(gawk 'BEGIN {print '"${1}"'}')"
}

NPROC="$(nproc)"
# Linux uses this algorithm to multiply miliseconds
MODIFIER="$( call_gawk "10 ** 6 * (1 + int(log(${NPROC}) / log(2)))" )"

LATENCY_NS_FILE="/sys/kernel/debug/sched/latency_ns"
MIN_GRANULARITY_NS_FILE="/sys/kernel/debug/sched/min_granularity_ns"
WAKEUP_GRANULARITY_NS_FILE="/sys/kernel/debug/sched/wakeup_granularity_ns"
MIGRATION_COST_NS_FILE="/sys/kernel/debug/sched/migration_cost_ns"
BANDWIDTH_SIZE_US_FILE="/proc/sys/kernel/sched_cfs_bandwidth_slice_us"

if [ ! -f "$LATENCY_NS_FILE" ]; then
    echo "Detected kernel <5.13. Using legacy locations."
    LATENCY_NS_FILE="/proc/sys/kernel/sched_latency_ns"
    MIN_GRANULARITY_NS_FILE="/proc/sys/kernel/sched_min_granularity_ns"
    WAKEUP_GRANULARITY_NS_FILE="/proc/sys/kernel/sched_wakeup_granularity_ns"
    MIGRATION_COST_NS_FILE="/proc/sys/kernel/sched_migration_cost_ns"
fi

printf '%s' "$( call_gawk "int(${LATENCY_MS} * ${MODIFIER})" )" > "$LATENCY_NS_FILE"
printf '%s' "$( call_gawk "int(${MIN_GRANULARITY_MS} * ${MODIFIER})" )" > "$MIN_GRANULARITY_NS_FILE"
printf '%s' "$( call_gawk "int(${WAKEUP_GRANULARITY_MS} * ${MODIFIER})" )" > "$WAKEUP_GRANULARITY_NS_FILE"
printf '%s' "$( call_gawk "int(${MIGRATION_COST_MS} * ${MODIFIER})" )" > "$MIGRATION_COST_NS_FILE"
printf '%s' "$( call_gawk "int(${BANDWIDTH_SIZE_MS} * 1000)" )" > "$BANDWIDTH_SIZE_US_FILE"
