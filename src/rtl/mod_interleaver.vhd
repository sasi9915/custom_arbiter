library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;

entity mod_intrlv is

    port(
        axis_resetn          : in  std_logic;
        axis_clk             : in  std_logic;
        frame_tready         : out std_logic;
        frame_tvalid         : in  std_logic;
        frame_tuser          : in  std_logic_vector(15 downto 00);
        frame_tdata          : in  std_logic_vector(31 downto 00);
        frame_tkeep          : in  std_logic_vector(03 downto 00);
        frame_tlast          : in  std_logic;
        frame_intrlvd_tready : in  std_logic;
        frame_intrlvd_tvalid : out std_logic;
        frame_intrlvd_tuser  : out std_logic_vector(15 downto 00);
        frame_intrlvd_tdata  : out std_logic_vector(31 downto 00);
        frame_intrlvd_tkeep  : out std_logic_vector(03 downto 00);
        frame_intrlvd_tlast  : out std_logic;
        ddr4_m_axi_awid      : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awaddr    : out std_logic_vector(28 downto 0);
        ddr4_m_axi_awlen     : out std_logic_vector(7 downto 0);
        ddr4_m_axi_awsize    : out std_logic_vector(2 downto 0);
        ddr4_m_axi_awburst   : out std_logic_vector(1 downto 0);
        ddr4_m_axi_awlock    : out std_logic_vector(0 downto 0);
        ddr4_m_axi_awcache   : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awprot    : out std_logic_vector(2 downto 0);
        ddr4_m_axi_awqos     : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awvalid   : out std_logic;
        ddr4_m_axi_awready   : in  std_logic;
        ddr4_m_axi_wdata     : out std_logic_vector(127 downto 0);
        ddr4_m_axi_wstrb     : out std_logic_vector(15 downto 0);
        ddr4_m_axi_wlast     : out std_logic;
        ddr4_m_axi_wvalid    : out std_logic;
        ddr4_m_axi_wready    : in  std_logic;
        ddr4_m_axi_bready    : out std_logic;
        ddr4_m_axi_bid       : in  std_logic_vector(3 downto 0);
        ddr4_m_axi_bresp     : in  std_logic_vector(1 downto 0);
        ddr4_m_axi_bvalid    : in  std_logic;
        ddr4_m_axi_arid      : out std_logic_vector(3 downto 0);
        ddr4_m_axi_araddr    : out std_logic_vector(28 downto 0);
        ddr4_m_axi_arlen     : out std_logic_vector(7 downto 0);
        ddr4_m_axi_arsize    : out std_logic_vector(2 downto 0);
        ddr4_m_axi_arburst   : out std_logic_vector(1 downto 0);
        ddr4_m_axi_arlock    : out std_logic_vector(0 downto 0);
        ddr4_m_axi_arcache   : out std_logic_vector(3 downto 0);
        ddr4_m_axi_arprot    : out std_logic_vector(2 downto 0);
        ddr4_m_axi_arqos     : out std_logic_vector(3 downto 0);
        ddr4_m_axi_arvalid   : out std_logic;
        ddr4_m_axi_arready   : in  std_logic;
        ddr4_m_axi_rready    : out std_logic;
        ddr4_m_axi_rlast     : in  std_logic;
        ddr4_m_axi_rvalid    : in  std_logic;
        ddr4_m_axi_rresp     : in  std_logic_vector(1 downto 0);
        ddr4_m_axi_rid       : in  std_logic_vector(3 downto 0);
        ddr4_m_axi_rdata     : in  std_logic_vector(127 downto 0)
    );
end entity;

architecture arc_mod_intrlv of mod_intrlv is

    -- Constants
    constant C_ROWS         : unsigned(9 downto 0)  := to_unsigned(64, 10);
    constant C_COLS         : unsigned(9 downto 0)  := to_unsigned(64, 10);
    constant C_base_address : unsigned(28 downto 0) := to_unsigned(1000, 29);
    constant C_BURST_LEN    : unsigned(3 downto 0)  := to_unsigned(8, 4);

    -- Clocks & Resets
    attribute X_INTERFACE_INFO      : string;
    attribute X_INTERFACE_PARAMETER : string;

    attribute X_INTERFACE_INFO of axis_clk      : signal is "xilinx.com:signal:clock:1.0 axis_clk CLK";
    attribute X_INTERFACE_PARAMETER of axis_clk : signal is "ASSOCIATED_BUSIF frame:frame_intrlvd:ddr4_m, ASSOCIATED_RESET axis_resetn";

    attribute X_INTERFACE_INFO of axis_resetn      : signal is "xilinx.com:signal:reset:1.0 axis_resetn RST";
    attribute X_INTERFACE_PARAMETER of axis_resetn : signal is "POLARITY ACTIVE_LOW";

    -- AXI4-Stream Slave (frame)
    attribute X_INTERFACE_INFO of frame_tvalid     : signal is "xilinx.com:interface:axis:1.0 frame TVALID";
    attribute X_INTERFACE_INFO of frame_tready     : signal is "xilinx.com:interface:axis:1.0 frame TREADY";
    attribute X_INTERFACE_INFO of frame_tuser      : signal is "xilinx.com:interface:axis:1.0 frame TUSER";
    attribute X_INTERFACE_INFO of frame_tdata      : signal is "xilinx.com:interface:axis:1.0 frame TDATA";
    attribute X_INTERFACE_INFO of frame_tkeep      : signal is "xilinx.com:interface:axis:1.0 frame TKEEP";
    attribute X_INTERFACE_INFO of frame_tlast      : signal is "xilinx.com:interface:axis:1.0 frame TLAST";
    attribute X_INTERFACE_PARAMETER of frame_tdata : signal is "TDATA_NUM_BYTES 4, TUSER_WIDTH 16, HAS_TKEEP 1, HAS_TLAST 1";

    -- AXI4-Stream Master (frame_intrlvd)
    attribute X_INTERFACE_INFO of frame_intrlvd_tvalid     : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TVALID";
    attribute X_INTERFACE_INFO of frame_intrlvd_tready     : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TREADY";
    attribute X_INTERFACE_INFO of frame_intrlvd_tuser      : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TUSER";
    attribute X_INTERFACE_INFO of frame_intrlvd_tdata      : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TDATA";
    attribute X_INTERFACE_INFO of frame_intrlvd_tkeep      : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TKEEP";
    attribute X_INTERFACE_INFO of frame_intrlvd_tlast      : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TLAST";
    attribute X_INTERFACE_PARAMETER of frame_intrlvd_tdata : signal is "TDATA_NUM_BYTES 4, TUSER_WIDTH 16, HAS_TKEEP 1, HAS_TLAST 1";

    -- AXI4 Master Interface (DDR4)
    attribute X_INTERFACE_INFO of ddr4_m_axi_awid    : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awaddr  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWADDR";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awlen   : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWLEN";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awsize  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWSIZE";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awburst : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWBURST";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awlock  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWLOCK";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awcache : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWCACHE";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awprot  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWPROT";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awqos   : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWQOS";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWVALID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_awready : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi AWREADY";

    attribute X_INTERFACE_INFO of ddr4_m_axi_wdata  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi WDATA";
    attribute X_INTERFACE_INFO of ddr4_m_axi_wstrb  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi WSTRB";
    attribute X_INTERFACE_INFO of ddr4_m_axi_wlast  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi WLAST";
    attribute X_INTERFACE_INFO of ddr4_m_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi WVALID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_wready : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi WREADY";

    attribute X_INTERFACE_INFO of ddr4_m_axi_bid    : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi BID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_bresp  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi BRESP";
    attribute X_INTERFACE_INFO of ddr4_m_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi BVALID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_bready : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi BREADY";

    attribute X_INTERFACE_INFO of ddr4_m_axi_arid    : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_araddr  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARADDR";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arlen   : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARLEN";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arsize  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARSIZE";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arburst : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARBURST";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arlock  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARLOCK";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arcache : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARCACHE";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arprot  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARPROT";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arqos   : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARQOS";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARVALID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_arready : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi ARREADY";

    attribute X_INTERFACE_INFO of ddr4_m_axi_rid    : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_rdata  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RDATA";
    attribute X_INTERFACE_INFO of ddr4_m_axi_rresp  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RRESP";
    attribute X_INTERFACE_INFO of ddr4_m_axi_rlast  : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RLAST";
    attribute X_INTERFACE_INFO of ddr4_m_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RVALID";
    attribute X_INTERFACE_INFO of ddr4_m_axi_rready : signal is "xilinx.com:interface:aximm:1.0 ddr4_m_axi RREADY";

    attribute X_INTERFACE_PARAMETER of ddr4_m_axi_awaddr : signal is "DATA_WIDTH 128, ADDR_WIDTH 29, ID_WIDTH 4, PROTOCOL AXI4, MAX_BURST_LENGTH 256";

    -- Component Declarations
    component avmm_to_axi4_wr is
        generic(
            g_ADDR_WIDTH : integer := 29;
            g_DATA_WIDTH : integer := 128
        );
        port(
            axi_aresetn       : in  std_logic;
            axi_aclk          : in  std_logic;
            avmm_s_write      : in  std_logic;
            avmm_s_address    : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
            avmm_s_writedata  : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            avmm_s_busy       : out std_logic;
            axi_m_axi_awid    : out std_logic_vector(3 downto 0);
            axi_m_axi_awaddr  : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
            axi_m_axi_awlen   : out std_logic_vector(7 downto 0);
            axi_m_axi_awsize  : out std_logic_vector(2 downto 0);
            axi_m_axi_awburst : out std_logic_vector(1 downto 0);
            axi_m_axi_awlock  : out std_logic_vector(0 downto 0);
            axi_m_axi_awcache : out std_logic_vector(3 downto 0);
            axi_m_axi_awprot  : out std_logic_vector(2 downto 0);
            axi_m_axi_awqos   : out std_logic_vector(3 downto 0);
            axi_m_axi_awvalid : out std_logic;
            axi_m_axi_awready : in  std_logic;
            axi_m_axi_wdata   : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            axi_m_axi_wstrb   : out std_logic_vector(15 downto 0);
            axi_m_axi_wlast   : out std_logic;
            axi_m_axi_wvalid  : out std_logic;
            axi_m_axi_wready  : in  std_logic;
            axi_m_axi_bready  : out std_logic;
            axi_m_axi_bid     : in  std_logic_vector(3 downto 0);
            axi_m_axi_bresp   : in  std_logic_vector(1 downto 0);
            axi_m_axi_bvalid  : in  std_logic
        );
    end component;

    component avmm_to_axi4_rd
        generic(
            g_ADDR_WIDTH : integer := 29;
            g_DATA_WIDTH : integer := 128
        );
        port(
            axi_aresetn         : in  std_logic;
            axi_aclk            : in  std_logic;
            avmm_s_read         : in  std_logic;
            avmm_s_address      : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
            avmm_s_address_val  : in  std_logic;
            avmm_s_readdata_val : out std_logic;
            avmm_s_readdata     : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);
            avmm_s_busy         : out std_logic;
            axi_m_axi_arid      : out std_logic_vector(3 downto 0);
            axi_m_axi_araddr    : out std_logic_vector(28 downto 0);
            axi_m_axi_arlen     : out std_logic_vector(7 downto 0);
            axi_m_axi_arsize    : out std_logic_vector(2 downto 0);
            axi_m_axi_arburst   : out std_logic_vector(1 downto 0);
            axi_m_axi_arlock    : out std_logic_vector(0 downto 0);
            axi_m_axi_arcache   : out std_logic_vector(3 downto 0);
            axi_m_axi_arprot    : out std_logic_vector(2 downto 0);
            axi_m_axi_arqos     : out std_logic_vector(3 downto 0);
            axi_m_axi_arvalid   : out std_logic;
            axi_m_axi_arready   : in  std_logic;
            axi_m_axi_rready    : out std_logic;
            axi_m_axi_rlast     : in  std_logic;
            axi_m_axi_rvalid    : in  std_logic;
            axi_m_axi_rresp     : in  std_logic_vector(1 downto 0);
            axi_m_axi_rid       : in  std_logic_vector(3 downto 0);
            axi_m_axi_rdata     : in  std_logic_vector(127 downto 0)
        );
    end component;

    -- Component IOs
    signal r_avmm_to_axi4_wr_avmm_write     : std_logic;
    signal r_avmm_to_axi4_wr_avmm_address   : std_logic_vector(28 downto 0);
    signal r_avmm_to_axi4_wr_avmm_writedata : std_logic_vector(127 downto 0);
    signal w_avmm_to_axi4_wr_avmm_busy      : std_logic;

    signal r_avmm_to_axi4_rd_avmm_read         : std_logic;
    signal r_avmm_to_axi4_rd_avmm_address      : std_logic_vector(28 downto 0);
    signal r_avmm_to_axi4_rd_avmm_address_val  : std_logic;
    signal w_avmm_to_axi4_rd_avmm_readdata_val : std_logic;
    signal w_avmm_to_axi4_rd_avmm_readdata     : std_logic_vector(127 downto 0);
    signal w_avmm_to_axi4_rd_avmm_busy         : std_logic;

    -- Temp Signals
    signal w_write_limit               : unsigned(28 downto 0)          := (others => '0');
    signal r_rd_address_current_row    : unsigned(9 downto 0)           := (others => '0');
    signal r_rd_address_current_column : unsigned(9 downto 0)           := (others => '0');
    signal r_rd_address_gen            : std_logic                      := '0';
    signal sr_frame_data               : std_logic_vector(127 downto 0) := (others => '0');
    signal r_out_data                  : std_logic_vector(31 downto 0)  := (others => '0');
    signal r_byte_idx                  : unsigned(1 downto 0)           := (others => '0');
    signal r_bit_idx                   : unsigned(4 downto 0)           := (others => '0');
    signal r_ddr_offset                : unsigned(28 downto 0)          := (others => '0');
    signal r_write_ddr_address         : unsigned(28 downto 0)          := (others => '0');
    signal r_out_last                  : std_logic                      := '0';
    signal r_tkeep                     : std_logic_vector(3 downto 0)   := (others => '0');
    signal r_burst_cnt                 : unsigned(2 downto 0)           := (others => '0');

    -- Registered Outputs
    signal r_frame_tready         : std_logic;
    signal r_frame_intrlvd_tvalid : std_logic;
    signal r_frame_intrlvd_tuser  : std_logic_vector(15 downto 00);
    signal r_frame_intrlvd_tdata  : std_logic_vector(31 downto 00);
    signal r_frame_intrlvd_tkeep  : std_logic_vector(03 downto 00);
    signal r_frame_intrlvd_tlast  : std_logic;

    -- FIFO signals
    signal fifo_din   : std_logic_vector(6 downto 0) := (others => '0');
    signal fifo_dout  : std_logic_vector(6 downto 0) := (others => '0');
    signal fifo_wr_en : std_logic                    := '0';
    signal fifo_rd_en : std_logic                    := '0';
    signal fifo_rst   : std_logic                    := '0';

    type buf_burst_t is array (0 to to_integer(C_BURST_LEN) - 1) of std_logic_vector(127 downto 0);

    signal buf_burst : buf_burst_t;

    -- States
    type state_type is (wr_idle, wr_store_buffer, wr_burst_start, wr_burst_data, wr_burst_wait,
                        rd_phase);

    signal next_state, current_state : state_type;

begin
    process(axis_resetn, axis_clk) is
    begin
        if axis_resetn = '0' then

            -- Output Registers
            r_frame_tready         <= '0';
            r_frame_intrlvd_tvalid <= '0';
            r_frame_intrlvd_tuser  <= (others => '0');
            r_frame_intrlvd_tdata  <= (others => '0');
            r_frame_intrlvd_tkeep  <= (others => '0');
            r_frame_intrlvd_tlast  <= '0';

            r_avmm_to_axi4_wr_avmm_write     <= '0';
            r_avmm_to_axi4_wr_avmm_address   <= (others => '0');
            r_avmm_to_axi4_wr_avmm_writedata <= (others => '0');

            r_avmm_to_axi4_rd_avmm_read        <= '0';
            r_avmm_to_axi4_rd_avmm_address     <= (others => '0');
            r_avmm_to_axi4_rd_avmm_address_val <= '0';

            fifo_din   <= (others => '0');
            fifo_wr_en <= '0';

            current_state <= wr_idle;

            -- Registers
            r_byte_idx                  <= (others => '0');
            sr_frame_data               <= (others => '0');
            r_out_data                  <= (others => '0');
            r_ddr_offset                <= (others => '0');
            r_write_ddr_address         <= (others => '0');
            r_rd_address_current_column <= (others => '0');
            r_rd_address_current_row    <= (others => '0');
            r_bit_idx                   <= (others => '0');
            r_tkeep                     <= (others => '0');
            r_burst_cnt                 <= (others => '0');
            buf_burst                   <= (others => (others => '0'));
            r_rd_address_gen            <= '0';
            r_out_last                  <= '0';

        elsif axis_clk'event and axis_clk = '1' then

            -- defaults every cycle 
            r_frame_tready               <= '0';
            r_avmm_to_axi4_rd_avmm_read  <= '0';
            r_avmm_to_axi4_wr_avmm_write <= '0';
            r_frame_intrlvd_tlast        <= '0';
            r_frame_intrlvd_tvalid       <= '0';

            case current_state is

                -- idle - latch axis word
                when wr_idle =>

                    r_frame_tready <= '1';

                    if frame_tvalid = '1' then
                        sr_frame_data(to_integer(r_byte_idx) * 32 + 31 downto to_integer(r_byte_idx) * 32) <= frame_tdata;

                        if r_byte_idx = "11" then
                            r_byte_idx <= (others => '0');
                        else
                            r_byte_idx <= r_byte_idx + 1;
                        end if;
                    end if;

                -- Once we have 128 bits of data, store it in the burst buffer
                when wr_store_buffer =>
                    buf_burst(to_integer(r_burst_cnt)) <= sr_frame_data;

                    if r_burst_cnt = "111" then
                        r_burst_cnt <= (others => '0');
                    else
                        r_burst_cnt <= r_burst_cnt + 1;
                    end if;

                -- Start AXI4 write burst to DDR
                when wr_burst_start =>
                    if w_avmm_to_axi4_wr_avmm_busy = '0' and r_avmm_to_axi4_wr_avmm_write = '0' then
                        r_avmm_to_axi4_wr_avmm_address <= std_logic_vector(C_base_address + resize(r_write_ddr_address * 128, 29));
                        r_avmm_to_axi4_wr_avmm_write   <= '1';
                        r_burst_cnt                    <= (others => '0');
                    end if;

                -- Write burst data to DDR - one 128-bit word per cycle for 8 cycles (total burst length of 1024 bits)
                when wr_burst_data =>
                    r_avmm_to_axi4_wr_avmm_write     <= '1';
                    r_avmm_to_axi4_wr_avmm_writedata <= buf_burst(to_integer(r_burst_cnt));

                    if r_burst_cnt = "111" then
                        r_burst_cnt <= (others => '0');
                    else
                        r_burst_cnt <= r_burst_cnt + 1;
                    end if;

                -- After writing 8 words, wait for the burst to complete
                when wr_burst_wait =>
                    if w_avmm_to_axi4_wr_avmm_busy = '0' then
                        if r_write_ddr_address = ((w_write_limit + 1) / C_BURST_LEN - 1) then
                            r_write_ddr_address <= (others => '0');
                            r_rd_address_gen    <= '1';
                        else
                            r_write_ddr_address <= r_write_ddr_address + 1;
                        end if;
                    end if;

                -- Start reading a DDR word
                when rd_phase =>

                    -- Generate read addresses and control signals for reading from DDR
                    if r_rd_address_gen = '1' then

                        r_ddr_offset <= resize(resize(r_rd_address_current_row * C_COLS + r_rd_address_current_column, 29)(28 downto 7), 29);
                        fifo_din     <= std_logic_vector(resize(r_rd_address_current_row * C_COLS + r_rd_address_current_column, 7));

                        if w_avmm_to_axi4_rd_avmm_busy = '0' and r_avmm_to_axi4_rd_avmm_address_val = '0' then
                            r_avmm_to_axi4_rd_avmm_address     <= std_logic_vector(resize(C_base_address + r_ddr_offset * 16, 29));
                            r_avmm_to_axi4_rd_avmm_address_val <= '1';
                            fifo_wr_en                         <= '1';

                            if (r_rd_address_current_column = C_COLS - 1) and (r_rd_address_current_row = C_ROWS - 1) then
                                r_rd_address_current_row    <= (others => '0');
                                r_rd_address_current_column <= (others => '0');
                                r_rd_address_gen            <= '0';
                            elsif r_rd_address_current_row = C_ROWS - 1 then
                                r_rd_address_current_row    <= (others => '0');
                                r_rd_address_current_column <= r_rd_address_current_column + 1;
                            else
                                r_rd_address_current_row <= r_rd_address_current_row + 1;
                            end if;
                        elsif w_avmm_to_axi4_rd_avmm_busy = '1' and r_avmm_to_axi4_rd_avmm_address_val = '1' then
                            r_avmm_to_axi4_rd_avmm_address_val <= '1';
                            r_avmm_to_axi4_rd_avmm_address     <= r_avmm_to_axi4_rd_avmm_address;
                            fifo_wr_en                         <= '0';
                        else
                            r_avmm_to_axi4_rd_avmm_address_val <= '0';
                            fifo_wr_en                         <= '0';
                        end if;

                    else
                        r_avmm_to_axi4_rd_avmm_address_val <= '0';
                        fifo_wr_en                         <= '0';
                    end if;

                    -- Capture read data from DDR and send it out over AXI4-Stream after reordering
                    if w_avmm_to_axi4_rd_avmm_readdata_val = '1' then

                        r_out_data(to_integer(r_bit_idx)) <= w_avmm_to_axi4_rd_avmm_readdata(to_integer(unsigned(fifo_dout)));

                        if r_bit_idx = to_unsigned(31, r_bit_idx'length) then
                            r_bit_idx <= (others => '0');
                        else
                            r_bit_idx <= r_bit_idx + 1;
                        end if;

                        r_write_ddr_address <= r_write_ddr_address + 1;

                        if r_write_ddr_address = C_COLS * C_ROWS - 1 then
                            r_out_last <= '1';
                            case r_bit_idx is
                                when "00111" => r_tkeep <= "0001";
                                when "01111" => r_tkeep <= "0011";
                                when "10111" => r_tkeep <= "0111";
                                when others   => r_tkeep <= "1111";

                            end case;
                        else
                            r_out_last <= '0';
                            r_tkeep    <= "1111";

                        end if;

                    end if;

                    -- send the data and associated sideband signals out over AXI4-Stream
                    if (r_bit_idx = to_unsigned(0, r_bit_idx'length) and (r_write_ddr_address > 0)) then
                        if (frame_intrlvd_tready = '1') and (r_frame_intrlvd_tvalid = '0') then
                            r_frame_intrlvd_tdata  <= r_out_data;
                            r_frame_intrlvd_tuser  <= frame_tuser;
                            r_frame_intrlvd_tlast  <= r_out_last;
                            r_frame_intrlvd_tkeep  <= r_tkeep;
                            r_frame_intrlvd_tvalid <= '1';
                        elsif (frame_intrlvd_tready = '1') and (r_frame_intrlvd_tvalid = '1') then
                            r_frame_intrlvd_tvalid <= '0';
                            r_frame_intrlvd_tlast  <= '0';
                            r_frame_intrlvd_tkeep  <= (others => '0');
                            r_frame_intrlvd_tdata  <= (others => '0');
                            r_frame_intrlvd_tuser  <= (others => '0');

                            if r_write_ddr_address = C_COLS * C_ROWS then
                                r_write_ddr_address <= (others => '0');
                            end if;
                        end if;

                    end if;

            end case;
            current_state <= next_state;

        end if;
    end process;

    process(current_state, r_byte_idx, r_burst_cnt, w_avmm_to_axi4_wr_avmm_busy, frame_intrlvd_tready, r_frame_intrlvd_tvalid, r_write_ddr_address, r_bit_idx, w_write_limit)
    begin
        case current_state is

            when wr_idle =>
                if r_byte_idx = "11" then
                    next_state <= wr_store_buffer;
                else
                    next_state <= current_state;
                end if;

            when wr_store_buffer =>
                if r_burst_cnt = "111" then
                    next_state <= wr_burst_start;
                else
                    next_state <= wr_idle;
                end if;

            when wr_burst_start =>
                if w_avmm_to_axi4_wr_avmm_busy = '1' then
                    next_state <= wr_burst_data;
                else
                    next_state <= current_state;
                end if;

            when wr_burst_data =>
                if r_burst_cnt = "111" then
                    next_state <= wr_burst_wait;
                else
                    next_state <= wr_burst_data;
                end if;

            when wr_burst_wait =>
                if w_avmm_to_axi4_wr_avmm_busy = '0' then
                    if r_write_ddr_address = ((w_write_limit + 1) / C_BURST_LEN - 1) then
                        next_state <= rd_phase;
                    else
                        next_state <= wr_idle;
                    end if;
                end if;

            when rd_phase =>

                if r_frame_intrlvd_tvalid = '1' and frame_intrlvd_tready = '1' then
                    if r_write_ddr_address = C_COLS * C_ROWS then
                        next_state <= wr_idle;
                    else
                        next_state <= rd_phase;
                    end if;
                else
                    next_state <= current_state;
                end if;
        end case;
    end process;

    -- Output assignments
    frame_tready         <= r_frame_tready;
    frame_intrlvd_tdata  <= r_frame_intrlvd_tdata;
    frame_intrlvd_tlast  <= r_frame_intrlvd_tlast;
    frame_intrlvd_tkeep  <= r_frame_intrlvd_tkeep;
    frame_intrlvd_tuser  <= r_frame_intrlvd_tuser;
    frame_intrlvd_tvalid <= r_frame_intrlvd_tvalid;

    fifo_rd_en <= w_avmm_to_axi4_rd_avmm_readdata_val;
    fifo_rst   <= not axis_resetn;

    w_write_limit <= resize((C_COLS * C_ROWS) / 128 - 1, 29);

    xpm_fifo_sync_inst : xpm_fifo_sync
        generic map(
            CASCADE_HEIGHT      => 0,   -- DECIMAL
            DOUT_RESET_VALUE    => "0", -- String
            ECC_MODE            => "no_ecc", -- String
          --  EN_SIM_ASSERT_ERR   => "warning", -- String
            FIFO_MEMORY_TYPE    => "auto", -- String
            FIFO_READ_LATENCY   => 0,   -- DECIMAL
            FIFO_WRITE_DEPTH    => 128, -- DECIMAL
            FULL_RESET_VALUE    => 0,   -- DECIMAL
            PROG_EMPTY_THRESH   => 10,  -- DECIMAL
            PROG_FULL_THRESH    => 10,  -- DECIMAL
            RD_DATA_COUNT_WIDTH => 1,   -- DECIMAL
            READ_DATA_WIDTH     => 7,   -- DECIMAL
            READ_MODE           => "std", -- String
            SIM_ASSERT_CHK      => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            USE_ADV_FEATURES    => "1707", -- String
            WAKEUP_TIME         => 0,   -- DECIMAL
            WRITE_DATA_WIDTH    => 7,   -- DECIMAL
            WR_DATA_COUNT_WIDTH => 1
        )
        port map(
            dout          => fifo_dout,
            din           => fifo_din,
            rd_en         => fifo_rd_en,
            wr_clk        => axis_clk,
            sleep         => '0',
            rst           => fifo_rst,
            wr_en         => fifo_wr_en,
            injectsbiterr => '0',
            empty         => open,
            injectdbiterr => '0'
        );

    avmm_to_axi4_wr_inst : avmm_to_axi4_wr
        generic map(
            g_ADDR_WIDTH => 29,
            g_DATA_WIDTH => 128
        )
        port map(
            axi_aresetn       => axis_resetn,
            axi_aclk          => axis_clk,
            avmm_s_write      => r_avmm_to_axi4_wr_avmm_write,
            avmm_s_address    => r_avmm_to_axi4_wr_avmm_address,
            avmm_s_writedata  => r_avmm_to_axi4_wr_avmm_writedata,
            avmm_s_busy       => w_avmm_to_axi4_wr_avmm_busy,
            axi_m_axi_awid    => ddr4_m_axi_awid,
            axi_m_axi_awaddr  => ddr4_m_axi_awaddr,
            axi_m_axi_awlen   => ddr4_m_axi_awlen,
            axi_m_axi_awsize  => ddr4_m_axi_awsize,
            axi_m_axi_awburst => ddr4_m_axi_awburst,
            axi_m_axi_awlock  => ddr4_m_axi_awlock,
            axi_m_axi_awcache => ddr4_m_axi_awcache,
            axi_m_axi_awprot  => ddr4_m_axi_awprot,
            axi_m_axi_awqos   => ddr4_m_axi_awqos,
            axi_m_axi_awvalid => ddr4_m_axi_awvalid,
            axi_m_axi_awready => ddr4_m_axi_awready,
            axi_m_axi_wdata   => ddr4_m_axi_wdata,
            axi_m_axi_wstrb   => ddr4_m_axi_wstrb,
            axi_m_axi_wlast   => ddr4_m_axi_wlast,
            axi_m_axi_wvalid  => ddr4_m_axi_wvalid,
            axi_m_axi_wready  => ddr4_m_axi_wready,
            axi_m_axi_bready  => ddr4_m_axi_bready,
            axi_m_axi_bid     => ddr4_m_axi_bid,
            axi_m_axi_bresp   => ddr4_m_axi_bresp,
            axi_m_axi_bvalid  => ddr4_m_axi_bvalid
        );

    avmm_to_axi4_rd_inst : avmm_to_axi4_rd
        generic map(
            g_ADDR_WIDTH => 29,         -- keep default or change as needed
            g_DATA_WIDTH => 128         -- keep default or change as needed
        )
        port map(
            axi_aresetn         => axis_resetn,
            axi_aclk            => axis_clk,
            avmm_s_read         => r_avmm_to_axi4_rd_avmm_read,
            avmm_s_address      => r_avmm_to_axi4_rd_avmm_address,
            avmm_s_address_val  => r_avmm_to_axi4_rd_avmm_address_val,
            avmm_s_readdata_val => w_avmm_to_axi4_rd_avmm_readdata_val,
            avmm_s_readdata     => w_avmm_to_axi4_rd_avmm_readdata,
            avmm_s_busy         => w_avmm_to_axi4_rd_avmm_busy,
            axi_m_axi_arid      => ddr4_m_axi_arid,
            axi_m_axi_araddr    => ddr4_m_axi_araddr,
            axi_m_axi_arlen     => ddr4_m_axi_arlen,
            axi_m_axi_arsize    => ddr4_m_axi_arsize,
            axi_m_axi_arburst   => ddr4_m_axi_arburst,
            axi_m_axi_arlock    => ddr4_m_axi_arlock,
            axi_m_axi_arcache   => ddr4_m_axi_arcache,
            axi_m_axi_arprot    => ddr4_m_axi_arprot,
            axi_m_axi_arqos     => ddr4_m_axi_arqos,
            axi_m_axi_arvalid   => ddr4_m_axi_arvalid,
            axi_m_axi_arready   => ddr4_m_axi_arready,
            axi_m_axi_rready    => ddr4_m_axi_rready,
            axi_m_axi_rlast     => ddr4_m_axi_rlast,
            axi_m_axi_rvalid    => ddr4_m_axi_rvalid,
            axi_m_axi_rresp     => ddr4_m_axi_rresp,
            axi_m_axi_rid       => ddr4_m_axi_rid,
            axi_m_axi_rdata     => ddr4_m_axi_rdata
        );

end arc_mod_intrlv;
