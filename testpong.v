`define VGA_WIDTH 160
`define VGA_HEIGHT 120
`define IMG_WIDTH 4
`define IMG_HEIGHT 4

// PONG

module testpong
	(
		CLOCK_50,			//	On Board 50 MHz
		// Your inputs and outputs here
        KEY

	);

	input			CLOCK_50;				//	50 MHz
	input   [3:0]   KEY;

	wire resetn;
	assign resetn = KEY[0];

    // Create the colour x, y and writeEn wires that are inputs to the controller.
    wire colour;
    wire [7:0] x;
    wire [6:0] y;
    wire w_plot;

    // More wires.
    wire x_en_wire, y_en_wire;
    wire [3:0] w_count_b;
    wire w_move;
    wire w_slow_clock;
    wire [7:0] w_xreg_b;
    wire [6:0] w_yreg_b;
	wire w_go = ~KEY[1];
	wire [3:0] w_state;
	wire [19:0] w_cnt;

    // datapath
    datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .xreg_b(w_xreg_b),
        .yreg_b(w_yreg_b),
        .count_b(w_count_b),
        .plot_b(w_plot),

        .EN(w_slow_clock),
        .x(x),
        .y(y),
		.cnt(w_cnt)
    );

    // ball
    ball b0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .x_in(8'b0),
        .y_in(7'b0),
        .x_en(x_en_wire),
        .y_en(y_en_wire),
        .plot_b(w_plot),
        .move(w_move),
        .EN(w_slow_clock),

        .count_b(w_count_b),
        .xreg_b(w_xreg_b),
        .yreg_b(w_yreg_b)
    );

    // control
    control c0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(w_go),
        .count_b(w_count_b),
        .EN(w_slow_clock),

        .x_en(x_en_wire),
        .y_en(y_en_wire),
        .plotout(w_plot),
        .colour_out(colour),
        .move(w_move),
		.current_state(w_state)
    );

endmodule

    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
    // datapath d0(...);

module datapath(
    input clk,
    input resetn,
    input [7:0] xreg_b,
    input [6:0] yreg_b,
    input [3:0] count_b,
    input plot_b,

    output reg EN = 1'b0,

    // Register for x coordinate.
    output reg [7:0] x = 8'b0,

    // Registers for y coordinate.
    output reg [6:0] y = 7'b0,

    output reg [19:0] cnt = 20'b0
    );

    // Slowed down clock speed.
    reg [19:0] clock_speed = 20'd10;

    always @ (posedge clk) begin
        cnt = cnt + 1;
        //Clock cycles for 50 Hz.
        if (cnt == clock_speed) begin
            cnt = 1'b0;
            EN = ~EN;
            if (clock_speed > 20'd5)
                clock_speed = clock_speed - 1'd1;
        end
    end

    // Adder to add count to the coordinates.
    always @ (posedge clk) begin
        if (!resetn)
        begin
            x <= 8'b0;
            y <= 7'b0;
        end
        else if (plot_b) begin
            x <= xreg_b + count_b[1:0];
            y <= yreg_b + count_b[3:2];
        end
    end
endmodule

module ball (
    input clk,
    input resetn,
    input [7:0] x_in,
    input [6:0] y_in,
    input x_en,
    input y_en, // Enable outputs from the FSM that signal the coordinates to move.
    input plot_b,
    input move,
    input EN, // 50Hz clock.

    // Register for Counter.
    output reg [3:0] count_b,

    // Registers for x and y coordinates of the ball.
    output reg [7:0] xreg_b,
    output reg [6:0] yreg_b
    );

    // Coordinates of the ball during animation.
    reg[7:0] x_anm_b = 0;
    reg[6:0] y_anm_b = 0;

    //Indicates direction of animation.
    reg x_fwd_b = 1, y_fwd_b = 1;

    // Registers xreg_b and yreg_b for the ball.
    always @ (posedge clk) begin
        if (!resetn)
        begin
            xreg_b <= 8'b0;
            yreg_b <= 7'b0;
        end
        else begin
            if (x_en) // S_LOAD state.
                xreg_b <= x_anm_b;
            else
                xreg_b <= xreg_b;
            if (y_en) // S_LOAD state.
                yreg_b <= y_anm_b;
            else
                yreg_b <= yreg_b;
        end
    end

    // Counter to draw 4 x 4 box.
    always @ (posedge clk) begin
        if (!resetn)
            count_b <= 4'b0;
        else if (count_b == 4'b1111)
            if (!EN)
                count_b <= 4'b1111;
            else
                count_b <= 4'b0;
        else if (plot_b) // S_PLOT_BALL state.
            count_b <= count_b + 4'b1;
    end

    //Clock for this module should be 500Hz (EN)
    always @ (posedge EN) begin
        if (!resetn) begin
            x_anm_b = 0;
            y_anm_b = 0;
            x_fwd_b = 1;
            y_fwd_b = 1;
        end

        else if (move) begin
            if (x_fwd_b) // S_MOVE state.
                x_anm_b = x_anm_b + 1;
            else
                x_anm_b = x_anm_b - 1;
            if (y_fwd_b) // S_MOVE state.
                y_anm_b = y_anm_b + 1;
            else
                y_anm_b = y_anm_b - 1;
            // Bounce off the right side of the screen.
            if (x_anm_b == (`VGA_WIDTH - `IMG_WIDTH))
                x_fwd_b = 0;
            // Bounce off the left side of the screen.
            else if (x_anm_b == 0)
                x_fwd_b = 1;
            // Bounce off the top of the screen.
            if (y_anm_b == (`VGA_HEIGHT - `IMG_HEIGHT))
                y_fwd_b = 0;
            // Bounce off the bottom of the screen.
            else if (y_anm_b == 0)
                y_fwd_b = 1;
        end
    end //end always

endmodule

    // Instansiate FSM control
    // control c0(...);

module control (
    input clk,
    input resetn,
    input go,
    input [3:0] count_b,
    input EN,

    output reg x_en,
    output reg y_en,
    output reg plotout,
    output reg colour_out,
    output reg move,
    output reg [3:0] current_state
    );

	reg [3:0] next_state;

    localparam      S_LOAD_WAIT        = 3'd0,
                    S_LOAD            = 3'd1,
                    S_PLOT_BALL        = 3'd2,
                    S_ERASE_BALL    = 3'd3,
                    S_MOVE            = 3'd4;

    // State table (next state logic).
    always @ (*)
    begin: state_table
        case (current_state)
            S_LOAD_WAIT: next_state = go ? S_LOAD : S_LOAD_WAIT; // Loop in current state until coordinates
            S_LOAD: next_state = S_PLOT_BALL;                                                                            // are loaded
            S_PLOT_BALL: begin
                if (count_b == 4'b1111)
                    next_state = S_ERASE_BALL;    // Start over after plotting.
                else
                    next_state = S_PLOT_BALL;
            end
            S_ERASE_BALL:  begin
                if ((count_b == 4'b1111))
                    next_state = S_MOVE;    // Start over after plotting.
                else
                    next_state = S_ERASE_BALL;
            end
            S_MOVE: next_state = S_LOAD;
            default: next_state = S_LOAD_WAIT;
        endcase
    end // state_table

    // Output logic (datapath control signals).
    always @ (*)
    begin: enable_signals
        // By default make the load and plot signals 0.
        x_en = 1'b0;
        y_en = 1'b0;
        plotout = 1'b0;
        move = 1'b0;
        colour_out = 3'b111;

        case (current_state)
            S_LOAD: begin
                x_en = 1'b1;
                y_en = 1'b1;
            end
            S_PLOT_BALL:    plotout = 1'b1;

            S_ERASE_BALL: begin
                colour_out = 3'b000;
                plotout = 1'b1;
            end
            S_MOVE: begin
                move = 1'b1;
            end
            // default: dont't need default case since we made sure all of the outputs were assigned a value at the
            // start of the always block.
        endcase
    end // enable_signals

    // current_state registers
    always @ (posedge EN)
    begin: state_FFs
        if (!resetn)
            current_state <= S_LOAD_WAIT;
        else
            current_state <= next_state;
    end // state_FFs

endmodule
