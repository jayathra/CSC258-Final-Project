vlib work

vlog -timescale 1ns/1ns pong.v

vsim datapath
log {/*}

add wave {/*}

# CLOCK
force {clk} 0 0ns, 1 2ns -r 4ns

# RESET
force {resetn} 0 0ns, 1 3ns

# MOVE
force {move} 1 0ns

# PLOT
force {plot} 1 0ns

# X_EN & Y_EN
force {x_en} 1 0ns
force {y_en} 1 0ns

# X_IN
force {x_in[7]} 0 0ns
force {x_in[6]} 0 0ns
force {x_in[5]} 0 0ns
force {x_in[4]} 0 0ns
force {x_in[3]} 0 0ns
force {x_in[2]} 0 0ns
force {x_in[1]} 0 0ns
force {x_in[0]} 0 0ns

# Y_IN
force {y_in[6]} 0 0ns
force {y_in[5]} 0 0ns
force {y_in[4]} 0 0ns
force {y_in[3]} 0 0ns
force {y_in[2]} 0 0ns
force {y_in[1]} 0 0ns
force {y_in[0]} 0 0ns

run 5000000ns