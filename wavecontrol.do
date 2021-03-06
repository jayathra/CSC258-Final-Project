vlib work

vlog -timescale 1ns/1ns pong.v

vsim control
log {/*}

add wave {/*}

# CLOCK
force {clk} 0 0ns, 1 2ns -r 4ns

# RESET
force {resetn} 0 0ns, 1 3ns

# GO
force {go} 0 0ns, 1 9ns

# COUNT
force {count[3]} 1 25ns
force {count[2]} 1 25ns
force {count[1]} 1 25ns
force {count[0]} 1 25ns

#EN
force {EN} 0 0ns, 1 4ns -r 8ns

run 50ns
