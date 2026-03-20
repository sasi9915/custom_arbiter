library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_custom_int_2slot is
    generic(
        G_ADDR_WIDTH     : positive := 29;
        G_DATA_WIDTH     : positive := 128;
        G_S_ID_WIDTH     : positive := 1;
        G_M_ID_WIDTH     : positive := 4;
        G_CMD_FIFO_DEPTH : positive := 16
    );
    port(
        S00_AXI_ACLK    : in  std_logic;
        S00_AXI_ARESETN : in  std_logic;
        S00_AXI_AWID    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S00_AXI_AWADDR  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        S00_AXI_AWLEN   : in  std_logic_vector(7 downto 0);
        S00_AXI_AWSIZE  : in  std_logic_vector(2 downto 0);
        S00_AXI_AWBURST : in  std_logic_vector(1 downto 0);
        S00_AXI_AWLOCK  : in  std_logic;
        S00_AXI_AWCACHE : in  std_logic_vector(3 downto 0);
        S00_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
        S00_AXI_AWQOS   : in  std_logic_vector(3 downto 0);
        S00_AXI_AWVALID : in  std_logic;
        S00_AXI_AWREADY : out std_logic;
        S00_AXI_WDATA   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        S00_AXI_WSTRB   : in  std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        S00_AXI_WLAST   : in  std_logic;
        S00_AXI_WVALID  : in  std_logic;
        S00_AXI_WREADY  : out std_logic;
        S00_AXI_BID     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S00_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S00_AXI_BVALID  : out std_logic;
        S00_AXI_BREADY  : in  std_logic;
        S00_AXI_ARID    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S00_AXI_ARADDR  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        S00_AXI_ARLEN   : in  std_logic_vector(7 downto 0);
        S00_AXI_ARSIZE  : in  std_logic_vector(2 downto 0);
        S00_AXI_ARBURST : in  std_logic_vector(1 downto 0);
        S00_AXI_ARLOCK  : in  std_logic;
        S00_AXI_ARCACHE : in  std_logic_vector(3 downto 0);
        S00_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
        S00_AXI_ARQOS   : in  std_logic_vector(3 downto 0);
        S00_AXI_ARVALID : in  std_logic;
        S00_AXI_ARREADY : out std_logic;
        S00_AXI_RID     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S00_AXI_RDATA   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        S00_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S00_AXI_RLAST   : out std_logic;
        S00_AXI_RVALID  : out std_logic;
        S00_AXI_RREADY  : in  std_logic;
        S01_AXI_AWID    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S01_AXI_AWADDR  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        S01_AXI_AWLEN   : in  std_logic_vector(7 downto 0);
        S01_AXI_AWSIZE  : in  std_logic_vector(2 downto 0);
        S01_AXI_AWBURST : in  std_logic_vector(1 downto 0);
        S01_AXI_AWLOCK  : in  std_logic;
        S01_AXI_AWCACHE : in  std_logic_vector(3 downto 0);
        S01_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
        S01_AXI_AWQOS   : in  std_logic_vector(3 downto 0);
        S01_AXI_AWVALID : in  std_logic;
        S01_AXI_AWREADY : out std_logic;
        S01_AXI_WDATA   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        S01_AXI_WSTRB   : in  std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        S01_AXI_WLAST   : in  std_logic;
        S01_AXI_WVALID  : in  std_logic;
        S01_AXI_WREADY  : out std_logic;
        S01_AXI_BID     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S01_AXI_BRESP   : out std_logic_vector(1 downto 0);
        S01_AXI_BVALID  : out std_logic;
        S01_AXI_BREADY  : in  std_logic;
        S01_AXI_ARID    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S01_AXI_ARADDR  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        S01_AXI_ARLEN   : in  std_logic_vector(7 downto 0);
        S01_AXI_ARSIZE  : in  std_logic_vector(2 downto 0);
        S01_AXI_ARBURST : in  std_logic_vector(1 downto 0);
        S01_AXI_ARLOCK  : in  std_logic;
        S01_AXI_ARCACHE : in  std_logic_vector(3 downto 0);
        S01_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
        S01_AXI_ARQOS   : in  std_logic_vector(3 downto 0);
        S01_AXI_ARVALID : in  std_logic;
        S01_AXI_ARREADY : out std_logic;
        S01_AXI_RID     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        S01_AXI_RDATA   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        S01_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S01_AXI_RLAST   : out std_logic;
        S01_AXI_RVALID  : out std_logic;
        S01_AXI_RREADY  : in  std_logic;
        M_AXI_AWID      : out std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        M_AXI_AWADDR    : out std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        M_AXI_AWLEN     : out std_logic_vector(7 downto 0);
        M_AXI_AWSIZE    : out std_logic_vector(2 downto 0);
        M_AXI_AWBURST   : out std_logic_vector(1 downto 0);
        M_AXI_AWLOCK    : out std_logic;
        M_AXI_AWCACHE   : out std_logic_vector(3 downto 0);
        M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
        M_AXI_AWQOS     : out std_logic_vector(3 downto 0);
        M_AXI_AWVALID   : out std_logic;
        M_AXI_AWREADY   : in  std_logic;
        M_AXI_WDATA     : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        M_AXI_WSTRB     : out std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        M_AXI_WLAST     : out std_logic;
        M_AXI_WVALID    : out std_logic;
        M_AXI_WREADY    : in  std_logic;
        M_AXI_BID       : in  std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        M_AXI_BRESP     : in  std_logic_vector(1 downto 0);
        M_AXI_BVALID    : in  std_logic;
        M_AXI_BREADY    : out std_logic;
        M_AXI_ARID      : out std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        M_AXI_ARADDR    : out std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        M_AXI_ARLEN     : out std_logic_vector(7 downto 0);
        M_AXI_ARSIZE    : out std_logic_vector(2 downto 0);
        M_AXI_ARBURST   : out std_logic_vector(1 downto 0);
        M_AXI_ARLOCK    : out std_logic;
        M_AXI_ARCACHE   : out std_logic_vector(3 downto 0);
        M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
        M_AXI_ARQOS     : out std_logic_vector(3 downto 0);
        M_AXI_ARVALID   : out std_logic;
        M_AXI_ARREADY   : in  std_logic;
        M_AXI_RID       : in  std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        M_AXI_RDATA     : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        M_AXI_RRESP     : in  std_logic_vector(1 downto 0);
        M_AXI_RLAST     : in  std_logic;
        M_AXI_RVALID    : in  std_logic;
        M_AXI_RREADY    : out std_logic
    );
end entity axi_custom_int_2slot;

architecture rtl of axi_custom_int_2slot is

    component xpm_fifo_sync_wrap is
        generic(
            g_TYPE                   : string  := "block";
            g_DATA_WIDTH             : natural := 10;
            g_DEPTH                  : natural := 2048;
            g_FWFT_MODE_ENA          : boolean := true;
            g_ALMOST_FULL_THRESHOLD  : integer := 1920;
            g_ALMOST_EMPTY_THRESHOLD : integer := 128
        );
        port(
            i_resetn       : in  std_logic;
            i_clk          : in  std_logic;
            i_wrreq        : in  std_logic;
            i_data         : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            i_rdreq        : in  std_logic;
            o_q_val        : out std_logic;
            o_q            : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            o_usedw        : out std_logic_vector(15 downto 0);
            o_full         : out std_logic;
            o_empty        : out std_logic;
            o_almost_full  : out std_logic;
            o_almost_empty : out std_logic
        );
    end component;

    constant C_QOS_LSB   : natural := 0;
    constant C_QOS_MSB   : natural := C_QOS_LSB + 4 - 1;
    constant C_PROT_LSB  : natural := C_QOS_MSB + 1;
    constant C_PROT_MSB  : natural := C_PROT_LSB + 3 - 1;
    constant C_CACHE_LSB : natural := C_PROT_MSB + 1;
    constant C_CACHE_MSB : natural := C_CACHE_LSB + 4 - 1;
    constant C_LOCK_LSB  : natural := C_CACHE_MSB + 1;
    constant C_LOCK_MSB  : natural := C_LOCK_LSB;
    constant C_BURST_LSB : natural := C_LOCK_MSB + 1;
    constant C_BURST_MSB : natural := C_BURST_LSB + 2 - 1;
    constant C_SIZE_LSB  : natural := C_BURST_MSB + 1;
    constant C_SIZE_MSB  : natural := C_SIZE_LSB + 3 - 1;
    constant C_LEN_LSB   : natural := C_SIZE_MSB + 1;
    constant C_LEN_MSB   : natural := C_LEN_LSB + 8 - 1;
    constant C_ADDR_LSB  : natural := C_LEN_MSB + 1;
    constant C_ADDR_MSB  : natural := C_ADDR_LSB + G_ADDR_WIDTH - 1;
    constant C_ID_LSB    : natural := C_ADDR_MSB + 1;
    constant C_ID_MSB    : natural := C_ID_LSB + G_S_ID_WIDTH - 1;
    constant C_CMD_W     : natural := C_ID_MSB + 1;

    type wr_state_t is (WR_IDLE, WR_SEND_AW, WR_SEND_W, WR_WAIT_B);
    type rd_state_t is (RD_IDLE, RD_SEND_AR);

    signal r_wr_state : wr_state_t := WR_IDLE;
    signal r_rd_state : rd_state_t := RD_IDLE;

    -- round robin select signals for issuing from two slots
    signal r_wr_rr_sel   : std_logic := '0';
    signal r_rd_rr_sel   : std_logic := '0';
    signal r_wr_slot_sel : std_logic := '0';
    signal r_rd_slot_sel : std_logic := '0';

    signal r_wr_cmd_reg : std_logic_vector(C_CMD_W - 1 downto 0) := (others => '0');
    signal r_rd_cmd_reg : std_logic_vector(C_CMD_W - 1 downto 0) := (others => '0');

    signal w_aw0_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_aw1_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_aw0_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_aw1_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_aw0_fifo_wrreq : std_logic;
    signal w_aw1_fifo_wrreq : std_logic;
    signal r_aw0_fifo_rdreq : std_logic := '0';
    signal r_aw1_fifo_rdreq : std_logic := '0';
    signal w_aw0_fifo_full  : std_logic;
    signal w_aw1_fifo_full  : std_logic;
    signal w_aw0_fifo_empty : std_logic;
    signal w_aw1_fifo_empty : std_logic;

    signal w_ar0_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_ar1_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_ar0_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_ar1_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal w_ar0_fifo_wrreq : std_logic;
    signal w_ar1_fifo_wrreq : std_logic;
    signal r_ar0_fifo_rdreq : std_logic := '0';
    signal r_ar1_fifo_rdreq : std_logic := '0';
    signal w_ar0_fifo_full  : std_logic;
    signal w_ar1_fifo_full  : std_logic;
    signal w_ar0_fifo_empty : std_logic;
    signal w_ar1_fifo_empty : std_logic;

    signal w_bid_slot : std_logic;
    signal w_rid_slot : std_logic;

    signal w_bready_sel : std_logic;

    --interenal signals for the fifo_full assertions
    signal w_s0_awready_i : std_logic;
    signal w_s1_awready_i : std_logic;
    signal w_s0_arready_i : std_logic;
    signal w_s1_arready_i : std_logic;

begin

    assert G_DATA_WIDTH mod 8 = 0
    report "G_DATA_WIDTH must be divisible by 8."
    severity failure;

    assert G_CMD_FIFO_DEPTH > 1
    report "G_CMD_FIFO_DEPTH must be > 1."
    severity failure;

    assert G_CMD_FIFO_DEPTH >= 10
    report "G_CMD_FIFO_DEPTH must be >= 10 for configured XPM programmable thresholds."
    severity failure;

    assert G_M_ID_WIDTH >= (G_S_ID_WIDTH + 1)
    report "G_M_ID_WIDTH must be >= G_S_ID_WIDTH + 1 for 2-slot remap."
    severity failure;

    -- Pack incoming AW/AR metadata (ID + attributes) before enqueue.
    w_aw0_fifo_din <= S00_AXI_AWID & S00_AXI_AWADDR & S00_AXI_AWLEN & S00_AXI_AWSIZE & S00_AXI_AWBURST & S00_AXI_AWLOCK & S00_AXI_AWCACHE & S00_AXI_AWPROT & S00_AXI_AWQOS;
    w_aw1_fifo_din <= S01_AXI_AWID & S01_AXI_AWADDR & S01_AXI_AWLEN & S01_AXI_AWSIZE & S01_AXI_AWBURST & S01_AXI_AWLOCK & S01_AXI_AWCACHE & S01_AXI_AWPROT & S01_AXI_AWQOS;
    w_ar0_fifo_din <= S00_AXI_ARID & S00_AXI_ARADDR & S00_AXI_ARLEN & S00_AXI_ARSIZE & S00_AXI_ARBURST & S00_AXI_ARLOCK & S00_AXI_ARCACHE & S00_AXI_ARPROT & S00_AXI_ARQOS;
    w_ar1_fifo_din <= S01_AXI_ARID & S01_AXI_ARADDR & S01_AXI_ARLEN & S01_AXI_ARSIZE & S01_AXI_ARBURST & S01_AXI_ARLOCK & S01_AXI_ARCACHE & S01_AXI_ARPROT & S01_AXI_ARQOS;

    -- Instantiate AW FIFOs for each slot.

    -- Backpressure slave AW/AR ready when respective FIFO is not full.
    w_s0_awready_i <= not w_aw0_fifo_full;
    w_s1_awready_i <= not w_aw1_fifo_full;
    w_s0_arready_i <= not w_ar0_fifo_full;
    w_s1_arready_i <= not w_ar1_fifo_full;

    -- Enqueue AW/AR commands when valid and accepted by ready handshake.
    w_aw0_fifo_wrreq <= S00_AXI_AWVALID and w_s0_awready_i;
    w_aw1_fifo_wrreq <= S01_AXI_AWVALID and w_s1_awready_i;
    w_ar0_fifo_wrreq <= S00_AXI_ARVALID and w_s0_arready_i;
    w_ar1_fifo_wrreq <= S01_AXI_ARVALID and w_s1_arready_i;

    -- Drive ready signals based on FIFO full status.
    S00_AXI_AWREADY <= w_s0_awready_i;
    S01_AXI_AWREADY <= w_s1_awready_i;
    S00_AXI_ARREADY <= w_s0_arready_i;
    S01_AXI_ARREADY <= w_s1_arready_i;

    process(S00_AXI_ACLK, S00_AXI_ARESETN)
    begin
        if S00_AXI_ARESETN = '0' then
            r_wr_state       <= WR_IDLE;
            r_rd_state       <= RD_IDLE;
            r_wr_rr_sel      <= '0';
            r_rd_rr_sel      <= '0';
            r_wr_slot_sel    <= '0';
            r_rd_slot_sel    <= '0';
            r_wr_cmd_reg     <= (others => '0');
            r_rd_cmd_reg     <= (others => '0');
            r_aw0_fifo_rdreq <= '0';
            r_aw1_fifo_rdreq <= '0';
            r_ar0_fifo_rdreq <= '0';
            r_ar1_fifo_rdreq <= '0';
        elsif rising_edge(S00_AXI_ACLK) then
            r_aw0_fifo_rdreq <= '0';
            r_aw1_fifo_rdreq <= '0';
            r_ar0_fifo_rdreq <= '0';
            r_ar1_fifo_rdreq <= '0';

            case r_wr_state is
                when WR_IDLE =>
                    if (w_aw0_fifo_empty = '0') or (w_aw1_fifo_empty = '0') then
                        if (w_aw0_fifo_empty = '0') and (w_aw1_fifo_empty = '0') then
                            if r_wr_rr_sel = '0' then
                                r_wr_slot_sel    <= '0';
                                r_wr_cmd_reg     <= w_aw0_fifo_q;
                                r_aw0_fifo_rdreq <= '1';
                            else
                                r_wr_slot_sel    <= '1';
                                r_wr_cmd_reg     <= w_aw1_fifo_q;
                                r_aw1_fifo_rdreq <= '1';
                            end if;
                        elsif w_aw0_fifo_empty = '0' then
                            r_wr_slot_sel    <= '0';
                            r_wr_cmd_reg     <= w_aw0_fifo_q;
                            r_aw0_fifo_rdreq <= '1';
                        else
                            r_wr_slot_sel    <= '1';
                            r_wr_cmd_reg     <= w_aw1_fifo_q;
                            r_aw1_fifo_rdreq <= '1';
                        end if;
                        r_wr_state <= WR_SEND_AW;
                    end if;

                when WR_SEND_AW =>
                    if M_AXI_AWREADY = '1' then
                        r_wr_rr_sel <= not r_wr_slot_sel; --* chnage the grant access for next round after address accepted
                        r_wr_state  <= WR_SEND_W;
                    end if;

                when WR_SEND_W =>
                    if r_wr_slot_sel = '0' then
                        if (S00_AXI_WVALID = '1') and (M_AXI_WREADY = '1') and (S00_AXI_WLAST = '1') then
                            r_wr_state <= WR_WAIT_B;
                        end if;
                    else
                        if (S01_AXI_WVALID = '1') and (M_AXI_WREADY = '1') and (S01_AXI_WLAST = '1') then
                            r_wr_state <= WR_WAIT_B;
                        end if;
                    end if;

                when WR_WAIT_B =>
                    if (M_AXI_BVALID = '1') and (w_bready_sel = '1') then
                        r_wr_state <= WR_IDLE;
                    end if;
            end case;

            case r_rd_state is
                when RD_IDLE =>
                    if (w_ar0_fifo_empty = '0') or (w_ar1_fifo_empty = '0') then
                        if (w_ar0_fifo_empty = '0') and (w_ar1_fifo_empty = '0') then
                            if r_rd_rr_sel = '0' then
                                r_rd_slot_sel    <= '0';
                                r_rd_cmd_reg     <= w_ar0_fifo_q;
                                r_ar0_fifo_rdreq <= '1';
                            else
                                r_rd_slot_sel    <= '1';
                                r_rd_cmd_reg     <= w_ar1_fifo_q;
                                r_ar1_fifo_rdreq <= '1';
                            end if;
                        elsif w_ar0_fifo_empty = '0' then
                            r_rd_slot_sel    <= '0';
                            r_rd_cmd_reg     <= w_ar0_fifo_q;
                            r_ar0_fifo_rdreq <= '1';
                        else
                            r_rd_slot_sel    <= '1';
                            r_rd_cmd_reg     <= w_ar1_fifo_q;
                            r_ar1_fifo_rdreq <= '1';
                        end if;
                        r_rd_state <= RD_SEND_AR;
                    end if;

                when RD_SEND_AR =>
                    if M_AXI_ARREADY = '1' then
                        r_rd_rr_sel <= not r_rd_slot_sel; -- * change the grant access for next round after address accepted
                        -- Return to IDLE after each accepted AR command. The next command
                        -- is fetched from FIFO in RD_IDLE to avoid re-latching stale FIFO q.
                        r_rd_state  <= RD_IDLE;
                    end if;
            end case;
        end if;
    end process;

    -- Write address channel (AW): send selected queued command with remapped ID.
    process(r_wr_state, r_wr_slot_sel, r_wr_cmd_reg)
    begin
        M_AXI_AWVALID                         <= '0';
        -- ID remap format for 2 slots:
        --   M_ID[MSB] = slot index bit
        --   M_ID[LSB +: G_S_ID_WIDTH] = original slave ID
        --   Middle bits (if any) = 0
        M_AXI_AWID                            <= (others => '0');
        M_AXI_AWID(G_M_ID_WIDTH - 1)          <= r_wr_slot_sel;
        M_AXI_AWID(G_S_ID_WIDTH - 1 downto 0) <= r_wr_cmd_reg(C_ID_MSB downto C_ID_LSB);
        M_AXI_AWADDR                          <= r_wr_cmd_reg(C_ADDR_MSB downto C_ADDR_LSB);
        M_AXI_AWLEN                           <= r_wr_cmd_reg(C_LEN_MSB downto C_LEN_LSB);
        M_AXI_AWSIZE                          <= r_wr_cmd_reg(C_SIZE_MSB downto C_SIZE_LSB);
        M_AXI_AWBURST                         <= r_wr_cmd_reg(C_BURST_MSB downto C_BURST_LSB);
        M_AXI_AWLOCK                          <= r_wr_cmd_reg(C_LOCK_LSB);
        M_AXI_AWCACHE                         <= r_wr_cmd_reg(C_CACHE_MSB downto C_CACHE_LSB);
        M_AXI_AWPROT                          <= r_wr_cmd_reg(C_PROT_MSB downto C_PROT_LSB);
        M_AXI_AWQOS                           <= r_wr_cmd_reg(C_QOS_MSB downto C_QOS_LSB);

        -- Note: AWVALID is held until address handshake completes, 
        -- but the command register is only guaranteed to hold the valid command until the next state transition. 
        -- This is safe because the state machine only transitions on AWREADY handshake, 
        -- which guarantees the command has been accepted by the slave and won't be changed by the master.

        if r_wr_state = WR_SEND_AW then
            M_AXI_AWVALID <= '1';
        end if;
    end process;

    -- * Write data channel (W): lock to granted slot until WLAST.
    process(r_wr_state, r_wr_slot_sel, S00_AXI_WVALID, S01_AXI_WVALID, S00_AXI_WDATA, S01_AXI_WDATA, S00_AXI_WSTRB, S01_AXI_WSTRB, S00_AXI_WLAST, S01_AXI_WLAST, M_AXI_WREADY)
    begin
        M_AXI_WVALID   <= '0';
        M_AXI_WDATA    <= (others => '0');
        M_AXI_WSTRB    <= (others => '0');
        M_AXI_WLAST    <= '0';
        S00_AXI_WREADY <= '0';
        S01_AXI_WREADY <= '0';

        if r_wr_state = WR_SEND_W then
            if r_wr_slot_sel = '0' then
                M_AXI_WVALID   <= S00_AXI_WVALID;
                M_AXI_WDATA    <= S00_AXI_WDATA;
                M_AXI_WSTRB    <= S00_AXI_WSTRB;
                M_AXI_WLAST    <= S00_AXI_WLAST;
                S00_AXI_WREADY <= M_AXI_WREADY;
            else
                M_AXI_WVALID   <= S01_AXI_WVALID;
                M_AXI_WDATA    <= S01_AXI_WDATA;
                M_AXI_WSTRB    <= S01_AXI_WSTRB;
                M_AXI_WLAST    <= S01_AXI_WLAST;
                S01_AXI_WREADY <= M_AXI_WREADY;
            end if;
        end if;
    end process;

    -- Write response channel (B): decode BID MSB to return slot.

    w_bid_slot    <= M_AXI_BID(G_M_ID_WIDTH - 1);
    S00_AXI_BID   <= M_AXI_BID(G_S_ID_WIDTH - 1 downto 0);
    S01_AXI_BID   <= M_AXI_BID(G_S_ID_WIDTH - 1 downto 0);
    S00_AXI_BRESP <= M_AXI_BRESP;
    S01_AXI_BRESP <= M_AXI_BRESP;

    -- Drive BREADY based on returned slot and master BVALID.
    process(w_bid_slot, S00_AXI_BREADY, S01_AXI_BREADY)
    begin
        w_bready_sel <= '0';
        if w_bid_slot = '0' then
            w_bready_sel <= S00_AXI_BREADY;
        else
            w_bready_sel <= S01_AXI_BREADY;
        end if;
    end process;

    -- Drive BVALID to the correct slot based on returned BID MSB.
    process(w_bid_slot, M_AXI_BVALID, S00_AXI_BREADY, S01_AXI_BREADY, r_wr_state)
    begin
        S00_AXI_BVALID <= '0';
        S01_AXI_BVALID <= '0';
        M_AXI_BREADY   <= '0';

        if w_bid_slot = '0' then
            S00_AXI_BVALID <= M_AXI_BVALID;
            if r_wr_state = WR_WAIT_B then
                M_AXI_BREADY <= S00_AXI_BREADY;
            end if;
        else
            S01_AXI_BVALID <= M_AXI_BVALID;
            if r_wr_state = WR_WAIT_B then
                M_AXI_BREADY <= S01_AXI_BREADY;
            end if;
        end if;
    end process;

    -- Read address channel (AR): send selected queued command with remapped ID.
    process(r_rd_state, r_rd_slot_sel, r_rd_cmd_reg)
    begin
        M_AXI_ARVALID                         <= '0';
        M_AXI_ARID                            <= (others => '0');
        M_AXI_ARID(G_M_ID_WIDTH - 1)          <= r_rd_slot_sel;
        M_AXI_ARID(G_S_ID_WIDTH - 1 downto 0) <= r_rd_cmd_reg(C_ID_MSB downto C_ID_LSB);
        M_AXI_ARADDR                          <= r_rd_cmd_reg(C_ADDR_MSB downto C_ADDR_LSB);
        M_AXI_ARLEN                           <= r_rd_cmd_reg(C_LEN_MSB downto C_LEN_LSB);
        M_AXI_ARSIZE                          <= r_rd_cmd_reg(C_SIZE_MSB downto C_SIZE_LSB);
        M_AXI_ARBURST                         <= r_rd_cmd_reg(C_BURST_MSB downto C_BURST_LSB);
        M_AXI_ARLOCK                          <= r_rd_cmd_reg(C_LOCK_LSB);
        M_AXI_ARCACHE                         <= r_rd_cmd_reg(C_CACHE_MSB downto C_CACHE_LSB);
        M_AXI_ARPROT                          <= r_rd_cmd_reg(C_PROT_MSB downto C_PROT_LSB);
        M_AXI_ARQOS                           <= r_rd_cmd_reg(C_QOS_MSB downto C_QOS_LSB);

        -- Similar to AWVALID, ARVALID is held until handshake, but command register is only guaranteed valid until
        -- next state transition.
        if r_rd_state = RD_SEND_AR then
            M_AXI_ARVALID <= '1';
        end if;
    end process;

    -- * Read response channel (R): decode RID MSB to return slot.
    w_rid_slot <= M_AXI_RID(G_M_ID_WIDTH - 1);

    process(w_rid_slot, M_AXI_RVALID, M_AXI_RDATA, M_AXI_RRESP, M_AXI_RLAST, M_AXI_RID, S00_AXI_RREADY, S01_AXI_RREADY, r_rd_state)
    begin
        S00_AXI_RVALID <= '0';
        S01_AXI_RVALID <= '0';
        S00_AXI_RDATA  <= (others => '0');
        S01_AXI_RDATA  <= (others => '0');
        S00_AXI_RRESP  <= (others => '0');
        S01_AXI_RRESP  <= (others => '0');
        S00_AXI_RLAST  <= '0';
        S01_AXI_RLAST  <= '0';
        S00_AXI_RID    <= (others => '0');
        S01_AXI_RID    <= (others => '0');

        -- default backpressure (only asserted when valid)
        M_AXI_RREADY <= '0';

        if w_rid_slot = '0' then
            -- route to slot 0

            S00_AXI_RVALID <= M_AXI_RVALID;
            S00_AXI_RDATA  <= M_AXI_RDATA;
            S00_AXI_RRESP  <= M_AXI_RRESP;
            S00_AXI_RLAST  <= M_AXI_RLAST;
            S00_AXI_RID    <= M_AXI_RID(G_S_ID_WIDTH - 1 downto 0);

            if M_AXI_RVALID = '1' then
                M_AXI_RREADY <= S00_AXI_RREADY;
            end if;

        else
            -- route to slot 1
            S01_AXI_RVALID <= M_AXI_RVALID;
            S01_AXI_RDATA  <= M_AXI_RDATA;
            S01_AXI_RRESP  <= M_AXI_RRESP;
            S01_AXI_RLAST  <= M_AXI_RLAST;
            S01_AXI_RID    <= M_AXI_RID(G_S_ID_WIDTH - 1 downto 0);

            if M_AXI_RVALID = '1' then
                M_AXI_RREADY <= S01_AXI_RREADY;
            end if;

        end if;
    end process;

    aw_slot0_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 5,
            g_ALMOST_EMPTY_THRESHOLD => 5
        )
        port map(
            i_resetn       => S00_AXI_ARESETN,
            i_clk          => S00_AXI_ACLK,
            i_wrreq        => w_aw0_fifo_wrreq,
            i_data         => w_aw0_fifo_din,
            i_rdreq        => r_aw0_fifo_rdreq,
            o_q_val        => open,
            o_q            => w_aw0_fifo_q,
            o_usedw        => open,
            o_full         => w_aw0_fifo_full,
            o_empty        => w_aw0_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    aw_slot1_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 5,
            g_ALMOST_EMPTY_THRESHOLD => 5
        )
        port map(
            i_resetn       => S00_AXI_ARESETN,
            i_clk          => S00_AXI_ACLK,
            i_wrreq        => w_aw1_fifo_wrreq,
            i_data         => w_aw1_fifo_din,
            i_rdreq        => r_aw1_fifo_rdreq,
            o_q_val        => open,
            o_q            => w_aw1_fifo_q,
            o_usedw        => open,
            o_full         => w_aw1_fifo_full,
            o_empty        => w_aw1_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    ar_slot0_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 5,
            g_ALMOST_EMPTY_THRESHOLD => 5
        )
        port map(
            i_resetn       => S00_AXI_ARESETN,
            i_clk          => S00_AXI_ACLK,
            i_wrreq        => w_ar0_fifo_wrreq,
            i_data         => w_ar0_fifo_din,
            i_rdreq        => r_ar0_fifo_rdreq,
            o_q_val        => open,
            o_q            => w_ar0_fifo_q,
            o_usedw        => open,
            o_full         => w_ar0_fifo_full,
            o_empty        => w_ar0_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    ar_slot1_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 5,
            g_ALMOST_EMPTY_THRESHOLD => 5
        )
        port map(
            i_resetn       => S00_AXI_ARESETN,
            i_clk          => S00_AXI_ACLK,
            i_wrreq        => w_ar1_fifo_wrreq,
            i_data         => w_ar1_fifo_din,
            i_rdreq        => r_ar1_fifo_rdreq,
            o_q_val        => open,
            o_q            => w_ar1_fifo_q,
            o_usedw        => open,
            o_full         => w_ar1_fifo_full,
            o_empty        => w_ar1_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

end architecture rtl;

