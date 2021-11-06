#!/bin/bash
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

call_awk() {
  echo "$(awk 'BEGIN {print '"${1}"'}')"
}

NPROC="$(nproc)"
# Linux uses this algorithm to multiply miliseconds
MODIFIER=$( call_awk "10 ** 6 * (1 + int(log(${NPROC}) / log(2)))" )

echo $( call_awk "int(${LATENCY_MS} * ${MODIFIER})" ) > /sys/kernel/debug/sched/latency_ns
echo $( call_awk "int(${MIN_GRANULARITY_MS} * ${MODIFIER})" ) > /sys/kernel/debug/sched/min_granularity_ns
echo $( call_awk "int(${WAKEUP_GRANULARITY_MS} * ${MODIFIER})" ) > /sys/kernel/debug/sched/wakeup_granularity_ns
echo $( call_awk "int(${MIGRATION_COST_MS} * ${MODIFIER})" ) > /sys/kernel/debug/sched/migration_cost_ns
echo $( call_awk "int(${BANDWIDTH_SIZE_MS} * 1000)" ) > /proc/sys/kernel/sched_cfs_bandwidth_slice_us
