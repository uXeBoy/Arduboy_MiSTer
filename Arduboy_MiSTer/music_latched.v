// Music demo verilog file
// (c) fpga4fun.com 2003-2015

// Plays a little tune on a speaker
// Use a 25MHz clock if possible (other frequencies will
// change the pitch/speed of the song)

/////////////////////////////////////////////////////
module music_latched(
    input clk,
    input clk100,
    input [7:0] music_data,
    input latch,
    output reg speaker
);

reg [5:0] fullnote;

always @(posedge clk100)
begin
  if(latch && (music_data[5:0] > 12)) fullnote <= music_data[5:0] - 12;
  else if(latch && (music_data[5:0] < 13)) fullnote <= music_data[5:0];
end

wire [2:0] octave;
wire [3:0] note;
divide_by12 get_octave_and_note(.numerator(fullnote), .quotient(octave), .remainder(note));

reg [8:0] clkdivider;
always @*
case(note)
     0: clkdivider = 9'd511;//A
     1: clkdivider = 9'd482;// A#/Bb
     2: clkdivider = 9'd455;//B
     3: clkdivider = 9'd430;//C
     4: clkdivider = 9'd405;// C#/Db
     5: clkdivider = 9'd383;//D
     6: clkdivider = 9'd361;// D#/Eb
     7: clkdivider = 9'd341;//E
     8: clkdivider = 9'd322;//F
     9: clkdivider = 9'd303;// F#/Gb
    10: clkdivider = 9'd286;//G
    11: clkdivider = 9'd270;// G#/Ab
    default: clkdivider = 9'd0;
endcase

reg [8:0] counter_note;
reg [7:0] counter_octave;
always @(posedge clk) counter_note <= counter_note==0 ? clkdivider : counter_note-9'd1;
always @(posedge clk) if(counter_note==0) counter_octave <= counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1;
always @(posedge clk) if(counter_note==0 && counter_octave==0 && fullnote!=0) speaker <= ~speaker;
                      else if(fullnote==0) speaker <= 1'd0;
endmodule


/////////////////////////////////////////////////////
module divide_by12_latched(
    input [5:0] numerator,  // value to be divided by 12
    output reg [2:0] quotient,
    output [3:0] remainder
);

reg [1:0] remainder3to2;
always @(numerator[5:2])
case(numerator[5:2])
     0: begin quotient=0; remainder3to2=0; end
     1: begin quotient=0; remainder3to2=1; end
     2: begin quotient=0; remainder3to2=2; end
     3: begin quotient=1; remainder3to2=0; end
     4: begin quotient=1; remainder3to2=1; end
     5: begin quotient=1; remainder3to2=2; end
     6: begin quotient=2; remainder3to2=0; end
     7: begin quotient=2; remainder3to2=1; end
     8: begin quotient=2; remainder3to2=2; end
     9: begin quotient=3; remainder3to2=0; end
    10: begin quotient=3; remainder3to2=1; end
    11: begin quotient=3; remainder3to2=2; end
    12: begin quotient=4; remainder3to2=0; end
    13: begin quotient=4; remainder3to2=1; end
    14: begin quotient=4; remainder3to2=2; end
    15: begin quotient=5; remainder3to2=0; end
endcase

assign remainder[1:0] = numerator[1:0];  // the first 2 bits are copied through
assign remainder[3:2] = remainder3to2;  // and the last 2 bits come from the case statement
endmodule
/////////////////////////////////////////////////////
