`timescale 1ns/1ps

module top_loop_back_tb;

    // Mod Interleaver Signals

    // /AXI Clock and reset signals
    wire            axis_resetn;
    wire            axis_clk;


    // AXI Stream Slave Interface (frame)
    reg             mod_frame_tvalid;
    wire            mod_frame_tready;
    reg [15:0]      mod_frame_tuser;
    reg [31:0]      mod_frame_tdata;
    reg [3:0]       mod_frame_tkeep;
    reg             mod_frame_tlast;

    reg             demod_frame_tvalid;
    wire            demod_frame_tready;
    reg [15:0]      demod_frame_tuser;
    reg [31:0]      demod_frame_tdata;
    reg [3:0]       demod_frame_tkeep;
    reg             demod_frame_tlast;


    // Interleaver stream observed hierarchically for simulation debug only
    wire            frame_intrlvd_tvalid;
    wire            frame_intrlvd_tready;
    wire [15:0]     frame_intrlvd_tuser;
    wire [31:0]     frame_intrlvd_tdata;
    wire [3:0]      frame_intrlvd_tkeep;
    wire            frame_intrlvd_tlast;

    wire            frame_deintrlvd_tvalid;
    reg             frame_deintrlvd_tready;
    wire [15:0]     frame_deintrlvd_tuser;
    wire [31:0]     frame_deintrlvd_tdata;
    wire [3:0]      frame_deintrlvd_tkeep;
    wire            frame_deintrlvd_tlast;

    // AXI4 Master Interface (DDR4)
    wire [3:0]      M_AXI_AWID;
    wire [28:0]     M_AXI_AWADDR;
    wire [7:0]      M_AXI_AWLEN;
    wire [2:0]      M_AXI_AWSIZE;
    wire [1:0]      M_AXI_AWBURST;
    wire            M_AXI_AWLOCK;
    wire [3:0]      M_AXI_AWCACHE;
    wire [2:0]      M_AXI_AWPROT;
    wire [3:0]      M_AXI_AWQOS;
    wire            M_AXI_AWVALID;
    wire            M_AXI_AWREADY;

    wire [127:0]    M_AXI_WDATA;
    wire [15:0]     M_AXI_WSTRB;
    wire            M_AXI_WLAST;
    wire            M_AXI_WVALID;
    wire            M_AXI_WREADY;

    wire [3:0]      M_AXI_BID;
    wire [1:0]      M_AXI_BRESP;
    wire            M_AXI_BVALID;
    wire            M_AXI_BREADY;

    wire [3:0]      M_AXI_ARID;
    wire [28:0]     M_AXI_ARADDR;
    wire [7:0]      M_AXI_ARLEN;
    wire [2:0]      M_AXI_ARSIZE;
    wire [1:0]      M_AXI_ARBURST;
    wire            M_AXI_ARLOCK;
    wire [3:0]      M_AXI_ARCACHE;
    wire [2:0]      M_AXI_ARPROT;
    wire [3:0]      M_AXI_ARQOS;
    wire            M_AXI_ARVALID;
    wire            M_AXI_ARREADY;

    wire [3:0]      M_AXI_RID;
    wire [127:0]    M_AXI_RDATA;
    wire [1:0]      M_AXI_RRESP;
    wire            M_AXI_RLAST;
    wire            M_AXI_RVALID;
    wire            M_AXI_RREADY;


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



    localparam real CLK_FREQ_HZ   = 100_000_000.0; // 100 MHz
    localparam real CLK_PERIOD_NS = 1e9 / CLK_FREQ_HZ;

    localparam real DDR_REF_FREQ_HZ   = 75_000_000.0; // 75 MHz
    localparam real DDR_REF_PERIOD_NS = 1e9 / DDR_REF_FREQ_HZ;
    localparam int  NUM_INPUT_WORDS   = 128;
    localparam int  RX_WORDS_PER_TX   = 16;
    localparam int  EXPECTED_RX_WORDS = NUM_INPUT_WORDS * RX_WORDS_PER_TX;

    reg [31:0] tx_words [0:NUM_INPUT_WORDS - 1];
    integer    tx_count;
    integer    intrlv_count;
    integer    rx_count;
    integer    error_count;

    function automatic [15:0] llr16_from_bit(input bit bit_value);
        begin
            llr16_from_bit = bit_value ? 16'h7FFF : 16'h8001;
        end
    endfunction

    function automatic [31:0] expected_rx_word(input [31:0] source_word, input integer pair_idx);
        begin
            expected_rx_word = {
            llr16_from_bit(source_word[pair_idx * 2 + 1]),
            llr16_from_bit(source_word[pair_idx * 2])
            };
        end
    endfunction


    // Instantiate DUT top
    top_loop_back dut (
        .axis_resetn            (axis_resetn),
        .axis_clk               (axis_clk),

        // MOD input stream
        .mod_frame_tvalid (mod_frame_tvalid),
        .mod_frame_tready (mod_frame_tready),
        .mod_frame_tuser  (mod_frame_tuser),
        .mod_frame_tdata  (mod_frame_tdata),
        .mod_frame_tkeep  (mod_frame_tkeep),
        .mod_frame_tlast  (mod_frame_tlast),

        // // DEMOD input stream
        // .demod_frame_tvalid (demod_frame_tvalid),
        // .demod_frame_tready (demod_frame_tready),
        // .demod_frame_tuser  (demod_frame_tuser),
        // .demod_frame_tdata  (demod_frame_tdata),
        // .demod_frame_tkeep  (demod_frame_tkeep),
        // .demod_frame_tlast  (demod_frame_tlast),

        // Deintrlv output
        .frame_deintrlvd_tvalid (frame_deintrlvd_tvalid),
        .frame_deintrlvd_tready (frame_deintrlvd_tready),
        .frame_deintrlvd_tuser  (frame_deintrlvd_tuser),
        .frame_deintrlvd_tdata  (frame_deintrlvd_tdata),
        .frame_deintrlvd_tkeep  (frame_deintrlvd_tkeep),
        .frame_deintrlvd_tlast  (frame_deintrlvd_tlast),

        // AXI Master
        .M_AXI_AWID    (M_AXI_AWID),
        .M_AXI_AWADDR  (M_AXI_AWADDR),
        .M_AXI_AWLEN   (M_AXI_AWLEN),
        .M_AXI_AWSIZE  (M_AXI_AWSIZE),
        .M_AXI_AWBURST (M_AXI_AWBURST),
        .M_AXI_AWLOCK  (M_AXI_AWLOCK),
        .M_AXI_AWCACHE (M_AXI_AWCACHE),
        .M_AXI_AWPROT  (M_AXI_AWPROT),
        .M_AXI_AWQOS   (M_AXI_AWQOS),
        .M_AXI_AWVALID (M_AXI_AWVALID),
        .M_AXI_AWREADY (M_AXI_AWREADY),

        .M_AXI_WDATA   (M_AXI_WDATA),
        .M_AXI_WSTRB   (M_AXI_WSTRB),
        .M_AXI_WLAST   (M_AXI_WLAST),
        .M_AXI_WVALID  (M_AXI_WVALID),
        .M_AXI_WREADY  (M_AXI_WREADY),

        .M_AXI_BID     (M_AXI_BID),
        .M_AXI_BRESP   (M_AXI_BRESP),
        .M_AXI_BVALID  (M_AXI_BVALID),
        .M_AXI_BREADY  (M_AXI_BREADY),

        .M_AXI_ARID    (M_AXI_ARID),
        .M_AXI_ARADDR  (M_AXI_ARADDR),
        .M_AXI_ARLEN   (M_AXI_ARLEN),
        .M_AXI_ARSIZE  (M_AXI_ARSIZE),
        .M_AXI_ARBURST (M_AXI_ARBURST),
        .M_AXI_ARLOCK  (M_AXI_ARLOCK),
        .M_AXI_ARCACHE (M_AXI_ARCACHE),
        .M_AXI_ARPROT  (M_AXI_ARPROT),
        .M_AXI_ARQOS   (M_AXI_ARQOS),
        .M_AXI_ARVALID (M_AXI_ARVALID),
        .M_AXI_ARREADY (M_AXI_ARREADY),

        .M_AXI_RID     (M_AXI_RID),
        .M_AXI_RDATA   (M_AXI_RDATA),
        .M_AXI_RRESP   (M_AXI_RRESP),
        .M_AXI_RLAST   (M_AXI_RLAST),
        .M_AXI_RVALID  (M_AXI_RVALID),
        .M_AXI_RREADY  (M_AXI_RREADY)
    );

    // assign frame_intrlvd_tready = dut.w_frame_intrlvd_tready;
    // assign frame_intrlvd_tvalid = dut.w_frame_intrlvd_tvalid;
    // assign frame_intrlvd_tuser  = dut.w_frame_intrlvd_tuser;
    // assign frame_intrlvd_tdata  = dut.w_frame_intrlvd_tdata;
    // assign frame_intrlvd_tkeep  = dut.w_frame_intrlvd_tkeep;
    // assign frame_intrlvd_tlast  = dut.w_frame_intrlvd_tlast;


    // Instantiate DDR4 Interface
    ddr4_intf ddr4_intf_inst (
        // System Reset
        .sys_rst                  (ddr4_intf_sys_rst),

        // Clock & Reset Interface
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

        // AXI Slave Interface (Connected to top_loop_back module)
        .c0_ddr4_s_axi_awid       (M_AXI_AWID),
        .c0_ddr4_s_axi_awaddr     (M_AXI_AWADDR),
        .c0_ddr4_s_axi_awlen      (M_AXI_AWLEN),
        .c0_ddr4_s_axi_awsize     (M_AXI_AWSIZE),
        .c0_ddr4_s_axi_awburst    (M_AXI_AWBURST),
        .c0_ddr4_s_axi_awlock     (M_AXI_AWLOCK),
        .c0_ddr4_s_axi_awcache    (M_AXI_AWCACHE),
        .c0_ddr4_s_axi_awprot     (M_AXI_AWPROT),
        .c0_ddr4_s_axi_awqos      (M_AXI_AWQOS),
        .c0_ddr4_s_axi_awvalid    (M_AXI_AWVALID),
        .c0_ddr4_s_axi_awready    (M_AXI_AWREADY),

        .c0_ddr4_s_axi_wdata      (M_AXI_WDATA),
        .c0_ddr4_s_axi_wstrb      (M_AXI_WSTRB),
        .c0_ddr4_s_axi_wlast      (M_AXI_WLAST),
        .c0_ddr4_s_axi_wvalid     (M_AXI_WVALID),
        .c0_ddr4_s_axi_wready     (M_AXI_WREADY),

        .c0_ddr4_s_axi_bready     (M_AXI_BREADY),
        .c0_ddr4_s_axi_bid        (M_AXI_BID),
        .c0_ddr4_s_axi_bresp      (M_AXI_BRESP),
        .c0_ddr4_s_axi_bvalid     (M_AXI_BVALID),

        .c0_ddr4_s_axi_arid       (M_AXI_ARID),
        .c0_ddr4_s_axi_araddr     (M_AXI_ARADDR),
        .c0_ddr4_s_axi_arlen      (M_AXI_ARLEN),
        .c0_ddr4_s_axi_arsize     (M_AXI_ARSIZE),
        .c0_ddr4_s_axi_arburst    (M_AXI_ARBURST),
        .c0_ddr4_s_axi_arlock     (M_AXI_ARLOCK),
        .c0_ddr4_s_axi_arcache    (M_AXI_ARCACHE),
        .c0_ddr4_s_axi_arprot     (M_AXI_ARPROT),
        .c0_ddr4_s_axi_arqos      (M_AXI_ARQOS),
        .c0_ddr4_s_axi_arvalid    (M_AXI_ARVALID),
        .c0_ddr4_s_axi_arready    (M_AXI_ARREADY),

        .c0_ddr4_s_axi_rready     (M_AXI_RREADY),
        .c0_ddr4_s_axi_rlast      (M_AXI_RLAST),
        .c0_ddr4_s_axi_rvalid     (M_AXI_RVALID),
        .c0_ddr4_s_axi_rresp      (M_AXI_RRESP),
        .c0_ddr4_s_axi_rid        (M_AXI_RID),
        .c0_ddr4_s_axi_rdata      (M_AXI_RDATA)
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
        repeat (300) @(posedge ddr4_intf_c0_sys_clk_p);
        ddr4_intf_c0_ddr4_aresetn = 1;
    end

    assign ddr4_intf_sys_rst = 0;


    // ------------------------------------------------------------------
    // AXI4 Reset & Clock
    // ------------------------------------------------------------------
    assign axis_resetn = ~ddr4_intf_c0_ddr4_ui_clk_sync_rst;
    assign axis_clk    = ddr4_intf_c0_ddr4_ui_clk;




    reg test_done;

    initial begin
        test_done = 1'b0;
        tx_count = 0;
        intrlv_count = 0;
        rx_count = 0;
        error_count = 0;

        mod_frame_tvalid = 0;
        mod_frame_tuser  = 16'h0000;
        mod_frame_tdata  = 32'h00000000;
        mod_frame_tkeep  = 4'b1111;
        mod_frame_tlast  = 0;

        frame_deintrlvd_tready = 1'b1;

        demod_frame_tvalid = 0;
        demod_frame_tuser  = 0;
        demod_frame_tdata  = 0;
        demod_frame_tkeep  = 4'hF;
        demod_frame_tlast  = 0;

        fork
            test_axi_stream();
        join

        wait(test_done === 1'b1);
        repeat (10) @(posedge axis_clk);

        if (error_count == 0 && rx_count == EXPECTED_RX_WORDS) begin
            $display("PASS: loopback produced %0d checked RX words with no mismatches.", rx_count);
        end else begin
            $display("FAIL: rx_count=%0d expected=%0d error_count=%0d", rx_count, EXPECTED_RX_WORDS, error_count);
        end
        $finish;
    end

    task test_axi_stream;
        integer i;
        begin

            // Wait until DDR controller is ready
            wait(ddr4_intf_c0_init_calib_complete);

            // Drive valid signals
            mod_frame_tvalid = 1'b0;
            mod_frame_tuser = 16'h0000;
            mod_frame_tdata = 32'h00000000;
            mod_frame_tkeep = 4'b1111;
            mod_frame_tlast = 1'b0;


            // Wait for reset to be asserted
            @(posedge axis_clk);

            repeat (20) @(posedge axis_clk); // <-- wait 20 clock cycles

            // Send 10-word packet with counter
            mod_frame_tvalid = 1'b1;
            for (i = 0; i < NUM_INPUT_WORDS; i = i + 1) begin
                tx_words[i] = 32'h00000000 + i;
                mod_frame_tdata = tx_words[i];
                mod_frame_tuser = 16'hABCD;
                if (i == NUM_INPUT_WORDS - 1) begin
                    mod_frame_tlast = 1'b1;
                end else begin
                    mod_frame_tlast = 1'b0;
                end

                @(posedge axis_clk);
                while (!mod_frame_tready) @(posedge axis_clk);
            end

            mod_frame_tvalid = 1'b0;
            mod_frame_tlast = 1'b0;

        end
    endtask



    integer outfile;
    integer intrlv_outfile;


    integer aw_count;
    integer wbeat_count;
    integer wlast_count;

    always @(posedge axis_clk) begin
        if (!axis_resetn) begin
            aw_count    <= 0;
            wbeat_count <= 0;
            wlast_count <= 0;
        end else begin
            if (M_AXI_AWVALID && M_AXI_AWREADY) begin
                aw_count <= aw_count + 1;
                $display("AW[%0d] addr=%h len=%0d time=%0t",
                    aw_count, M_AXI_AWADDR, M_AXI_AWLEN, $time);
            end

            if (M_AXI_WVALID && M_AXI_WREADY) begin
                wbeat_count <= wbeat_count + 1;

                if (M_AXI_WLAST) begin
                    wlast_count <= wlast_count + 1;
                    $display("WLAST[%0d] beat=%0d time=%0t",
                        wlast_count, wbeat_count + 1, $time);
                end
            end
        end
    end

    // Open the file at the start of simulation
    initial begin
        outfile = $fopen("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_deintrlv_output.txt", "w");
        if (outfile == 0) begin
            $display("ERROR: Could not open file for writing!");
        end

        intrlv_outfile = $fopen("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/mod_interlv_output.txt", "w");
        if (intrlv_outfile == 0) begin
            $display("ERROR: Could not open interleaver output file for writing!");
        end
    end



    // always @(posedge axis_clk) begin
    //     if (!axis_resetn) begin
    //         // nothing
    //     end else begin
    //         if (frame_intrlvd_tvalid && frame_intrlvd_tready) begin
    //             // Log exactly one transfer
    //             $fdisplay(intrlv_outfile, "%h", frame_intrlvd_tdata);
    //             $fflush(intrlv_outfile);

    //             if (frame_intrlvd_tlast) begin
    //                 $display("Packet complete at time %0t ns, last word received: 0x%h",
    //                     $time, frame_intrlvd_tdata);
    //                 $fclose(intrlv_outfile);
    //                 //                    $finish;
    //             end
    //         end
    //     end
    // end


    // ------------------------------------------------------------------
    // Monitor frame_deintrlvd signals and write to file
    // ------------------------------------------------------------------
    always @(posedge axis_clk) begin
        if (!axis_resetn) begin
            // nothing
        end else begin
            if (frame_deintrlvd_tvalid && frame_deintrlvd_tready) begin
                integer rx_word_idx;
                reg [31:0] expected_word;

                rx_word_idx = rx_count;
                expected_word = expected_rx_word(tx_words[rx_word_idx / RX_WORDS_PER_TX], rx_word_idx % RX_WORDS_PER_TX);
                $fdisplay(outfile, "%h", frame_deintrlvd_tdata);
                $fflush(outfile);
                $display("RX[%0d]: %h", rx_word_idx, frame_deintrlvd_tdata);

                if (frame_deintrlvd_tdata !== expected_word) begin
                    error_count = error_count + 1;
                    $display("RX mismatch at word %0d: got=%h expected=%h",
                        rx_word_idx,
                        frame_deintrlvd_tdata,
                        expected_word);
                end

                if ((rx_word_idx == EXPECTED_RX_WORDS - 1) && !frame_deintrlvd_tlast) begin
                    error_count = error_count + 1;
                    $display("RX mismatch: final word arrived without TLAST.");
                end

                if ((rx_word_idx != EXPECTED_RX_WORDS - 1) && frame_deintrlvd_tlast) begin
                    error_count = error_count + 1;
                    $display("RX mismatch: unexpected TLAST at word %0d.", rx_word_idx);
                end

                rx_count = rx_count + 1;

                if (frame_deintrlvd_tlast) begin
                    $display("Packet complete at time %0t ns, last word received: 0x%h",
                        $time, frame_deintrlvd_tdata);
                    $fclose(outfile);
                    $fclose(intrlv_outfile);
                    test_done <= 1'b1;
                end
            end
        end
    end

    // always @(posedge axis_clk) begin
    //     if (mod_frame_tvalid && mod_frame_tready) begin
    //         tx_count = tx_count + 1;
    //         $display("TX[%0d]: %h", tx_count - 1, mod_frame_tdata);
    //     end
    // end

    // always @(posedge axis_clk) begin
    //     if (frame_intrlvd_tvalid && frame_intrlvd_tready) begin
    //         intrlv_count = intrlv_count + 1;
    //         $fdisplay(intrlv_outfile, "%h %h %b", frame_intrlvd_tdata, frame_intrlvd_tkeep, frame_intrlvd_tlast);
    //         $fflush(intrlv_outfile);
    //         $display("INT[%0d]: data=%h keep=%h last=%b", intrlv_count - 1, frame_intrlvd_tdata, frame_intrlvd_tkeep, frame_intrlvd_tlast);
    //     end
    // end

endmodule
