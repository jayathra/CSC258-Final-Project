vlib work

vlog -timescale 1ns/1ns testpong.v

vsim testpong
log {/*}

add wave {/*}

# CLOCK
force {CLOCK_50} 0 0ns, 1 2ns -r 4ns

# RESET
force {KEY[0]} 0 0ns, 1 3ns

# GO
force {KEY[1]} 1 0ns, 0 9ns

run 500000ns