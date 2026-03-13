library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

entity top is
    port(
        -- AXI-Stream Interface
        axis_resetn            : in  std_logic;
        axis_clk               : in  std_logic;
        -- mod_intrlv AXI Master Interface (to connect to AXI Interconnect)
        mod_frame_tready       : out std_logic;
        mod_frame_tvalid       : in  std_logic;
        mod_frame_tuser        : in  std_logic_vector(15 downto 00);
        mod_frame_tdata        : in  std_logic_vector(31 downto 00);
        mod_frame_tkeep        : in  std_logic_vector(03 downto 00);
        mod_frame_tlast        : in  std_logic;
        frame_intrlvd_tready   : in  std_logic;
        frame_intrlvd_tvalid   : out std_logic;
        frame_intrlvd_tuser    : out std_logic_vector(15 downto 00);
        frame_intrlvd_tdata    : out std_logic_vector(31 downto 00);
        frame_intrlvd_tkeep    : out std_logic_vector(03 downto 00);
        frame_intrlvd_tlast    : out std_logic;
        -- demod_deintrlv AXI Master Interface (to connect to AXI Interconnect)
        demod_frame_tready     : out std_logic;
        demod_frame_tvalid     : in  std_logic;
        demod_frame_tuser      : in  std_logic_vector(15 downto 0);
        demod_frame_tdata      : in  std_logic_vector(31 downto 0);
        demod_frame_tkeep      : in  std_logic_vector(3 downto 0);
        demod_frame_tlast      : in  std_logic;
        frame_deintrlvd_tready : in  std_logic;
        frame_deintrlvd_tvalid : out std_logic;
        frame_deintrlvd_tuser  : out std_logic_vector(15 downto 0);
        frame_deintrlvd_tdata  : out std_logic_vector(31 downto 0);
        frame_deintrlvd_tkeep  : out std_logic_vector(3 downto 0);
        frame_deintrlvd_tlast  : out std_logic;
        -- Exposed AXI Master Interface (to connect DDR4 externally)
        M_AXI_AWID             : out std_logic_vector(3 downto 0);
        M_AXI_AWADDR           : out std_logic_vector(28 downto 0);
        M_AXI_AWLEN            : out std_logic_vector(7 downto 0);
        M_AXI_AWSIZE           : out std_logic_vector(2 downto 0);
        M_AXI_AWBURST          : out std_logic_vector(1 downto 0);
        M_AXI_AWLOCK           : out std_logic;
        M_AXI_AWCACHE          : out std_logic_vector(3 downto 0);
        M_AXI_AWPROT           : out std_logic_vector(2 downto 0);
        M_AXI_AWQOS            : out std_logic_vector(3 downto 0);
        M_AXI_AWVALID          : out std_logic;
        M_AXI_AWREADY          : in  std_logic;
        M_AXI_WDATA            : out std_logic_vector(127 downto 0);
        M_AXI_WSTRB            : out std_logic_vector(15 downto 0);
        M_AXI_WLAST            : out std_logic;
        M_AXI_WVALID           : out std_logic;
        M_AXI_WREADY           : in  std_logic;
        M_AXI_BID              : in  std_logic_vector(3 downto 0);
        M_AXI_BRESP            : in  std_logic_vector(1 downto 0);
        M_AXI_BVALID           : in  std_logic;
        M_AXI_BREADY           : out std_logic;
        M_AXI_ARID             : out std_logic_vector(3 downto 0);
        M_AXI_ARADDR           : out std_logic_vector(28 downto 0);
        M_AXI_ARLEN            : out std_logic_vector(7 downto 0);
        M_AXI_ARSIZE           : out std_logic_vector(2 downto 0);
        M_AXI_ARBURST          : out std_logic_vector(1 downto 0);
        M_AXI_ARLOCK           : out std_logic;
        M_AXI_ARCACHE          : out std_logic_vector(3 downto 0);
        M_AXI_ARPROT           : out std_logic_vector(2 downto 0);
        M_AXI_ARQOS            : out std_logic_vector(3 downto 0);
        M_AXI_ARVALID          : out std_logic;
        M_AXI_ARREADY          : in  std_logic;
        M_AXI_RID              : in  std_logic_vector(3 downto 0);
        M_AXI_RDATA            : in  std_logic_vector(127 downto 0);
        M_AXI_RRESP            : in  std_logic_vector(1 downto 0);
        M_AXI_RLAST            : in  std_logic;
        M_AXI_RVALID           : in  std_logic;
        M_AXI_RREADY           : out std_logic
    );
end entity top;

architecture rtl of top is

    component mod_intrlv is
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
    end component mod_intrlv;

    component demod_deintrlv is
        port(
            axis_resetn            : in  std_logic;
            axis_clk               : in  std_logic;
            frame_tready           : out std_logic;
            frame_tvalid           : in  std_logic;
            frame_tuser            : in  std_logic_vector(15 downto 00);
            frame_tdata            : in  std_logic_vector(31 downto 00);
            frame_tkeep            : in  std_logic_vector(03 downto 00);
            frame_tlast            : in  std_logic;
            frame_deintrlvd_tready : in  std_logic;
            frame_deintrlvd_tvalid : out std_logic;
            frame_deintrlvd_tuser  : out std_logic_vector(15 downto 00);
            frame_deintrlvd_tdata  : out std_logic_vector(31 downto 00);
            frame_deintrlvd_tkeep  : out std_logic_vector(03 downto 00);
            frame_deintrlvd_tlast  : out std_logic;
            ddr4_m_axi_awid        : out std_logic_vector(3 downto 0);
            ddr4_m_axi_awaddr      : out std_logic_vector(28 downto 0);
            ddr4_m_axi_awlen       : out std_logic_vector(7 downto 0);
            ddr4_m_axi_awsize      : out std_logic_vector(2 downto 0);
            ddr4_m_axi_awburst     : out std_logic_vector(1 downto 0);
            ddr4_m_axi_awlock      : out std_logic_vector(0 downto 0);
            ddr4_m_axi_awcache     : out std_logic_vector(3 downto 0);
            ddr4_m_axi_awprot      : out std_logic_vector(2 downto 0);
            ddr4_m_axi_awqos       : out std_logic_vector(3 downto 0);
            ddr4_m_axi_awvalid     : out std_logic;
            ddr4_m_axi_awready     : in  std_logic;
            ddr4_m_axi_wdata       : out std_logic_vector(127 downto 0);
            ddr4_m_axi_wstrb       : out std_logic_vector(15 downto 0);
            ddr4_m_axi_wlast       : out std_logic;
            ddr4_m_axi_wvalid      : out std_logic;
            ddr4_m_axi_wready      : in  std_logic;
            ddr4_m_axi_bready      : out std_logic;
            ddr4_m_axi_bid         : in  std_logic_vector(3 downto 0);
            ddr4_m_axi_bresp       : in  std_logic_vector(1 downto 0);
            ddr4_m_axi_bvalid      : in  std_logic;
            ddr4_m_axi_arid        : out std_logic_vector(3 downto 0);
            ddr4_m_axi_araddr      : out std_logic_vector(28 downto 0);
            ddr4_m_axi_arlen       : out std_logic_vector(7 downto 0);
            ddr4_m_axi_arsize      : out std_logic_vector(2 downto 0);
            ddr4_m_axi_arburst     : out std_logic_vector(1 downto 0);
            ddr4_m_axi_arlock      : out std_logic_vector(0 downto 0);
            ddr4_m_axi_arcache     : out std_logic_vector(3 downto 0);
            ddr4_m_axi_arprot      : out std_logic_vector(2 downto 0);
            ddr4_m_axi_arqos       : out std_logic_vector(3 downto 0);
            ddr4_m_axi_arvalid     : out std_logic;
            ddr4_m_axi_arready     : in  std_logic;
            ddr4_m_axi_rready      : out std_logic;
            ddr4_m_axi_rlast       : in  std_logic;
            ddr4_m_axi_rvalid      : in  std_logic;
            ddr4_m_axi_rresp       : in  std_logic_vector(1 downto 0);
            ddr4_m_axi_rid         : in  std_logic_vector(3 downto 0);
            ddr4_m_axi_rdata       : in  std_logic_vector(127 downto 0)
        );
    end component demod_deintrlv;

    
    function llr_mapper_16(input_bits : std_logic_vector(1 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(31 downto 0);
        variable temp   : signed(15 downto 0);
    begin
        for i in 0 to 1 loop
            if input_bits(i) = '1' then
                temp := to_signed(32767, 16);
            else
                temp := to_signed(-32767, 16);
            end if;
            result((i * 16 + 15) downto (i * 16)) := std_logic_vector(temp);
        end loop;
        return result;
    end function;

    -- Internal signals for connecting mod_intrlv to AXI interconnect
    signal slot0_awid    : std_logic_vector(3 downto 0);
    signal slot0_awaddr  : std_logic_vector(28 downto 0);
    signal slot0_awlen   : std_logic_vector(7 downto 0);
    signal slot0_awsize  : std_logic_vector(2 downto 0);
    signal slot0_awburst : std_logic_vector(1 downto 0);
    signal slot0_awlock  : std_logic_vector(0 downto 0);
    signal slot0_awcache : std_logic_vector(3 downto 0);
    signal slot0_awprot  : std_logic_vector(2 downto 0);
    signal slot0_awqos   : std_logic_vector(3 downto 0);
    signal slot0_awvalid : std_logic;
    signal slot0_awready : std_logic;
    signal slot0_wdata   : std_logic_vector(127 downto 0);
    signal slot0_wstrb   : std_logic_vector(15 downto 0);
    signal slot0_wlast   : std_logic;
    signal slot0_wvalid  : std_logic;
    signal slot0_wready  : std_logic;
    signal slot0_bid     : std_logic_vector(3 downto 0);
    signal slot0_bresp   : std_logic_vector(1 downto 0);
    signal slot0_bvalid  : std_logic;
    signal slot0_bready  : std_logic;
    signal slot0_arid    : std_logic_vector(3 downto 0);
    signal slot0_araddr  : std_logic_vector(28 downto 0);
    signal slot0_arlen   : std_logic_vector(7 downto 0);
    signal slot0_arsize  : std_logic_vector(2 downto 0);
    signal slot0_arburst : std_logic_vector(1 downto 0);
    signal slot0_arlock  : std_logic_vector(0 downto 0);
    signal slot0_arcache : std_logic_vector(3 downto 0);
    signal slot0_arprot  : std_logic_vector(2 downto 0);
    signal slot0_arqos   : std_logic_vector(3 downto 0);
    signal slot0_arvalid : std_logic;
    signal slot0_arready : std_logic;
    signal slot0_rid     : std_logic_vector(3 downto 0);
    signal slot0_rdata   : std_logic_vector(127 downto 0);
    signal slot0_rresp   : std_logic_vector(1 downto 0);
    signal slot0_rlast   : std_logic;
    signal slot0_rvalid  : std_logic;
    signal slot0_rready  : std_logic;
    signal slot0_resetn  : std_logic;

    -- Internal signals for looping mod output stream to deinterleaver input stream.
    signal w_frame_intrlvd_tready : std_logic;
    signal w_frame_intrlvd_tvalid : std_logic;
    signal w_frame_intrlvd_tuser  : std_logic_vector(15 downto 0);
    signal w_frame_intrlvd_tdata  : std_logic_vector(31 downto 0);
    signal w_frame_intrlvd_tkeep  : std_logic_vector(3 downto 0);
    signal w_frame_intrlvd_tlast  : std_logic;

    signal w_demod_frame_tready : std_logic;
    signal r_demod_frame_tvalid : std_logic := '0';
    signal r_demod_frame_tuser  : std_logic_vector(15 downto 0) := (others => '0');
    signal r_demod_frame_tdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal r_demod_frame_tkeep  : std_logic_vector(3 downto 0) := (others => '0');
    signal r_demod_frame_tlast  : std_logic := '0';

    signal r_fetch_counter : unsigned(4 downto 0) := (others => '0');
    signal r_fetch_req     : std_logic := '1';
    signal r_tvalid        : std_logic := '0';
    signal r_intrlvd_tlast : std_logic := '0';
    signal r_intrlvd_tdata : std_logic_vector(31 downto 0) := (others => '0');
    signal r_intrlvd_tuser : std_logic_vector(15 downto 0) := (others => '0');
    signal r_intrlvd_tkeep : std_logic_vector(3 downto 0) := (others => '0');

    -- Internal signals for connecting demod_deintrlv to AXI interconnect
    signal slot1_awid    : std_logic_vector(3 downto 0);
    signal slot1_awaddr  : std_logic_vector(28 downto 0);
    signal slot1_awlen   : std_logic_vector(7 downto 0);
    signal slot1_awsize  : std_logic_vector(2 downto 0);
    signal slot1_awburst : std_logic_vector(1 downto 0);
    signal slot1_awlock  : std_logic_vector(0 downto 0);
    signal slot1_awcache : std_logic_vector(3 downto 0);
    signal slot1_awprot  : std_logic_vector(2 downto 0);
    signal slot1_awqos   : std_logic_vector(3 downto 0);
    signal slot1_awvalid : std_logic;
    signal slot1_awready : std_logic;
    signal slot1_wdata   : std_logic_vector(127 downto 0);
    signal slot1_wstrb   : std_logic_vector(15 downto 0);
    signal slot1_wlast   : std_logic;
    signal slot1_wvalid  : std_logic;
    signal slot1_wready  : std_logic;
    signal slot1_bid     : std_logic_vector(3 downto 0);
    signal slot1_bresp   : std_logic_vector(1 downto 0);
    signal slot1_bvalid  : std_logic;
    signal slot1_bready  : std_logic;
    signal slot1_arid    : std_logic_vector(3 downto 0);
    signal slot1_araddr  : std_logic_vector(28 downto 0);
    signal slot1_arlen   : std_logic_vector(7 downto 0);
    signal slot1_arsize  : std_logic_vector(2 downto 0);
    signal slot1_arburst : std_logic_vector(1 downto 0);
    signal slot1_arlock  : std_logic_vector(0 downto 0);
    signal slot1_arcache : std_logic_vector(3 downto 0);
    signal slot1_arprot  : std_logic_vector(2 downto 0);
    signal slot1_arqos   : std_logic_vector(3 downto 0);
    signal slot1_arvalid : std_logic;
    signal slot1_arready : std_logic;
    signal slot1_rid     : std_logic_vector(3 downto 0);
    signal slot1_rdata   : std_logic_vector(127 downto 0);
    signal slot1_rresp   : std_logic_vector(1 downto 0);
    signal slot1_rlast   : std_logic;
    signal slot1_rvalid  : std_logic;
    signal slot1_rready  : std_logic;
    signal slot1_resetn  : std_logic;

begin

    -- s0/s1 side IDs are 1-bit on the interconnect-facing side.
    slot0_bid(3 downto 1) <= (others => '0');
    slot0_rid(3 downto 1) <= (others => '0');
    slot1_bid(3 downto 1) <= (others => '0');
    slot1_rid(3 downto 1) <= (others => '0');

    -- Keep mod output visible at top-level and feed internal 16-bit-LLR loopback.
    frame_intrlvd_tvalid <= w_frame_intrlvd_tvalid;
    frame_intrlvd_tuser  <= w_frame_intrlvd_tuser;
    frame_intrlvd_tdata  <= w_frame_intrlvd_tdata;
    frame_intrlvd_tkeep  <= w_frame_intrlvd_tkeep;
    frame_intrlvd_tlast  <= w_frame_intrlvd_tlast;
    demod_frame_tready   <= w_demod_frame_tready;

    -- Pull next interleaved word only when the demod/deinterleaver side is ready.
    w_frame_intrlvd_tready <= r_fetch_req and w_demod_frame_tready;

    loopback_16llr_proc : process(axis_clk, axis_resetn)
    begin
        if axis_resetn = '0' then
            r_fetch_counter      <= (others => '0');
            r_fetch_req          <= '1';
            r_tvalid             <= '0';
            r_intrlvd_tlast      <= '0';
            r_intrlvd_tdata      <= (others => '0');
            r_intrlvd_tuser      <= (others => '0');
            r_intrlvd_tkeep      <= (others => '0');
            r_demod_frame_tdata  <= (others => '0');
            r_demod_frame_tuser  <= (others => '0');
            r_demod_frame_tkeep  <= (others => '0');
            r_demod_frame_tlast  <= '0';
            r_demod_frame_tvalid <= '0';
        elsif rising_edge(axis_clk) then
            r_demod_frame_tvalid <= '0';
            r_demod_frame_tlast  <= '0';
            r_demod_frame_tkeep  <= (others => '1');

            if w_frame_intrlvd_tvalid = '1' and w_frame_intrlvd_tready = '1' then
                r_intrlvd_tdata <= w_frame_intrlvd_tdata;
                r_intrlvd_tuser <= w_frame_intrlvd_tuser;
                r_intrlvd_tkeep <= w_frame_intrlvd_tkeep;
                r_intrlvd_tlast <= w_frame_intrlvd_tlast;
                r_tvalid        <= '1';
                r_fetch_req     <= '0';
                r_fetch_counter <= (others => '0');
            elsif r_tvalid = '1' and w_demod_frame_tready = '1' then
                r_demod_frame_tuser <= r_intrlvd_tuser;

                case to_integer(r_fetch_counter) is
                    when 0 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(1 downto 0));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(0);
                    when 1 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(3 downto 2));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(0);
                    when 2 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(5 downto 4));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(0);
                    when 3 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(7 downto 6));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(0);
                    when 4 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(9 downto 8));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(1);
                    when 5 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(11 downto 10));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(1);
                    when 6 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(13 downto 12));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(1);
                    when 7 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(15 downto 14));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(1);
                    when 8 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(17 downto 16));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(2);
                    when 9 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(19 downto 18));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(2);
                    when 10 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(21 downto 20));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(2);
                    when 11 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(23 downto 22));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(2);
                    when 12 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(25 downto 24));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(3);
                    when 13 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(27 downto 26));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(3);
                    when 14 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(29 downto 28));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(3);
                    when 15 =>
                        r_demod_frame_tdata  <= llr_mapper_16(r_intrlvd_tdata(31 downto 30));
                        r_demod_frame_tvalid <= r_intrlvd_tkeep(3);
                        r_demod_frame_tlast  <= r_intrlvd_tlast;
                    when others =>
                        r_demod_frame_tdata  <= (others => '0');
                        r_demod_frame_tvalid <= '0';
                end case;

                if r_fetch_counter = to_unsigned(15, r_fetch_counter'length) then
                    r_fetch_counter <= (others => '0');
                    r_fetch_req     <= '1';
                    r_tvalid        <= '0';
                else
                    r_fetch_counter <= r_fetch_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- mod_intrlv instance
    u_mod_intrlv : mod_intrlv
        port map(
            axis_resetn          => axis_resetn,
            axis_clk             => axis_clk,
            frame_tready         => mod_frame_tready,
            frame_tvalid         => mod_frame_tvalid,
            frame_tuser          => mod_frame_tuser,
            frame_tdata          => mod_frame_tdata,
            frame_tkeep          => mod_frame_tkeep,
            frame_tlast          => mod_frame_tlast,
            frame_intrlvd_tready => w_frame_intrlvd_tready,
            frame_intrlvd_tvalid => w_frame_intrlvd_tvalid,
            frame_intrlvd_tuser  => w_frame_intrlvd_tuser,
            frame_intrlvd_tdata  => w_frame_intrlvd_tdata,
            frame_intrlvd_tkeep  => w_frame_intrlvd_tkeep,
            frame_intrlvd_tlast  => w_frame_intrlvd_tlast,
            -- Connect to internal AXI signals
            ddr4_m_axi_awid      => slot0_awid,
            ddr4_m_axi_awaddr    => slot0_awaddr,
            ddr4_m_axi_awlen     => slot0_awlen,
            ddr4_m_axi_awsize    => slot0_awsize,
            ddr4_m_axi_awburst   => slot0_awburst,
            ddr4_m_axi_awlock    => slot0_awlock,
            ddr4_m_axi_awcache   => slot0_awcache,
            ddr4_m_axi_awprot    => slot0_awprot,
            ddr4_m_axi_awqos     => slot0_awqos,
            ddr4_m_axi_awvalid   => slot0_awvalid,
            ddr4_m_axi_awready   => slot0_awready,
            ddr4_m_axi_wdata     => slot0_wdata,
            ddr4_m_axi_wstrb     => slot0_wstrb,
            ddr4_m_axi_wlast     => slot0_wlast,
            ddr4_m_axi_wvalid    => slot0_wvalid,
            ddr4_m_axi_wready    => slot0_wready,
            ddr4_m_axi_bready    => slot0_bready,
            ddr4_m_axi_bid       => slot0_bid,
            ddr4_m_axi_bresp     => slot0_bresp,
            ddr4_m_axi_bvalid    => slot0_bvalid,
            ddr4_m_axi_arid      => slot0_arid,
            ddr4_m_axi_araddr    => slot0_araddr,
            ddr4_m_axi_arlen     => slot0_arlen,
            ddr4_m_axi_arsize    => slot0_arsize,
            ddr4_m_axi_arburst   => slot0_arburst,
            ddr4_m_axi_arlock    => slot0_arlock,
            ddr4_m_axi_arcache   => slot0_arcache,
            ddr4_m_axi_arprot    => slot0_arprot,
            ddr4_m_axi_arqos     => slot0_arqos,
            ddr4_m_axi_arvalid   => slot0_arvalid,
            ddr4_m_axi_arready   => slot0_arready,
            ddr4_m_axi_rready    => slot0_rready,
            ddr4_m_axi_rlast     => slot0_rlast,
            ddr4_m_axi_rvalid    => slot0_rvalid,
            ddr4_m_axi_rresp     => slot0_rresp,
            ddr4_m_axi_rid       => slot0_rid,
            ddr4_m_axi_rdata     => slot0_rdata
        );

    -- demod_deintrlv instance
    u_demod_deintrlv : demod_deintrlv
        port map(
            axis_resetn            => axis_resetn,
            axis_clk               => axis_clk,
            frame_tready           => w_demod_frame_tready,
            frame_tvalid           => r_demod_frame_tvalid,
            frame_tuser            => r_demod_frame_tuser,
            frame_tdata            => r_demod_frame_tdata,
            frame_tkeep            => r_demod_frame_tkeep,
            frame_tlast            => r_demod_frame_tlast,
            frame_deintrlvd_tready => frame_deintrlvd_tready,
            frame_deintrlvd_tvalid => frame_deintrlvd_tvalid,
            frame_deintrlvd_tuser  => frame_deintrlvd_tuser,
            frame_deintrlvd_tdata  => frame_deintrlvd_tdata,
            frame_deintrlvd_tkeep  => frame_deintrlvd_tkeep,
            frame_deintrlvd_tlast  => frame_deintrlvd_tlast,
            -- Connect to internal AXI signals
            ddr4_m_axi_awid        => slot1_awid,
            ddr4_m_axi_awaddr      => slot1_awaddr,
            ddr4_m_axi_awlen       => slot1_awlen,
            ddr4_m_axi_awsize      => slot1_awsize,
            ddr4_m_axi_awburst     => slot1_awburst,
            ddr4_m_axi_awlock      => slot1_awlock,
            ddr4_m_axi_awcache     => slot1_awcache,
            ddr4_m_axi_awprot      => slot1_awprot,
            ddr4_m_axi_awqos       => slot1_awqos,
            ddr4_m_axi_awvalid     => slot1_awvalid,
            ddr4_m_axi_awready     => slot1_awready,
            ddr4_m_axi_wdata       => slot1_wdata,
            ddr4_m_axi_wstrb       => slot1_wstrb,
            ddr4_m_axi_wlast       => slot1_wlast,
            ddr4_m_axi_wvalid      => slot1_wvalid,
            ddr4_m_axi_wready      => slot1_wready,
            ddr4_m_axi_bid         => slot1_bid,
            ddr4_m_axi_bresp       => slot1_bresp,
            ddr4_m_axi_bvalid      => slot1_bvalid,
            ddr4_m_axi_bready      => slot1_bready,
            ddr4_m_axi_arid        => slot1_arid,
            ddr4_m_axi_araddr      => slot1_araddr,
            ddr4_m_axi_arlen       => slot1_arlen,
            ddr4_m_axi_arsize      => slot1_arsize,
            ddr4_m_axi_arburst     => slot1_arburst,
            ddr4_m_axi_arlock      => slot1_arlock,
            ddr4_m_axi_arcache     => slot1_arcache,
            ddr4_m_axi_arprot      => slot1_arprot,
            ddr4_m_axi_arqos       => slot1_arqos,
            ddr4_m_axi_arvalid     => slot1_arvalid,
            ddr4_m_axi_arready     => slot1_arready,
            ddr4_m_axi_rready      => slot1_rready,
            ddr4_m_axi_rlast       => slot1_rlast,
            ddr4_m_axi_rvalid      => slot1_rvalid,
            ddr4_m_axi_rresp       => slot1_rresp,
            ddr4_m_axi_rid         => slot1_rid,
            ddr4_m_axi_rdata       => slot1_rdata
        );

    -- Custom AXI interconnect instance
    u_axi_interconnect : entity work.axi_custom_int_2slot
        port map(
            aclk       => axis_clk,
            aresetn    => axis_resetn,
            s0_awid    => slot0_awid(0 downto 0),
            s0_awaddr  => slot0_awaddr,
            s0_awlen   => slot0_awlen,
            s0_awsize  => slot0_awsize,
            s0_awburst => slot0_awburst,
            s0_awlock  => slot0_awlock(0),
            s0_awcache => slot0_awcache,
            s0_awprot  => slot0_awprot,
            s0_awqos   => slot0_awqos,
            s0_awvalid => slot0_awvalid,
            s0_awready => slot0_awready,
            s0_wdata   => slot0_wdata,
            s0_wstrb   => slot0_wstrb,
            s0_wlast   => slot0_wlast,
            s0_wvalid  => slot0_wvalid,
            s0_wready  => slot0_wready,
            s0_bid     => slot0_bid(0 downto 0),
            s0_bresp   => slot0_bresp,
            s0_bvalid  => slot0_bvalid,
            s0_bready  => slot0_bready,
            s0_arid    => slot0_arid(0 downto 0),
            s0_araddr  => slot0_araddr,
            s0_arlen   => slot0_arlen,
            s0_arsize  => slot0_arsize,
            s0_arburst => slot0_arburst,
            s0_arlock  => slot0_arlock(0),
            s0_arcache => slot0_arcache,
            s0_arprot  => slot0_arprot,
            s0_arqos   => slot0_arqos,
            s0_arvalid => slot0_arvalid,
            s0_arready => slot0_arready,
            s0_rid     => slot0_rid(0 downto 0),
            s0_rdata   => slot0_rdata,
            s0_rresp   => slot0_rresp,
            s0_rlast   => slot0_rlast,
            s0_rvalid  => slot0_rvalid,
            s0_rready  => slot0_rready,
            s1_awid    => slot1_awid(0 downto 0),
            s1_awaddr  => slot1_awaddr,
            s1_awlen   => slot1_awlen,
            s1_awsize  => slot1_awsize,
            s1_awburst => slot1_awburst,
            s1_awlock  => slot1_awlock(0),
            s1_awcache => slot1_awcache,
            s1_awprot  => slot1_awprot,
            s1_awqos   => slot1_awqos,
            s1_awvalid => slot1_awvalid,
            s1_awready => slot1_awready,
            s1_wdata   => slot1_wdata,
            s1_wstrb   => slot1_wstrb,
            s1_wlast   => slot1_wlast,
            s1_wvalid  => slot1_wvalid,
            s1_wready  => slot1_wready,
            s1_bid     => slot1_bid(0 downto 0),
            s1_bresp   => slot1_bresp,
            s1_bvalid  => slot1_bvalid,
            s1_bready  => slot1_bready,
            s1_arid    => slot1_arid(0 downto 0),
            s1_araddr  => slot1_araddr,
            s1_arlen   => slot1_arlen,
            s1_arsize  => slot1_arsize,
            s1_arburst => slot1_arburst,
            s1_arlock  => slot1_arlock(0),
            s1_arcache => slot1_arcache,
            s1_arprot  => slot1_arprot,
            s1_arqos   => slot1_arqos,
            s1_arvalid => slot1_arvalid,
            s1_arready => slot1_arready,
            s1_rid     => slot1_rid(0 downto 0),
            s1_rdata   => slot1_rdata,
            s1_rresp   => slot1_rresp,
            s1_rlast   => slot1_rlast,
            s1_rvalid  => slot1_rvalid,
            s1_rready  => slot1_rready,
            m_awid     => M_AXI_AWID,
            m_awaddr   => M_AXI_AWADDR,
            m_awlen    => M_AXI_AWLEN,
            m_awsize   => M_AXI_AWSIZE,
            m_awburst  => M_AXI_AWBURST,
            m_awlock   => M_AXI_AWLOCK,
            m_awcache  => M_AXI_AWCACHE,
            m_awprot   => M_AXI_AWPROT,
            m_awqos    => M_AXI_AWQOS,
            m_awvalid  => M_AXI_AWVALID,
            m_awready  => M_AXI_AWREADY,
            m_wdata    => M_AXI_WDATA,
            m_wstrb    => M_AXI_WSTRB,
            m_wlast    => M_AXI_WLAST,
            m_wvalid   => M_AXI_WVALID,
            m_wready   => M_AXI_WREADY,
            m_bid      => M_AXI_BID,
            m_bresp    => M_AXI_BRESP,
            m_bvalid   => M_AXI_BVALID,
            m_bready   => M_AXI_BREADY,
            m_arid     => M_AXI_ARID,
            m_araddr   => M_AXI_ARADDR,
            m_arlen    => M_AXI_ARLEN,
            m_arsize   => M_AXI_ARSIZE,
            m_arburst  => M_AXI_ARBURST,
            m_arlock   => M_AXI_ARLOCK,
            m_arcache  => M_AXI_ARCACHE,
            m_arprot   => M_AXI_ARPROT,
            m_arqos    => M_AXI_ARQOS,
            m_arvalid  => M_AXI_ARVALID,
            m_arready  => M_AXI_ARREADY,
            m_rid      => M_AXI_RID,
            m_rdata    => M_AXI_RDATA,
            m_rresp    => M_AXI_RRESP,
            m_rlast    => M_AXI_RLAST,
            m_rvalid   => M_AXI_RVALID,
            m_rready   => M_AXI_RREADY
        );

end architecture rtl;
