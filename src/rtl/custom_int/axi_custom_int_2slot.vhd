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
        aclk       : in  std_logic;
        aresetn    : in  std_logic;
        -- Slot 0 (slave-side AXI input)
        s0_awid    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s0_awaddr  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        s0_awlen   : in  std_logic_vector(7 downto 0);
        s0_awsize  : in  std_logic_vector(2 downto 0);
        s0_awburst : in  std_logic_vector(1 downto 0);
        s0_awlock  : in  std_logic;
        s0_awcache : in  std_logic_vector(3 downto 0);
        s0_awprot  : in  std_logic_vector(2 downto 0);
        s0_awqos   : in  std_logic_vector(3 downto 0);
        s0_awvalid : in  std_logic;
        s0_awready : out std_logic;
        s0_wdata   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        s0_wstrb   : in  std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        s0_wlast   : in  std_logic;
        s0_wvalid  : in  std_logic;
        s0_wready  : out std_logic;
        s0_bid     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s0_bresp   : out std_logic_vector(1 downto 0);
        s0_bvalid  : out std_logic;
        s0_bready  : in  std_logic;
        s0_arid    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s0_araddr  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        s0_arlen   : in  std_logic_vector(7 downto 0);
        s0_arsize  : in  std_logic_vector(2 downto 0);
        s0_arburst : in  std_logic_vector(1 downto 0);
        s0_arlock  : in  std_logic;
        s0_arcache : in  std_logic_vector(3 downto 0);
        s0_arprot  : in  std_logic_vector(2 downto 0);
        s0_arqos   : in  std_logic_vector(3 downto 0);
        s0_arvalid : in  std_logic;
        s0_arready : out std_logic;
        s0_rid     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s0_rdata   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        s0_rresp   : out std_logic_vector(1 downto 0);
        s0_rlast   : out std_logic;
        s0_rvalid  : out std_logic;
        s0_rready  : in  std_logic;
        -- Slot 1 (slave-side AXI input)
        s1_awid    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s1_awaddr  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        s1_awlen   : in  std_logic_vector(7 downto 0);
        s1_awsize  : in  std_logic_vector(2 downto 0);
        s1_awburst : in  std_logic_vector(1 downto 0);
        s1_awlock  : in  std_logic;
        s1_awcache : in  std_logic_vector(3 downto 0);
        s1_awprot  : in  std_logic_vector(2 downto 0);
        s1_awqos   : in  std_logic_vector(3 downto 0);
        s1_awvalid : in  std_logic;
        s1_awready : out std_logic;
        s1_wdata   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        s1_wstrb   : in  std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        s1_wlast   : in  std_logic;
        s1_wvalid  : in  std_logic;
        s1_wready  : out std_logic;
        s1_bid     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s1_bresp   : out std_logic_vector(1 downto 0);
        s1_bvalid  : out std_logic;
        s1_bready  : in  std_logic;
        s1_arid    : in  std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s1_araddr  : in  std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        s1_arlen   : in  std_logic_vector(7 downto 0);
        s1_arsize  : in  std_logic_vector(2 downto 0);
        s1_arburst : in  std_logic_vector(1 downto 0);
        s1_arlock  : in  std_logic;
        s1_arcache : in  std_logic_vector(3 downto 0);
        s1_arprot  : in  std_logic_vector(2 downto 0);
        s1_arqos   : in  std_logic_vector(3 downto 0);
        s1_arvalid : in  std_logic;
        s1_arready : out std_logic;
        s1_rid     : out std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
        s1_rdata   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        s1_rresp   : out std_logic_vector(1 downto 0);
        s1_rlast   : out std_logic;
        s1_rvalid  : out std_logic;
        s1_rready  : in  std_logic;
        -- DDR-side AXI master output
        m_awid     : out std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        m_awaddr   : out std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        m_awlen    : out std_logic_vector(7 downto 0);
        m_awsize   : out std_logic_vector(2 downto 0);
        m_awburst  : out std_logic_vector(1 downto 0);
        m_awlock   : out std_logic;
        m_awcache  : out std_logic_vector(3 downto 0);
        m_awprot   : out std_logic_vector(2 downto 0);
        m_awqos    : out std_logic_vector(3 downto 0);
        m_awvalid  : out std_logic;
        m_awready  : in  std_logic;
        m_wdata    : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        m_wstrb    : out std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
        m_wlast    : out std_logic;
        m_wvalid   : out std_logic;
        m_wready   : in  std_logic;
        m_bid      : in  std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        m_bresp    : in  std_logic_vector(1 downto 0);
        m_bvalid   : in  std_logic;
        m_bready   : out std_logic;
        m_arid     : out std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        m_araddr   : out std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
        m_arlen    : out std_logic_vector(7 downto 0);
        m_arsize   : out std_logic_vector(2 downto 0);
        m_arburst  : out std_logic_vector(1 downto 0);
        m_arlock   : out std_logic;
        m_arcache  : out std_logic_vector(3 downto 0);
        m_arprot   : out std_logic_vector(2 downto 0);
        m_arqos    : out std_logic_vector(3 downto 0);
        m_arvalid  : out std_logic;
        m_arready  : in  std_logic;
        m_rid      : in  std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
        m_rdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        m_rresp    : in  std_logic_vector(1 downto 0);
        m_rlast    : in  std_logic;
        m_rvalid   : in  std_logic;
        m_rready   : out std_logic
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

    signal wr_state : wr_state_t := WR_IDLE;
    signal rd_state : rd_state_t := RD_IDLE;

    -- round robin select signals for issuing from two slots
    signal wr_rr_sel   : std_logic := '0';
    signal rd_rr_sel   : std_logic := '0';
    signal wr_slot_sel : std_logic := '0';
    signal rd_slot_sel : std_logic := '0';

    signal wr_cmd_reg : std_logic_vector(C_CMD_W - 1 downto 0) := (others => '0');
    signal rd_cmd_reg : std_logic_vector(C_CMD_W - 1 downto 0) := (others => '0');

    signal aw0_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal aw1_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal aw0_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal aw1_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal aw0_fifo_wrreq : std_logic;
    signal aw1_fifo_wrreq : std_logic;
    signal aw0_fifo_rdreq : std_logic := '0';
    signal aw1_fifo_rdreq : std_logic := '0';
    signal aw0_fifo_full  : std_logic;
    signal aw1_fifo_full  : std_logic;
    signal aw0_fifo_empty : std_logic;
    signal aw1_fifo_empty : std_logic;

    signal ar0_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal ar1_fifo_din   : std_logic_vector(C_CMD_W - 1 downto 0);
    signal ar0_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal ar1_fifo_q     : std_logic_vector(C_CMD_W - 1 downto 0);
    signal ar0_fifo_wrreq : std_logic;
    signal ar1_fifo_wrreq : std_logic;
    signal ar0_fifo_rdreq : std_logic := '0';
    signal ar1_fifo_rdreq : std_logic := '0';
    signal ar0_fifo_full  : std_logic;
    signal ar1_fifo_full  : std_logic;
    signal ar0_fifo_empty : std_logic;
    signal ar1_fifo_empty : std_logic;

    signal bid_slot : std_logic;
    signal rid_slot : std_logic;

    signal w_bready_sel : std_logic;

    --interenal signals for the fifo_full assertions
    signal s0_awready_i : std_logic;
    signal s1_awready_i : std_logic;
    signal s0_arready_i : std_logic;
    signal s1_arready_i : std_logic;

begin

    assert G_DATA_WIDTH mod 8 = 0
    report "G_DATA_WIDTH must be divisible by 8."
    severity failure;

    assert G_CMD_FIFO_DEPTH > 1
    report "G_CMD_FIFO_DEPTH must be > 1."
    severity failure;

    assert G_M_ID_WIDTH >= (G_S_ID_WIDTH + 1)
    report "G_M_ID_WIDTH must be >= G_S_ID_WIDTH + 1 for 2-slot remap."
    severity failure;

    -- Pack incoming AW/AR metadata (ID + attributes) before enqueue.
    aw0_fifo_din <= s0_awid & s0_awaddr & s0_awlen & s0_awsize & s0_awburst & s0_awlock & s0_awcache & s0_awprot & s0_awqos;
    aw1_fifo_din <= s1_awid & s1_awaddr & s1_awlen & s1_awsize & s1_awburst & s1_awlock & s1_awcache & s1_awprot & s1_awqos;
    ar0_fifo_din <= s0_arid & s0_araddr & s0_arlen & s0_arsize & s0_arburst & s0_arlock & s0_arcache & s0_arprot & s0_arqos;
    ar1_fifo_din <= s1_arid & s1_araddr & s1_arlen & s1_arsize & s1_arburst & s1_arlock & s1_arcache & s1_arprot & s1_arqos;

    -- Backpressure slave AW/AR ready when respective FIFO is not full.
    s0_awready_i <= not aw0_fifo_full;
    s1_awready_i <= not aw1_fifo_full;
    s0_arready_i <= not ar0_fifo_full;
    s1_arready_i <= not ar1_fifo_full;

    -- Enqueue AW/AR commands when valid and accepted by ready handshake.
    aw0_fifo_wrreq <= s0_awvalid and s0_awready_i;
    aw1_fifo_wrreq <= s1_awvalid and s1_awready_i;
    ar0_fifo_wrreq <= s0_arvalid and s0_arready_i;
    ar1_fifo_wrreq <= s1_arvalid and s1_arready_i;

    -- Drive ready signals based on FIFO full status.
    s0_awready <= s0_awready_i;
    s1_awready <= s1_awready_i;
    s0_arready <= s0_arready_i;
    s1_arready <= s1_arready_i;

    process(aclk, aresetn)
    begin
        if aresetn = '0' then
            wr_state       <= WR_IDLE;
            rd_state       <= RD_IDLE;
            wr_rr_sel      <= '0';
            rd_rr_sel      <= '0';
            wr_slot_sel    <= '0';
            rd_slot_sel    <= '0';
            wr_cmd_reg     <= (others => '0');
            rd_cmd_reg     <= (others => '0');
            aw0_fifo_rdreq <= '0';
            aw1_fifo_rdreq <= '0';
            ar0_fifo_rdreq <= '0';
            ar1_fifo_rdreq <= '0';
        elsif rising_edge(aclk) then
            aw0_fifo_rdreq <= '0';
            aw1_fifo_rdreq <= '0';
            ar0_fifo_rdreq <= '0';
            ar1_fifo_rdreq <= '0';

            case wr_state is
                when WR_IDLE =>
                    if (aw0_fifo_empty = '0') or (aw1_fifo_empty = '0') then
                        if (aw0_fifo_empty = '0') and (aw1_fifo_empty = '0') then
                            if wr_rr_sel = '0' then
                                wr_slot_sel    <= '0';
                                wr_cmd_reg     <= aw0_fifo_q;
                                aw0_fifo_rdreq <= '1';
                            else
                                wr_slot_sel    <= '1';
                                wr_cmd_reg     <= aw1_fifo_q;
                                aw1_fifo_rdreq <= '1';
                            end if;
                        elsif aw0_fifo_empty = '0' then
                            wr_slot_sel    <= '0';
                            wr_cmd_reg     <= aw0_fifo_q;
                            aw0_fifo_rdreq <= '1';
                        else
                            wr_slot_sel    <= '1';
                            wr_cmd_reg     <= aw1_fifo_q;
                            aw1_fifo_rdreq <= '1';
                        end if;
                        wr_state <= WR_SEND_AW;
                    end if;

                when WR_SEND_AW =>
                    if m_awready = '1' then
                        wr_rr_sel <= not wr_slot_sel; --* chnage the grant access for next round after address accepted
                        wr_state  <= WR_SEND_W;
                    end if;

                when WR_SEND_W =>
                    if wr_slot_sel = '0' then
                        if (s0_wvalid = '1') and (m_wready = '1') and (s0_wlast = '1') then
                            wr_state <= WR_WAIT_B;
                        end if;
                    else
                        if (s1_wvalid = '1') and (m_wready = '1') and (s1_wlast = '1') then
                            wr_state <= WR_WAIT_B;
                        end if;
                    end if;

                when WR_WAIT_B =>
                    if (m_bvalid = '1') and (w_bready_sel = '1') then
                        wr_state <= WR_IDLE;
                    end if;
            end case;

            case rd_state is
                when RD_IDLE =>
                    if (ar0_fifo_empty = '0') or (ar1_fifo_empty = '0') then
                        if (ar0_fifo_empty = '0') and (ar1_fifo_empty = '0') then
                            if rd_rr_sel = '0' then
                                rd_slot_sel    <= '0';
                                rd_cmd_reg     <= ar0_fifo_q;
                                ar0_fifo_rdreq <= '1';
                            else
                                rd_slot_sel    <= '1';
                                rd_cmd_reg     <= ar1_fifo_q;
                                ar1_fifo_rdreq <= '1';
                            end if;
                        elsif ar0_fifo_empty = '0' then
                            rd_slot_sel    <= '0';
                            rd_cmd_reg     <= ar0_fifo_q;
                            ar0_fifo_rdreq <= '1';
                        else
                            rd_slot_sel    <= '1';
                            rd_cmd_reg     <= ar1_fifo_q;
                            ar1_fifo_rdreq <= '1';
                        end if;
                        rd_state <= RD_SEND_AR;
                    end if;

                when RD_SEND_AR =>
                    if m_arready = '1' then
                        rd_rr_sel <= not rd_slot_sel; -- * change the grant access for next round after address accepted
                        rd_state  <= RD_IDLE;
                    end if;
            end case;
        end if;
    end process;

    -- Write address channel (AW): send selected queued command with remapped ID.
    process(wr_state, wr_slot_sel, wr_cmd_reg)
    begin
        m_awvalid                         <= '0';
        -- ID remap format for 2 slots:
        --   M_ID[MSB] = slot index bit
        --   M_ID[LSB +: G_S_ID_WIDTH] = original slave ID
        --   Middle bits (if any) = 0
        m_awid                            <= (others => '0');
        m_awid(G_M_ID_WIDTH - 1)          <= wr_slot_sel;
        m_awid(G_S_ID_WIDTH - 1 downto 0) <= wr_cmd_reg(C_ID_MSB downto C_ID_LSB);
        m_awaddr                          <= wr_cmd_reg(C_ADDR_MSB downto C_ADDR_LSB);
        m_awlen                           <= wr_cmd_reg(C_LEN_MSB downto C_LEN_LSB);
        m_awsize                          <= wr_cmd_reg(C_SIZE_MSB downto C_SIZE_LSB);
        m_awburst                         <= wr_cmd_reg(C_BURST_MSB downto C_BURST_LSB);
        m_awlock                          <= wr_cmd_reg(C_LOCK_LSB);
        m_awcache                         <= wr_cmd_reg(C_CACHE_MSB downto C_CACHE_LSB);
        m_awprot                          <= wr_cmd_reg(C_PROT_MSB downto C_PROT_LSB);
        m_awqos                           <= wr_cmd_reg(C_QOS_MSB downto C_QOS_LSB);

        -- Note: AWVALID is held until address handshake completes, 
        -- but the command register is only guaranteed to hold the valid command until the next state transition. 
        -- This is safe because the state machine only transitions on AWREADY handshake, 
        -- which guarantees the command has been accepted by the slave and won't be changed by the master.

        if wr_state = WR_SEND_AW then
            m_awvalid <= '1';
        end if;
    end process;

    -- * Write data channel (W): lock to granted slot until WLAST.
    process(wr_state, wr_slot_sel, s0_wvalid, s1_wvalid, s0_wdata, s1_wdata, s0_wstrb, s1_wstrb, s0_wlast, s1_wlast, m_wready)
    begin
        m_wvalid  <= '0';
        m_wdata   <= (others => '0');
        m_wstrb   <= (others => '0');
        m_wlast   <= '0';
        s0_wready <= '0';
        s1_wready <= '0';

        if wr_state = WR_SEND_W then
            if wr_slot_sel = '0' then
                m_wvalid  <= s0_wvalid;
                m_wdata   <= s0_wdata;
                m_wstrb   <= s0_wstrb;
                m_wlast   <= s0_wlast;
                s0_wready <= m_wready;
            else
                m_wvalid  <= s1_wvalid;
                m_wdata   <= s1_wdata;
                m_wstrb   <= s1_wstrb;
                m_wlast   <= s1_wlast;
                s1_wready <= m_wready;
            end if;
        end if;
    end process;

    -- Write response channel (B): decode BID MSB to return slot.
    bid_slot <= m_bid(G_M_ID_WIDTH - 1);
    s0_bid   <= m_bid(G_S_ID_WIDTH - 1 downto 0);
    s1_bid   <= m_bid(G_S_ID_WIDTH - 1 downto 0);
    s0_bresp <= m_bresp;
    s1_bresp <= m_bresp;

    -- Drive BREADY based on returned slot and master BVALID.
    process(bid_slot, s0_bready, s1_bready)
    begin
        w_bready_sel <= '0';
        if bid_slot = '0' then
            w_bready_sel <= s0_bready;
        else
            w_bready_sel <= s1_bready;
        end if;
    end process;

    -- Drive BVALID to the correct slot based on returned BID MSB.
    process(bid_slot, m_bvalid, s0_bready, s1_bready, wr_state)
    begin
        s0_bvalid <= '0';
        s1_bvalid <= '0';
        m_bready  <= '0';

        if bid_slot = '0' then
            s0_bvalid <= m_bvalid;
            if wr_state = WR_WAIT_B then
                m_bready <= s0_bready;
            end if;
        else
            s1_bvalid <= m_bvalid;
            if wr_state = WR_WAIT_B then
                m_bready <= s1_bready;
            end if;
        end if;
    end process;

    -- Read address channel (AR): send selected queued command with remapped ID.
    process(rd_state, rd_slot_sel, rd_cmd_reg)
    begin
        m_arvalid                         <= '0';
        m_arid                            <= (others => '0');
        m_arid(G_M_ID_WIDTH - 1)          <= rd_slot_sel;
        m_arid(G_S_ID_WIDTH - 1 downto 0) <= rd_cmd_reg(C_ID_MSB downto C_ID_LSB);
        m_araddr                          <= rd_cmd_reg(C_ADDR_MSB downto C_ADDR_LSB);
        m_arlen                           <= rd_cmd_reg(C_LEN_MSB downto C_LEN_LSB);
        m_arsize                          <= rd_cmd_reg(C_SIZE_MSB downto C_SIZE_LSB);
        m_arburst                         <= rd_cmd_reg(C_BURST_MSB downto C_BURST_LSB);
        m_arlock                          <= rd_cmd_reg(C_LOCK_LSB);
        m_arcache                         <= rd_cmd_reg(C_CACHE_MSB downto C_CACHE_LSB);
        m_arprot                          <= rd_cmd_reg(C_PROT_MSB downto C_PROT_LSB);
        m_arqos                           <= rd_cmd_reg(C_QOS_MSB downto C_QOS_LSB);

        -- Similar to AWVALID, ARVALID is held until handshake, but command register is only guaranteed valid until
        -- next state transition.
        if rd_state = RD_SEND_AR then
            m_arvalid <= '1';
        end if;
    end process;

    -- * Read response channel (R): decode RID MSB to return slot.
    rid_slot <= m_rid(G_M_ID_WIDTH - 1);
    s0_rid   <= m_rid(G_S_ID_WIDTH - 1 downto 0);
    s1_rid   <= m_rid(G_S_ID_WIDTH - 1 downto 0);
    s0_rdata <= m_rdata;
    s1_rdata <= m_rdata;
    s0_rresp <= m_rresp;
    s1_rresp <= m_rresp;
    s0_rlast <= m_rlast;
    s1_rlast <= m_rlast;

    -- Drive RREADY based on returned slot and master RVALID.
    process(rid_slot, m_rvalid, s0_rready, s1_rready)
    begin
        s0_rvalid <= '0';
        s1_rvalid <= '0';
        m_rready  <= '0';

        if rid_slot = '0' then
            s0_rvalid <= m_rvalid;
            if m_rvalid = '1' then
                m_rready <= s0_rready;
            end if;
        else
            s1_rvalid <= m_rvalid;
            if m_rvalid = '1' then
                m_rready <= s1_rready;
            end if;
        end if;
    end process;

    aw_slot0_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 1,
            g_ALMOST_EMPTY_THRESHOLD => 1
        )
        port map(
            i_resetn       => aresetn,
            i_clk          => aclk,
            i_wrreq        => aw0_fifo_wrreq,
            i_data         => aw0_fifo_din,
            i_rdreq        => aw0_fifo_rdreq,
            o_q_val        => open,
            o_q            => aw0_fifo_q,
            o_usedw        => open,
            o_full         => aw0_fifo_full,
            o_empty        => aw0_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    aw_slot1_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 1,
            g_ALMOST_EMPTY_THRESHOLD => 1
        )
        port map(
            i_resetn       => aresetn,
            i_clk          => aclk,
            i_wrreq        => aw1_fifo_wrreq,
            i_data         => aw1_fifo_din,
            i_rdreq        => aw1_fifo_rdreq,
            o_q_val        => open,
            o_q            => aw1_fifo_q,
            o_usedw        => open,
            o_full         => aw1_fifo_full,
            o_empty        => aw1_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    ar_slot0_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 1,
            g_ALMOST_EMPTY_THRESHOLD => 1
        )
        port map(
            i_resetn       => aresetn,
            i_clk          => aclk,
            i_wrreq        => ar0_fifo_wrreq,
            i_data         => ar0_fifo_din,
            i_rdreq        => ar0_fifo_rdreq,
            o_q_val        => open,
            o_q            => ar0_fifo_q,
            o_usedw        => open,
            o_full         => ar0_fifo_full,
            o_empty        => ar0_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

    ar_slot1_fifo_inst : xpm_fifo_sync_wrap
        generic map(
            g_TYPE                   => "distributed",
            g_DATA_WIDTH             => C_CMD_W,
            g_DEPTH                  => G_CMD_FIFO_DEPTH,
            g_FWFT_MODE_ENA          => true,
            g_ALMOST_FULL_THRESHOLD  => G_CMD_FIFO_DEPTH - 1,
            g_ALMOST_EMPTY_THRESHOLD => 1
        )
        port map(
            i_resetn       => aresetn,
            i_clk          => aclk,
            i_wrreq        => ar1_fifo_wrreq,
            i_data         => ar1_fifo_din,
            i_rdreq        => ar1_fifo_rdreq,
            o_q_val        => open,
            o_q            => ar1_fifo_q,
            o_usedw        => open,
            o_full         => ar1_fifo_full,
            o_empty        => ar1_fifo_empty,
            o_almost_full  => open,
            o_almost_empty => open
        );

end architecture rtl;
