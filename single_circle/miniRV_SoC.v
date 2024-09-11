`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    input  wire [23:0]  sw,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A,
    output wire         DN_B,
    output wire         DN_C,
    output wire         DN_D,
    output wire         DN_E,
    output wire         DN_F,
    output wire         DN_G,
    output wire         DN_DP,
    output wire [23:0]  led

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // WB ?  ?   ?   ( ?     CPU     ? ¦Ë   ?1)
    output wire [31:0]  debug_wb_pc,        // WB ?¦Å PC (  wb_have_inst=0       ?    ?)
    output wire         debug_wb_ena,       // WB ?¦Å??   §Õ?   (  wb_have_inst=0       ?    ?)
    output wire [ 4:0]  debug_wb_reg,       // WB ? §Õ  ??      (  wb_ena  wb_have_inst=0       ?    ?)
    output wire [31:0]  debug_wb_value      // WB ? §Õ  ?     ? (  wb_ena  wb_have_inst=0       ?    ?)
`endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // Interface between CPU and IROM
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // Interface between CPU and Bridge
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire [3:0 ] Bus_we;
    wire [31:0] Bus_wdata;
    
    // Interface between bridge and DRAM
    // wire         rst_bridge2dram;
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire [3:0 ]  we_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
    
    // Interface between bridge and peripherals
    // TODO:  ??               I/O ?? ¡¤?        ? 
    //7-seg digital LEDs
    wire rst_bridge2dig;
	wire clk_bridge2dig;
    wire[11:0] addr_bridge2dig;
    wire[3:0] we_bridge2dig;
    wire[31:0] wdata_bridge2dig;
    //LEDs
    wire rst_bridge2led;
	wire clk_bridge2led;
    wire[11:0] addr_bridge2led; 
    wire[3:0] we_bridge2led;
    wire[31:0] wdata_bridge2led;
    //swithches
    wire rst_bridge2sw;
	wire clk_bridge2sw;
    wire[11:0] addr_bridge2sw;
    wire[31:0] rdata_bridge2sw={{8{1'b0}},{sw[23:0]}};
    //buttons
    wire rst_bridge2btn;
	wire clk_bridge2btn;
    wire[11:0] addr_bridge2btn;
    wire[31:0] rdata_bridge2btn = {{27{1'b0}},{button[4:0]}};

    
`ifdef RUN_TRACE
    // Trace    ?  ?  ?   ?    ?  
    assign cpu_clk = fpga_clk;
`else
    //  ¡ã ?  ?  PLL  ?   ?  
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        // .resetn     (!fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        // Interface to IROM
        .inst_addr          (inst_addr),
        .inst               (inst),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_we             (Bus_we),
        .Bus_wdata          (Bus_wdata)

`ifdef RUN_TRACE
        ,// Debug Interface
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (inst)
    );
    
    Bridge Bridge (       
        // Interface to CPU
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .we_from_cpu        (Bus_we),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // Interface to DRAM
        // .rst_to_dram    (rst_bridge2dram),
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .we_to_dram         (we_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        
        // Interface to 7-seg digital LEDs
        .rst_to_dig         (/* TODO */rst_bridge2dig),
        .clk_to_dig         (/* TODO */clk_bridge2dig),
        .addr_to_dig        (/* TODO */addr_bridge2dig),
        .we_to_dig          (/* TODO */we_bridge2dig),
        .wdata_to_dig       (/* TODO */wdata_bridge2dig),

        // Interface to LEDs
        .rst_to_led         (/* TODO */rst_bridge2led),
        .clk_to_led         (/* TODO */clk_bridge2led),
        .addr_to_led        (/* TODO */addr_bridge2led),
        .we_to_led          (/* TODO */we_bridge2led),
        .wdata_to_led       (/* TODO */wdata_bridge2led),

        // Interface to switches
        .rst_to_sw          (/* TODO */rst_bridge2sw),
        .clk_to_sw          (/* TODO */clk_bridge2sw),
        .addr_to_sw         (/* TODO */addr_bridge2sw),
        .rdata_from_sw      (/* TODO */rdata_bridge2sw),

        // Interface to buttons
        .rst_to_btn         (/* TODO */rst_bridge2btn),
        .clk_to_btn         (/* TODO */clk_bridge2btn),
        .addr_to_btn        (/* TODO */addr_bridge2btn),
        .rdata_from_btn     (/* TODO */rdata_bridge2btn)
    );

    DRAM Mem_DRAM (
        .clk        (clk_bridge2dram),
        .a          (addr_bridge2dram[15:2]),
        .spo        (rdata_dram2bridge),
        .we         (we_bridge2dram),
        .d          (wdata_bridge2dram)
    );
    
    // TODO:  ? ?           I/O ?? ¡¤?  
    //LEDs
    LEDs U_LEDs(
      .rst(fpga_rst),
      .data(wdata_bridge2led),
      .data_en(we_bridge2led),
      .led(led)
    );
    //7-seg digital LEDs
    display U_display(
      .clk(fpga_clk),
      .rst(fpga_rst),
      .data(wdata_bridge2dig),
      .data_en(we_bridge2dig),
      .led_en(dig_en),
      .led({DN_DP,DN_G,DN_F,DN_E,DN_D,DN_C,DN_B,DN_A})  
    );


endmodule
