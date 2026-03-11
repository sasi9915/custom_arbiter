`timescale 1ns/1ps

module mod_intrlv_tb;
    
    // Mod Interleaver Signals

    // /AXI Clock and reset signals
    wire            axis_resetn;
    wire            axis_clk;
    
    
    // AXI Stream Slave Interface (frame)
    reg             frame_tvalid;
    wire            frame_tready;
    reg [15:0]      frame_tuser;
    reg [31:0]      frame_tdata;
    reg [3:0]       frame_tkeep;
    reg             frame_tlast;
    
    // AXI Stream Master Interface (frame_intrlvd)
    wire            frame_intrlvd_tvalid;
    reg             frame_intrlvd_tready;
    wire [15:0]     frame_intrlvd_tuser;
    wire [31:0]     frame_intrlvd_tdata;
    wire [3:0]      frame_intrlvd_tkeep;
    wire            frame_intrlvd_tlast;
    
    // AXI4 Master Interface (DDR4)
    wire [3:0]      ddr4_m_axi_awid;
    wire [28:0]     ddr4_m_axi_awaddr;
    wire [7:0]      ddr4_m_axi_awlen;
    wire [2:0]      ddr4_m_axi_awsize;
    wire [1:0]      ddr4_m_axi_awburst;
    wire            ddr4_m_axi_awlock;
    wire [3:0]      ddr4_m_axi_awcache;
    wire [2:0]      ddr4_m_axi_awprot;
    wire [3:0]      ddr4_m_axi_awqos;
    wire            ddr4_m_axi_awvalid;
    wire            ddr4_m_axi_awready;
    
    wire [127:0]    ddr4_m_axi_wdata;
    wire [15:0]     ddr4_m_axi_wstrb;
    wire            ddr4_m_axi_wlast;
    wire            ddr4_m_axi_wvalid;
    wire            ddr4_m_axi_wready;
    
    wire            ddr4_m_axi_bready;
    wire [3:0]      ddr4_m_axi_bid;
    wire [1:0]      ddr4_m_axi_bresp;
    wire            ddr4_m_axi_bvalid;
    
    wire [3:0]      ddr4_m_axi_arid;
    wire [28:0]     ddr4_m_axi_araddr;
    wire [7:0]      ddr4_m_axi_arlen;
    wire [2:0]      ddr4_m_axi_arsize;
    wire [1:0]      ddr4_m_axi_arburst;
    wire            ddr4_m_axi_arlock;
    wire [3:0]      ddr4_m_axi_arcache;
    wire [2:0]      ddr4_m_axi_arprot;
    wire [3:0]      ddr4_m_axi_arqos;
    wire            ddr4_m_axi_arvalid;
    wire            ddr4_m_axi_arready;
    
    wire            ddr4_m_axi_rready;
    wire            ddr4_m_axi_rlast;
    wire            ddr4_m_axi_rvalid;
    wire [1:0]      ddr4_m_axi_rresp;
    wire [3:0]      ddr4_m_axi_rid;
    wire [127:0]    ddr4_m_axi_rdata;



    // DDR4 Interface Signals
    // System Reset
    wire            ddr4_intf_sys_rst;

    // Clock and Reset Interface
    wire            ddr4_intf_c0_init_calib_complete;
    wire            ddr4_intf_dbg_clk;
    reg             ddr4_intf_c0_sys_clk_p;
    wire            ddr4_intf_c0_sys_clk_n;
    wire [511:0]    ddr4_intf_dbg_bus;
        
    // DDR4 Memory Interface
    reg             ddr4_intf_c0_ddr4_aresetn;
    wire [16:0]     ddr4_intf_c0_ddr4_adr;
    wire [1:0]      ddr4_intf_c0_ddr4_ba;
    wire [0:0]      ddr4_intf_c0_ddr4_cke;
    wire [0:0]      ddr4_intf_c0_ddr4_cs_n;
    wire [1:0]      ddr4_intf_c0_ddr4_dm_dbi_n;
    wire [15:0]     ddr4_intf_c0_ddr4_dq;
    wire [1:0]      ddr4_intf_c0_ddr4_dqs_c;
    wire [1:0]      ddr4_intf_c0_ddr4_dqs_t;
    wire [0:0]      ddr4_intf_c0_ddr4_odt;
    wire [0:0]      ddr4_intf_c0_ddr4_bg;
    wire            ddr4_intf_c0_ddr4_reset_n;
    wire            ddr4_intf_c0_ddr4_act_n;
    wire [0:0]      ddr4_intf_c0_ddr4_ck_c;
    wire [0:0]      ddr4_intf_c0_ddr4_ck_t;
    wire            ddr4_intf_c0_ddr4_ui_clk;
    wire            ddr4_intf_c0_ddr4_ui_clk_sync_rst;
    

    

    

    
    localparam real CLK_FREQ_HZ   = 100_000_000.0;              // 100 MHz
    localparam real CLK_PERIOD_NS = 1e9 / CLK_FREQ_HZ;

    localparam real DDR_REF_FREQ_HZ   = 75_000_000.0;           // 75 MHz
    localparam real DDR_REF_PERIOD_NS = 1e9 / DDR_REF_FREQ_HZ;

    
    // Instantiate top (includes custom AXI interconnect + mod_intrlv)
    top top_inst (
        .axis_resetn            (axis_resetn),
        .axis_clk               (axis_clk),

        .mod_frame_tready       (frame_tready),
        .mod_frame_tvalid       (frame_tvalid),
        .mod_frame_tuser        (frame_tuser),
        .mod_frame_tdata        (frame_tdata),
        .mod_frame_tkeep        (frame_tkeep),
        .mod_frame_tlast        (frame_tlast),

        .frame_intrlvd_tready   (frame_intrlvd_tready),
        .frame_intrlvd_tvalid   (frame_intrlvd_tvalid),
        .frame_intrlvd_tuser    (frame_intrlvd_tuser),
        .frame_intrlvd_tdata    (frame_intrlvd_tdata),
        .frame_intrlvd_tkeep    (frame_intrlvd_tkeep),
        .frame_intrlvd_tlast    (frame_intrlvd_tlast),

        .M_AXI_AWID             (ddr4_m_axi_awid),
        .M_AXI_AWADDR           (ddr4_m_axi_awaddr),
        .M_AXI_AWLEN            (ddr4_m_axi_awlen),
        .M_AXI_AWSIZE           (ddr4_m_axi_awsize),
        .M_AXI_AWBURST          (ddr4_m_axi_awburst),
        .M_AXI_AWLOCK           (ddr4_m_axi_awlock),
        .M_AXI_AWCACHE          (ddr4_m_axi_awcache),
        .M_AXI_AWPROT           (ddr4_m_axi_awprot),
        .M_AXI_AWQOS            (ddr4_m_axi_awqos),
        .M_AXI_AWVALID          (ddr4_m_axi_awvalid),
        .M_AXI_AWREADY          (ddr4_m_axi_awready),
        .M_AXI_WDATA            (ddr4_m_axi_wdata),
        .M_AXI_WSTRB            (ddr4_m_axi_wstrb),
        .M_AXI_WLAST            (ddr4_m_axi_wlast),
        .M_AXI_WVALID           (ddr4_m_axi_wvalid),
        .M_AXI_WREADY           (ddr4_m_axi_wready),
        .M_AXI_BID              (ddr4_m_axi_bid),
        .M_AXI_BRESP            (ddr4_m_axi_bresp),
        .M_AXI_BVALID           (ddr4_m_axi_bvalid),
        .M_AXI_BREADY           (ddr4_m_axi_bready),
        .M_AXI_ARID             (ddr4_m_axi_arid),
        .M_AXI_ARADDR           (ddr4_m_axi_araddr),
        .M_AXI_ARLEN            (ddr4_m_axi_arlen),
        .M_AXI_ARSIZE           (ddr4_m_axi_arsize),
        .M_AXI_ARBURST          (ddr4_m_axi_arburst),
        .M_AXI_ARLOCK           (ddr4_m_axi_arlock),
        .M_AXI_ARCACHE          (ddr4_m_axi_arcache),
        .M_AXI_ARPROT           (ddr4_m_axi_arprot),
        .M_AXI_ARQOS            (ddr4_m_axi_arqos),
        .M_AXI_ARVALID          (ddr4_m_axi_arvalid),
        .M_AXI_ARREADY          (ddr4_m_axi_arready),
        .M_AXI_RID              (ddr4_m_axi_rid),
        .M_AXI_RDATA            (ddr4_m_axi_rdata),
        .M_AXI_RRESP            (ddr4_m_axi_rresp),
        .M_AXI_RLAST            (ddr4_m_axi_rlast),
        .M_AXI_RVALID           (ddr4_m_axi_rvalid),
        .M_AXI_RREADY           (ddr4_m_axi_rready)
    );
    

    // Instantiate DDR4 Interface
    ddr4_intf ddr4_intf_inst (
        // System Reset
        .sys_rst                  (ddr4_intf_sys_rst),

        // Clock and Reset Interface
        .c0_init_calib_complete   (ddr4_intf_c0_init_calib_complete),
        .dbg_clk                  (ddr4_intf_dbg_clk),
        .c0_sys_clk_p             (ddr4_intf_c0_sys_clk_p),
        .c0_sys_clk_n             (ddr4_intf_c0_sys_clk_n),
        .dbg_bus                  (ddr4_intf_dbg_bus),
        
        // DDR4 Memory Interface
        .c0_ddr4_aresetn          (ddr4_intf_c0_ddr4_aresetn),
        .c0_ddr4_ui_clk_sync_rst  (ddr4_intf_c0_ddr4_ui_clk_sync_rst),
        .c0_ddr4_ui_clk           (ddr4_intf_c0_ddr4_ui_clk),

        .c0_ddr4_adr              (ddr4_intf_c0_ddr4_adr),
        .c0_ddr4_ba               (ddr4_intf_c0_ddr4_ba),
        .c0_ddr4_cke              (ddr4_intf_c0_ddr4_cke),
        .c0_ddr4_cs_n             (ddr4_intf_c0_ddr4_cs_n),
        .c0_ddr4_dm_dbi_n         (ddr4_intf_c0_ddr4_dm_dbi_n),
        .c0_ddr4_dq               (ddr4_intf_c0_ddr4_dq),
        .c0_ddr4_dqs_c            (ddr4_intf_c0_ddr4_dqs_c),
        .c0_ddr4_dqs_t            (ddr4_intf_c0_ddr4_dqs_t),
        .c0_ddr4_odt              (ddr4_intf_c0_ddr4_odt),
        .c0_ddr4_bg               (ddr4_intf_c0_ddr4_bg),
        .c0_ddr4_reset_n          (ddr4_intf_c0_ddr4_reset_n),
        .c0_ddr4_act_n            (ddr4_intf_c0_ddr4_act_n),
        .c0_ddr4_ck_c             (ddr4_intf_c0_ddr4_ck_c),
        .c0_ddr4_ck_t             (ddr4_intf_c0_ddr4_ck_t),
        
        // AXI Slave Interface (Connected to mod_intrlv)
        .c0_ddr4_s_axi_awid       (ddr4_m_axi_awid),
        .c0_ddr4_s_axi_awaddr     (ddr4_m_axi_awaddr),
        .c0_ddr4_s_axi_awlen      (ddr4_m_axi_awlen),
        .c0_ddr4_s_axi_awsize     (ddr4_m_axi_awsize),
        .c0_ddr4_s_axi_awburst    (ddr4_m_axi_awburst),
        .c0_ddr4_s_axi_awlock     (ddr4_m_axi_awlock),
        .c0_ddr4_s_axi_awcache    (ddr4_m_axi_awcache),
        .c0_ddr4_s_axi_awprot     (ddr4_m_axi_awprot),
        .c0_ddr4_s_axi_awqos      (ddr4_m_axi_awqos),
        .c0_ddr4_s_axi_awvalid    (ddr4_m_axi_awvalid),
        .c0_ddr4_s_axi_awready    (ddr4_m_axi_awready),
        .c0_ddr4_s_axi_wdata      (ddr4_m_axi_wdata),
        .c0_ddr4_s_axi_wstrb      (ddr4_m_axi_wstrb),
        .c0_ddr4_s_axi_wlast      (ddr4_m_axi_wlast),
        .c0_ddr4_s_axi_wvalid     (ddr4_m_axi_wvalid),
        .c0_ddr4_s_axi_wready     (ddr4_m_axi_wready),
        .c0_ddr4_s_axi_bready     (ddr4_m_axi_bready),
        .c0_ddr4_s_axi_bid        (ddr4_m_axi_bid),
        .c0_ddr4_s_axi_bresp      (ddr4_m_axi_bresp),
        .c0_ddr4_s_axi_bvalid     (ddr4_m_axi_bvalid),
        .c0_ddr4_s_axi_arid       (ddr4_m_axi_arid),
        .c0_ddr4_s_axi_araddr     (ddr4_m_axi_araddr),
        .c0_ddr4_s_axi_arlen      (ddr4_m_axi_arlen),
        .c0_ddr4_s_axi_arsize     (ddr4_m_axi_arsize),
        .c0_ddr4_s_axi_arburst    (ddr4_m_axi_arburst),
        .c0_ddr4_s_axi_arlock     (ddr4_m_axi_arlock),
        .c0_ddr4_s_axi_arcache    (ddr4_m_axi_arcache),
        .c0_ddr4_s_axi_arprot     (ddr4_m_axi_arprot),
        .c0_ddr4_s_axi_arqos      (ddr4_m_axi_arqos),
        .c0_ddr4_s_axi_arvalid    (ddr4_m_axi_arvalid),
        .c0_ddr4_s_axi_arready    (ddr4_m_axi_arready),
        .c0_ddr4_s_axi_rready     (ddr4_m_axi_rready),
        .c0_ddr4_s_axi_rlast      (ddr4_m_axi_rlast),
        .c0_ddr4_s_axi_rvalid     (ddr4_m_axi_rvalid),
        .c0_ddr4_s_axi_rresp      (ddr4_m_axi_rresp),
        .c0_ddr4_s_axi_rid        (ddr4_m_axi_rid),
        .c0_ddr4_s_axi_rdata      (ddr4_m_axi_rdata)
    );


    ddr4_module_sim ddr4_module_sim_inst (
    .c0_ddr4_adr          (ddr4_intf_c0_ddr4_adr),
    .c0_ddr4_ba           (ddr4_intf_c0_ddr4_ba),
    .c0_ddr4_cke          (ddr4_intf_c0_ddr4_cke),
    .c0_ddr4_cs_n         (ddr4_intf_c0_ddr4_cs_n),
    .c0_ddr4_dm_dbi_n     (ddr4_intf_c0_ddr4_dm_dbi_n),
    .c0_ddr4_dq           (ddr4_intf_c0_ddr4_dq),
    .c0_ddr4_dqs_c        (ddr4_intf_c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t        (ddr4_intf_c0_ddr4_dqs_t),
    .c0_ddr4_odt          (ddr4_intf_c0_ddr4_odt),
    .c0_ddr4_bg           (ddr4_intf_c0_ddr4_bg),
    .c0_ddr4_reset_n      (ddr4_intf_c0_ddr4_reset_n),
    .c0_ddr4_act_n        (ddr4_intf_c0_ddr4_act_n),
    .c0_ddr4_ck_c         (ddr4_intf_c0_ddr4_ck_c),
    .c0_ddr4_ck_t         (ddr4_intf_c0_ddr4_ck_t)
    );


    
    // ------------------------------------------------------------------
    // DDR4 Reest & Clock
    // ------------------------------------------------------------------
    initial ddr4_intf_c0_sys_clk_p = 1'b1;
    always #(DDR_REF_PERIOD_NS/2.0) ddr4_intf_c0_sys_clk_p = ~ddr4_intf_c0_sys_clk_p;
    assign ddr4_intf_c0_sys_clk_n = ~ddr4_intf_c0_sys_clk_p;
    
    initial begin
        ddr4_intf_c0_ddr4_aresetn = 0;
        repeat (100) @(posedge ddr4_intf_c0_sys_clk_p);
        ddr4_intf_c0_ddr4_aresetn = 1;
    end

    assign ddr4_intf_sys_rst = 0;


    // ------------------------------------------------------------------
    // AXI4 Reset & Clock
    // ------------------------------------------------------------------
    assign axis_resetn = ~ddr4_intf_c0_ddr4_ui_clk_sync_rst;
    assign axis_clk    = ddr4_intf_c0_ddr4_ui_clk;
    


    // Testbench initial block
    initial begin
        
        assign frame_intrlvd_tready = 1'b1;

        
        // Test AXI Stream interface
        test_axi_stream();

        
        
        // End simulation
//      #1000 $finish;
    end
    
    // Test AXI Stream interface
    task test_axi_stream;
        integer i;
        begin
            // Drive valid signals
            frame_tvalid = 1'b0;
            frame_tuser = 16'h0000;
            frame_tdata = 32'h00000000;
            frame_tkeep = 4'b1111;
            frame_tlast = 1'b0;
            
            // Wait for reset to be asserted
            @(posedge axis_clk);
            
            // Send 10-word packet with counter
            frame_tvalid = 1'b1;
            for (i = 0; i < 1024; i = i + 1) begin
                frame_tdata = 32'h00000000 + i;
                frame_tuser = 16'hABCD;
                if (i == 999999) begin
                    frame_tlast = 1'b1;
                end else begin
                    frame_tlast = 1'b0;
                end
                
                @(posedge axis_clk);
                while (!frame_tready) @(posedge axis_clk);
            end
            
            frame_tvalid = 1'b0;
        end
    endtask

integer outfile_2;

    // Open the file at the start of simulation
    initial begin
        outfile_2 = $fopen("/home/satanya/Documents/Reading Materials/documents_20260109/ddr_tb_example/src/rtl/mod_intrlv_output.txt", "w");
        if (outfile_2 == 0) begin
            $display("ERROR: Could not open file for writing!");
//            $finish;
        end
    end

    // ------------------------------------------------------------------
    // Monitor frame_deintrlvd signals and write to file
    // ------------------------------------------------------------------
    always @(posedge axis_clk) begin
        if (!axis_resetn) begin
            // nothing
        end else begin
            if (frame_intrlvd_tvalid && frame_intrlvd_tready) begin
                // Log exactly one transfer
                $fdisplay(outfile_2, "%h", frame_intrlvd_tdata);
                $fflush(outfile_2);

                if (frame_intrlvd_tlast) begin
                    $display("Packet complete at time %0t ns, last word received: 0x%h",
                             $time, frame_intrlvd_tdata);
                    $fclose(outfile_2);
//                    $finish;
                end
            end
        end
    end



    
//  // Monitor signals for verification
//  initial begin
//      $monitor("Time=%0t: frame_tvalid=%b, frame_tready=%b, frame_tdata=0x%h, frame_intrlvd_tvalid=%b, frame_intrlvd_tready=%b, frame_intrlvd_tdata=0x%h",
//               $time, frame_tvalid, frame_tready, frame_tdata, 
//               frame_intrlvd_tvalid, frame_intrlvd_tready, frame_intrlvd_tdata);
//  end

endmodule
