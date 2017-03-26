`define VGA_WIDTH 160
`define VGA_HEIGHT 120
`define IMG_WIDTH 4
`define IMG_HEIGHT 4

// PONG

module pong
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                        //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                            //    VGA Green[9:0]
        VGA_B                           //    VGA Blue[9:0]
    );

    input            CLOCK_50;                //    50 MHz
    input   [3:0]   KEY;

    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                    //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]

    wire resetn;
    assign resetn = KEY[0];

    // Create the colour x, y and writeEn wires that are inputs to the controller.
    wire colour;
    wire [7:0] x;
    wire [6:0] y;
    wire w_plot_b;
    wire w_plot_p1;
    wire w_plot_p2;
    wire w_plot_p3;
    wire w_plot_p4;
    wire w_plotout;

    // More wires.
    wire en_wire;
    wire [3:0] w_count;
    wire w_move;
    wire w_slow_clock;
    wire [7:0] w_xreg_b;
    wire [6:0] w_yreg_b;
    wire [7:0] w_reg_p1;
    wire [7:0] w_reg_p2;
    wire [7:0] w_reg_p3;
    wire [7:0] w_reg_p4;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(w_plotout),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";

    // datapath
    datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .xreg_b(w_xreg_b),
        .yreg_b(w_yreg_b),
        .plot_b(w_plot_b),
        .plot_p1(w_plot_p1),
        .plot_p2(w_plot_p2),
        .plot_p3(w_plot_p3),
        .plot_p4(w_plot_p4),
        .reg_p1(w_reg_p1),
        .reg_p2(w_reg_p2),
        .reg_p3(w_reg_p3),
        .reg_p4(w_reg_p4),

        .EN(w_slow_clock),
        .x(x),
        .y(y),
        .count(w_count),
        .plotout(w_plotout)
    );

    // ball
    ball p0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .x_in(8'b0),
        .y_in(7'b0),
        .ld_en(en_wire),
        .move(w_move),
        .EN(w_slow_clock),

        .xreg_b(w_xreg_b),
        .yreg_b(w_yreg_b)
    );

    // paddle 1 (left)
    paddle p1(
        .clk(CLOCK_50),
        .resetn(resetn),
        .ld_en(en_wire),
        .move(w_move),
        .EN(w_slow_clock),
        .right_p(KEY[2]),
        .left_p(KEY[3]),
        .height_width(8'd120),

        .reg_p(w_reg_p1)
        );

    // paddle 2 (top)
    paddle p2(
        .clk(CLOCK_50),
        .resetn(resetn),
        .ld_en(en_wire),
        .move(w_move),
        .EN(w_slow_clock),
        .right_p(KEY[2]),
        .left_p(KEY[3]),
        .height_width(8'd160),

        .reg_p(w_reg_p2)
    );

    // paddle 3 (right)
    paddle p3(
        .clk(CLOCK_50),
        .resetn(resetn),
        .ld_en(en_wire),
        .move(w_move),
        .EN(w_slow_clock),
        .right_p(KEY[2]),
        .left_p(KEY[3]),
        .height_width(8'd120),

        .reg_p(w_reg_p3)
    );

    // paddle 4 (bottom)
    paddle p4(
        .clk(CLOCK_50),
        .resetn(resetn),
        .ld_en(en_wire),
        .move(w_move),
        .EN(w_slow_clock),
        .right_p(KEY[2]),
        .left_p(KEY[3]),
        .height_width(8'd160),

        .reg_p(w_reg_p4)
    );

    // control
    control c0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(KEY[1]),
        .count(w_count),
        .EN(w_slow_clock),

        .ld_en(en_wire),
        .plot_b(w_plot_b),
        .plot_p1(w_plot_p1),
        .plot_p2(w_plot_p2),
        .plot_p3(w_plot_p3),
        .plot_p4(w_plot_p4),
        .colour_out(colour),
        .move(w_move)
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
    input plot_b,
    input plot_p1,
    input plot_p2,
    input plot_p3,
    input plot_p4,
    input [7:0] reg_p1,
    input [7:0] reg_p2,
    input [7:0] reg_p3,
    input [7:0] reg_p4,

    output reg [3:0] count,

    output reg EN = 1'b0,

    // Register for x coordinate.
    output reg [7:0] x = 8'b0,

    // Registers for y coordinate.
    output reg [6:0] y = 7'b0,

    output reg plotout
    );

	reg [19:0] cnt = 20'b0;

    // Slowed down clock speed.
    reg [19:0] clock_speed = 20'd10;

    always @ (posedge clk) begin
        cnt <= cnt + 1;
        //Clock cycles for 50 Hz.
        if (cnt == clock_speed) begin
            cnt <= 1'b0;
            EN <= ~EN;
            if (clock_speed > 20'd5)
                clock_speed <= clock_speed - 1'd1;
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
            x <= xreg_b + count[1:0];
            y <= yreg_b + count[3:2];
            plotout = 1'b1;
        end
        else if (plot_p1) begin
            x <= count[0];
            y <= reg_p1 + count[3:1];
            plotout = 1'b1;
        end
        else if (plot_p2) begin
            x <= reg_p2 + count[2:0];
            y <= count[3];
            plotout = 1'b1;
        end
        else if (plot_p3) begin
            x <= 8'd159 + count[0];
            y <= reg_p3 + count[3:1];
            plotout = 1'b1;
        end
        else if (plot_p4) begin
            x <= reg_p4 + count[2:0];
            y <= 8'd119 + count[3];
            plotout <= 1'b1;
        end
        else
            plotout <= 1'b0;
    end

    // Counter to draw 4 x 4 box.
    always @ (posedge clk) begin
        if (!resetn)
            count <= 4'b0;
        else if (count == 4'b1111)
            if (!EN)
                count <= 4'b1111;
            else
                count <= 4'b0;
        else if (plot_b || plot_p1 || plot_p2 || plot_p3 || plot_p4) // S_PLOT_BALL state.
            count <= count + 4'b1;
    end

endmodule

module ball (
    input clk,
    input resetn,
    input [7:0] x_in,
    input [6:0] y_in,
    input ld_en, // Enable output from the FSM that signal the coordinates to move.
    input move,
    input EN, // 50Hz clock.

    // Registers for x and y coordinates of the ball.
    output reg [7:0] xreg_b,
    output reg [6:0] yreg_b
    );

    // Coordinates of the ball during animation.
    reg[7:0] x_anm_b = 8'b0;
    reg[6:0] y_anm_b = 7'b0;

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
            if (ld_en) begin // S_LOAD state.
                xreg_b <= x_anm_b;
                yreg_b <= y_anm_b;
            end
            else begin
                xreg_b <= xreg_b;
                yreg_b <= yreg_b;
            end
        end
    end

    //Clock for this module should be 500Hz (EN)
    always @ (posedge EN) begin
        if (!resetn) begin
            x_anm_b <= 8'b0;
            y_anm_b <= 7'b0;
            x_fwd_b <= 1'b1;
            y_fwd_b <= 1'b1;
        end

        else if (move) begin
            if (x_fwd_b) // S_MOVE state.
                x_anm_b <= x_anm_b + 8'b1;
            else
                x_anm_b <= x_anm_b - 8'b1;
            if (y_fwd_b) // S_MOVE state.
                y_anm_b <= y_anm_b + 7'b1;
            else
                y_anm_b <= y_anm_b - 7'b1;
            // Bounce off the right side of the screen.
            if (x_anm_b == (`VGA_WIDTH - `IMG_WIDTH))
                x_fwd_b <= 1'b0;
            // Bounce off the left side of the screen.
            else if (x_anm_b == 8'b0)
                x_fwd_b <= 1'b1;
            // Bounce off the top of the screen.
            if (y_anm_b == (`VGA_HEIGHT - `IMG_HEIGHT))
                y_fwd_b <= 1'b0;
            // Bounce off the bottom of the screen.
            else if (y_anm_b == 7'b0)
                y_fwd_b <= 1'b1;
        end
    end //end always

endmodule

module paddle (
    input clk,
    input resetn,
    input ld_en, // Enable output from the FSM that signal the coordinates to move.
    input move,
    input EN, // 50Hz clock.
    input right_p, //Indicates direction of animation.
    input left_p,
    input [7:0] height_width,

    // Registers for coordinates of the paddle.
    output reg [7:0] reg_p
    );

    // Coordinates of the ball during animation.
    reg [7:0] anm_p = 8'b0;

    // Registers xreg_p and yreg_p for the ball.
    always @ (posedge clk) begin
        if (!resetn)
        begin
            reg_p <= 8'b0;
        end
        else begin
            if (ld_en) // S_LOAD state.
                reg_p <= anm_p;
            else
                reg_p <= reg_p;
        end
    end

    //Clock for this module should be 500Hz (EN)
    always @ (posedge EN) begin
        if (!resetn) begin
            anm_p <= 8'b0;
        end

        else if (move) begin
            if (right_p) begin // S_MOVE state.
                if (anm_p == (height_width - 4'd8))
                    anm_p <= anm_p;
                else
                    anm_p <= anm_p + 8'b1;
            end
            else if (left_p) begin
                if (anm_p == 8'b0)
                    anm_p <= anm_p;
                else
                    anm_p <= anm_p - 8'b1;
            end
			else if (left_p && right_p)
				anm_p <= anm_p;
        end
    end //end always
endmodule

    // Instansiate FSM control
    // control c0(...);

module control (
    input clk,
    input resetn,
    input go,
    input [3:0] count,
    input EN,

    output reg ld_en,
    output reg plot_b,
    output reg plot_p1,
    output reg plot_p2,
    output reg plot_p3,
    output reg plot_p4,
    output reg colour_out,
    output reg move
    );

    reg [3:0] current_state, next_state;

    localparam      S_LOAD_WAIT        = 4'd0,
                    S_LOAD            = 4'd1,
                    S_PLOT_BALL        = 4'd2,
                    S_PLOT_P1        = 4'd3,
                    S_PLOT_P2        = 4'd4,
                    S_PLOT_P3        = 4'd5,
                    S_PLOT_P4        = 4'd6,
                    S_ERASE_BALL    = 4'd7,
                    S_ERASE_P1        = 4'd8,
                    S_ERASE_P2        = 4'd9,
                    S_ERASE_P3        = 4'd10,
                    S_ERASE_P4        = 4'd11,
                    S_MOVE            = 4'd12;

    // State table (next state logic).
    always @ (*)
    begin: state_table
        case (current_state)
            S_LOAD_WAIT: next_state = go ? S_LOAD : S_LOAD_WAIT; // Loop in current state until coordinates
            S_LOAD: next_state = S_PLOT_BALL;                                                                            // are loaded
            S_PLOT_BALL: begin
                if (count == 4'b1111)
                    next_state = S_PLOT_P1;    // Start over after plotting.
                else
                    next_state = S_PLOT_BALL;
            end
            S_PLOT_P1: begin
                if (count == 4'b1111)
                    next_state = S_PLOT_P2;    // Start over after plotting.
                else
                    next_state = S_PLOT_P1;
            end
            S_PLOT_P2: begin
                if (count == 4'b1111)
                    next_state = S_PLOT_P3;    // Start over after plotting.
                else
                    next_state = S_PLOT_P2;
            end
            S_PLOT_P3: begin
                if (count == 4'b1111)
                    next_state = S_PLOT_P4;    // Start over after plotting.
                else
                    next_state = S_PLOT_P3;
            end
            S_PLOT_P4: begin
                if (count == 4'b1111)
                    next_state = S_ERASE_BALL;    // Start over after plotting.
                else
                    next_state = S_PLOT_P4;
            end
            S_ERASE_BALL:  begin
                if (count == 4'b1111)
                    next_state = S_MOVE;    // Start over after plotting.
                else
                    next_state = S_ERASE_BALL;
            end
            S_ERASE_P1:  begin
                if (count == 4'b1111)
                    next_state = S_ERASE_P2;    // Start over after plotting.
                else
                    next_state = S_ERASE_P1;
            end
            S_ERASE_P2:  begin
                if (count == 4'b1111)
                    next_state = S_ERASE_P3;    // Start over after plotting.
                else
                    next_state = S_ERASE_P2;
            end
            S_ERASE_P3:  begin
                if (count == 4'b1111)
                    next_state = S_ERASE_P4;    // Start over after plotting.
                else
                    next_state = S_ERASE_P3;
            end
            S_ERASE_P4:  begin
                if (count == 4'b1111)
                    next_state = S_MOVE;    // Start over after plotting.
                else
                    next_state = S_ERASE_P4;
            end
            S_MOVE: next_state = S_LOAD;
            default: next_state = S_LOAD_WAIT;
        endcase
    end // state_table

    // Output logic (datapath control signals).
    always @ (*)
    begin: enable_signals
        // By default make the load and plot signals 0.
        ld_en = 1'b0;
        plot_b = 1'b0;
        plot_p1 = 1'b0;
        plot_p2 = 1'b0;
        plot_p3 = 1'b0;
        plot_p4 = 1'b0;
        move = 1'b0;
        colour_out = 3'b111;

        case (current_state)
            S_LOAD: begin
                ld_en = 1'b1;
            end
            S_PLOT_BALL:  plot_b = 1'b1;
            S_PLOT_P1:    plot_p1 = 1'b1;
            S_PLOT_P2:    plot_p2 = 1'b1;
            S_PLOT_P3:    plot_p3 = 1'b1;
            S_PLOT_P4:    plot_p4 = 1'b1;
            S_ERASE_BALL: begin
                colour_out = 3'b000;
                plot_b = 1'b1;
            end
            S_ERASE_P1: begin
                colour_out = 3'b000;
                plot_p1 = 1'b1;
            end
            S_ERASE_P2: begin
                colour_out = 3'b000;
                plot_p2 = 1'b1;
            end
            S_ERASE_P3: begin
                colour_out = 3'b000;
                plot_p3 = 1'b1;
            end
            S_ERASE_P4: begin
                colour_out = 3'b000;
                plot_p4 = 1'b1;
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
