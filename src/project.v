/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_equipo7 (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs: Entrada
    output wire [7:0] uio_out,  // IOs: Salida
    output wire [7:0] uio_oe,   // IOs: Habilitación (1=salida, 0=entrada)
    input  wire       ena,      // Siempre en 1 cuando el diseño está encendido
    input  wire       clk,      // Reloj
    input  wire       rst_n     // Reset activo en bajo
);

    // Ejemplo sencillo: suma de ui_in y uio_in, y salida por uo_out
    assign uo_out  = ui_in + uio_in;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Para evitar advertencias por señales no utilizadas
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
