module tx(
  input reinicio,
  input clock,
  input [7:0] info_in,
  input start,
  output reg TX,
  output reg ocupado
);
  typedef enum reg [1:0] {Reposo, Start, Info, Stop} Estados;
  Estados EstadosTx;
  reg [2:0] Indexes;
  reg [7:0] DataSaved;

  always @(posedge clock or posedge reinicio) begin
    if (reinicio) begin
      EstadosTx <= Reposo;
      Indexes <= 0; 
      TX <= 1; 
      ocupado <= 0;
    end else begin
      case(EstadosTx)
        Reposo: begin
          TX <= 1;
          ocupado <= 0;
          if (start) begin 
            DataSaved <= info_in;
            EstadosTx <= Start;
            ocupado <= 1;
          end
        end

        Start: begin
          TX <= 0;
          EstadosTx <= Info;
          Indexes <= 0;
        end

        Info: begin
          TX <= DataSaved[Indexes];
          if (Indexes == 7) 
            EstadosTx <= Stop;
          else 
            Indexes <= Indexes + 1;
        end

        Stop: begin
          TX <= 1;
          EstadosTx <= Reposo;
        end
      endcase
    end
  end
endmodule


module rx (
  input RX,
  input clock,
  input reinicio,
  output reg Terminado,
  output reg [7:0] info_out
);
  reg WaitRx;
  typedef enum reg [1:0] {Reposo, Start, Info, Stop} Estados;
  Estados EstadosRx;
  reg [2:0] Indexes;
  reg [7:0] DataSaved;

  always @(posedge clock or posedge reinicio) begin
    if (reinicio)
      WaitRx <= 1'b1;  
    else
      WaitRx <= RX;    
  end

  always @(posedge clock or posedge reinicio) begin 
    if (reinicio) begin
      EstadosRx <= Reposo; 
      Terminado <= 0;
      Indexes <= 0;
    end else begin
      case (EstadosRx)
        Reposo: begin
          Terminado <= 0;
          if (RX == 0) begin
            EstadosRx <= Start;
          end
        end

        Start: begin
          EstadosRx <= Info;
          Indexes <= 0;
        end

        Info: begin
          DataSaved[Indexes] <= WaitRx;
          if (Indexes == 7) begin
            EstadosRx <= Stop;
          end else begin
            Indexes <= Indexes + 1;
          end
        end

        Stop: begin
          info_out <= DataSaved;
          Terminado <= 1;
          EstadosRx <= Reposo;
        end
      endcase
    end
  end
endmodule


module tt_um_equipo7 (
  input wire [7:0] ui_in,
  output wire [7:0] uo_out,
  input wire [7:0] uio_in,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe
);
  wire clockUart = ui_in[0];
  wire resetUart = ui_in[1];
  wire StartUart = ui_in[2];
  wire [7:0] info_in_Uart = {5'b00000, ui_in[7:3]}; // solo 5 bits de entrada

  wire [7:0] info_out_Uart;
  wire TerminadoUart;

  assign uo_out = info_out_Uart;

  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;

  UARTComplete uart_inst (
    .clockUart(clockUart),
    .resetUart(resetUart),
    .StartUart(StartUart),
    .info_in_Uart(info_in_Uart),
    .info_out_Uart(info_out_Uart),
    .TerminadoUart(TerminadoUart)
  );
endmodule


module UARTComplete (
  input clockUart,
  input resetUart,
  input StartUart,
  input [7:0] info_in_Uart,
  output [7:0] info_out_Uart,
  output TerminadoUart
);
  wire Tx;

  tx txUart (
    .clock(clockUart),
    .reinicio(resetUart),
    .info_in(info_in_Uart),
    .start(StartUart),
    .TX(Tx),
    .ocupado()
  );

  rx rxUart (
    .clock(clockUart),
    .reinicio(resetUart),
    .RX(Tx),
    .info_out(info_out_Uart),
    .Terminado(TerminadoUart)
  );
endmodule
