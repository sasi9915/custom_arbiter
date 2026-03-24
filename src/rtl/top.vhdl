library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

entity top_loop_back is
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
        -- -- mod_intrlv AXI Master Interface (to connect to AXI Interconnect)
        -- frame_intrlvd_tready : in  std_logic;
        -- frame_intrlvd_tvalid : out std_logic;
        -- frame_intrlvd_tuser  : out std_logic_vector(15 downto 00);
        -- frame_intrlvd_tdata  : out std_logic_vector(31 downto 00);
        -- frame_intrlvd_tkeep  : out std_logic_vector(03 downto 00);
        -- frame_intrlvd_tlast  : out std_logic;
        -- demodulator AXI-Stream Interface
        -- demod_frame_tready       : out std_logic;
        -- demod_frame_tvalid       : in  std_logic;
        -- demod_frame_tuser        : in  std_logic_vector(15 downto 0);
        -- demod_frame_tdata        : in  std_logic_vector(31 downto 0);
        -- demod_frame_tkeep        : in  std_logic_vector(3 downto 0);
        -- demod_frame_tlast        : in  std_logic;
        -- demod_deintrlv AXI Master Interface (to connect to AXI Interconnect)
        frame_deintrlvd_tready : in  std_logic;
        frame_deintrlvd_tvalid : out std_logic;
        frame_deintrlvd_tuser  : out std_logic_vector(15 downto 0);
        frame_deintrlvd_tdata  : out std_logic_vector(31 downto 0);
        frame_deintrlvd_tkeep  : out std_logic_vector(3 downto 0);
        frame_deintrlvd_tlast  : out std_logic;
        --
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
end entity top_loop_back;

architecture rtl of top_loop_back is

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

    -- Function declaration for LLR mapping
    function llr_mapper(input_bits : std_logic_vector(1 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(31 downto 0);
        variable temp   : signed(15 downto 0);
    begin
        for i in 0 to 1 loop
            if input_bits(i) = '1' then
                temp := to_signed(32767, 16); -- +127
            else
                temp := to_signed(-32767, 16); -- -127
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

    -- Internal signals for connecting mod_intrlv to demod_deintrlv
    signal w_frame_intrlvd_tready : std_logic;
    signal w_frame_intrlvd_tvalid : std_logic;
    signal w_frame_intrlvd_tuser  : std_logic_vector(15 downto 0);
    signal w_frame_intrlvd_tdata  : std_logic_vector(31 downto 0);
    signal w_frame_intrlvd_tkeep  : std_logic_vector(3 downto 0);
    signal w_frame_intrlvd_tlast  : std_logic;

    -- Internal signals for connecting demod_deintrlv to output AXI-Stream
    signal w_demod_frame_tready : std_logic;
    signal r_demod_frame_tvalid : std_logic;
    signal r_demod_frame_tuser  : std_logic_vector(15 downto 0);
    signal r_demod_frame_tdata  : std_logic_vector(31 downto 0);
    signal r_demod_frame_tkeep  : std_logic_vector(3 downto 0);
    signal r_demod_frame_tlast  : std_logic;

    -- Internal signals for fetch counter and control
    signal r_fetch_counter : unsigned(4 downto 0) := (others => '0');
    signal r_fetch_req     : std_logic            := 'U';
    signal r_tvalid        : std_logic            := '0';
    signal r_intrlvd_tuser : std_logic_vector(15 downto 0);
    signal r_intrlvd_tkeep : std_logic_vector(3 downto 0);
    signal r_intrlvd_tlast : std_logic;
    signal r_intrlvd_tdata : std_logic_vector(31 downto 0);

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

begin

    main_processs : process(axis_clk, axis_resetn)
    begin
        if axis_resetn = '0' then
            r_fetch_counter      <= (others => '0');
            r_fetch_req          <= '0';
            r_demod_frame_tdata  <= (others => '0');
            r_demod_frame_tuser  <= (others => '0');
            r_demod_frame_tkeep  <= (others => '0');
            r_demod_frame_tlast  <= ('0');
            r_demod_frame_tvalid <= ('0');

            r_intrlvd_tuser <= (others => '0');
            r_intrlvd_tkeep <= (others => '0');
            r_intrlvd_tlast <= '0';
            r_intrlvd_tdata <= (others => '0');
            r_tvalid        <= '0';

        elsif (rising_edge(axis_clk)) then
            r_demod_frame_tkeep <= (others => '1');
            -- r_demod_frame_tvalid <= '0';
            -- r_demod_frame_tlast  <= '0';

            if w_frame_intrlvd_tvalid = '1' and w_frame_intrlvd_tready = '1' and w_frame_intrlvd_tlast = '1' then
                r_intrlvd_tlast <= '1';
            elsif w_frame_intrlvd_tvalid = '1' and w_frame_intrlvd_tready = '1' then
                r_intrlvd_tlast <= '0';
            end if;

            if w_frame_intrlvd_tvalid = '1' and w_frame_intrlvd_tready = '1' then
                -- r_intrlvd_tuser <= w_frame_intrlvd_tuser;
                -- r_intrlvd_tkeep <= w_frame_intrlvd_tkeep;
                r_intrlvd_tdata <= w_frame_intrlvd_tdata;
                -- r_fetch_counter <= (others => '0');
                r_tvalid        <= '1';

            elsif r_tvalid = '1' and w_demod_frame_tready = '1' then
                r_demod_frame_tuser <= r_intrlvd_tuser;

                case to_integer(r_fetch_counter) is

                    when 0 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(1 downto 0));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(0);
                    when 1 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(3 downto 2));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(0);
                    when 2 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(5 downto 4));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(0);
                    when 3 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(7 downto 6));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(0);
                    when 4 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(9 downto 8));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(1);
                    when 5 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(11 downto 10));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(1);
                    when 6 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(13 downto 12));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(1);
                    when 7 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(15 downto 14));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(1);
                    when 8 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(17 downto 16));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(2);
                    when 9 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(19 downto 18));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(2);
                    when 10 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(21 downto 20));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(2);
                    when 11 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(23 downto 22));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(2);
                    when 12 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(25 downto 24));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(3);
                    when 13 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(27 downto 26));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(3);
                    when 14 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(29 downto 28));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(3);
                    when 15 =>
                        r_demod_frame_tdata  <= llr_mapper(r_intrlvd_tdata(31 downto 30));
                        r_fetch_req          <= '0';
                        r_demod_frame_tlast  <= r_intrlvd_tlast;
                        r_demod_frame_tvalid <= r_tvalid and w_frame_intrlvd_tkeep(3);
                    when 16 =>
                        r_demod_frame_tdata  <= (others => '0');
                        r_fetch_req          <= not r_fetch_req;
                        r_demod_frame_tlast  <= '0';
                        r_demod_frame_tvalid <= '0';
                        r_tvalid             <= w_frame_intrlvd_tvalid;
                    when others =>
                        r_demod_frame_tdata  <= (others => '0');
                        r_fetch_req          <= '1';
                        r_demod_frame_tvalid <= '0';
                        r_demod_frame_tlast  <= '0';

                end case;

                if r_fetch_counter = to_unsigned(16, 5) then
                    r_fetch_counter <= (others => '0');

                else
                    r_fetch_counter <= r_fetch_counter + to_unsigned(1, 5);
                end if;
            elsif w_demod_frame_tready = '1' then
                r_demod_frame_tdata  <= (others => '0');
                r_demod_frame_tvalid <= '0';
                r_demod_frame_tlast  <= '0';
                r_fetch_req          <= '1';
            end if;

        end if;
    end process;

    -- Ready signal for mod_intrlv
    w_frame_intrlvd_tready <= r_fetch_req and w_demod_frame_tready;

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
    --
    -- Custom AXI interconnect instance
    u_axi_interconnect : entity work.axi_custom_int_2slot
        port map(
            S00_AXI_ACLK    => axis_clk,
            S00_AXI_ARESETN => axis_resetn,
            S00_AXI_AWID    => slot0_awid(0 downto 0),
            S00_AXI_AWADDR  => slot0_awaddr,
            S00_AXI_AWLEN   => slot0_awlen,
            S00_AXI_AWSIZE  => slot0_awsize,
            S00_AXI_AWBURST => slot0_awburst,
            S00_AXI_AWLOCK  => slot0_awlock(0),
            S00_AXI_AWCACHE => slot0_awcache,
            S00_AXI_AWPROT  => slot0_awprot,
            S00_AXI_AWQOS   => slot0_awqos,
            S00_AXI_AWVALID => slot0_awvalid,
            S00_AXI_AWREADY => slot0_awready,
            S00_AXI_WDATA   => slot0_wdata,
            S00_AXI_WSTRB   => slot0_wstrb,
            S00_AXI_WLAST   => slot0_wlast,
            S00_AXI_WVALID  => slot0_wvalid,
            S00_AXI_WREADY  => slot0_wready,
            S00_AXI_BID     => slot0_bid(0 downto 0),
            S00_AXI_BRESP   => slot0_bresp,
            S00_AXI_BVALID  => slot0_bvalid,
            S00_AXI_BREADY  => slot0_bready,
            S00_AXI_ARID    => slot0_arid(0 downto 0),
            S00_AXI_ARADDR  => slot0_araddr,
            S00_AXI_ARLEN   => slot0_arlen,
            S00_AXI_ARSIZE  => slot0_arsize,
            S00_AXI_ARBURST => slot0_arburst,
            S00_AXI_ARLOCK  => slot0_arlock(0),
            S00_AXI_ARCACHE => slot0_arcache,
            S00_AXI_ARPROT  => slot0_arprot,
            S00_AXI_ARQOS   => slot0_arqos,
            S00_AXI_ARVALID => slot0_arvalid,
            S00_AXI_ARREADY => slot0_arready,
            S00_AXI_RID     => slot0_rid(0 downto 0),
            S00_AXI_RDATA   => slot0_rdata,
            S00_AXI_RRESP   => slot0_rresp,
            S00_AXI_RLAST   => slot0_rlast,
            S00_AXI_RVALID  => slot0_rvalid,
            S00_AXI_RREADY  => slot0_rready,
            S01_AXI_AWID    => slot1_awid(0 downto 0),
            S01_AXI_AWADDR  => slot1_awaddr,
            S01_AXI_AWLEN   => slot1_awlen,
            S01_AXI_AWSIZE  => slot1_awsize,
            S01_AXI_AWBURST => slot1_awburst,
            S01_AXI_AWLOCK  => slot1_awlock(0),
            S01_AXI_AWCACHE => slot1_awcache,
            S01_AXI_AWPROT  => slot1_awprot,
            S01_AXI_AWQOS   => slot1_awqos,
            S01_AXI_AWVALID => slot1_awvalid,
            S01_AXI_AWREADY => slot1_awready,
            S01_AXI_WDATA   => slot1_wdata,
            S01_AXI_WSTRB   => slot1_wstrb,
            S01_AXI_WLAST   => slot1_wlast,
            S01_AXI_WVALID  => slot1_wvalid,
            S01_AXI_WREADY  => slot1_wready,
            S01_AXI_BID     => slot1_bid(0 downto 0),
            S01_AXI_BRESP   => slot1_bresp,
            S01_AXI_BVALID  => slot1_bvalid,
            S01_AXI_BREADY  => slot1_bready,
            S01_AXI_ARID    => slot1_arid(0 downto 0),
            S01_AXI_ARADDR  => slot1_araddr,
            S01_AXI_ARLEN   => slot1_arlen,
            S01_AXI_ARSIZE  => slot1_arsize,
            S01_AXI_ARBURST => slot1_arburst,
            S01_AXI_ARLOCK  => slot1_arlock(0),
            S01_AXI_ARCACHE => slot1_arcache,
            S01_AXI_ARPROT  => slot1_arprot,
            S01_AXI_ARQOS   => slot1_arqos,
            S01_AXI_ARVALID => slot1_arvalid,
            S01_AXI_ARREADY => slot1_arready,
            S01_AXI_RID     => slot1_rid(0 downto 0),
            S01_AXI_RDATA   => slot1_rdata,
            S01_AXI_RRESP   => slot1_rresp,
            S01_AXI_RLAST   => slot1_rlast,
            S01_AXI_RVALID  => slot1_rvalid,
            S01_AXI_RREADY  => slot1_rready,
            M_AXI_AWID      => M_AXI_AWID,
            M_AXI_AWADDR    => M_AXI_AWADDR,
            M_AXI_AWLEN     => M_AXI_AWLEN,
            M_AXI_AWSIZE    => M_AXI_AWSIZE,
            M_AXI_AWBURST   => M_AXI_AWBURST,
            M_AXI_AWLOCK    => M_AXI_AWLOCK,
            M_AXI_AWCACHE   => M_AXI_AWCACHE,
            M_AXI_AWPROT    => M_AXI_AWPROT,
            M_AXI_AWQOS     => M_AXI_AWQOS,
            M_AXI_AWVALID   => M_AXI_AWVALID,
            M_AXI_AWREADY   => M_AXI_AWREADY,
            M_AXI_WDATA     => M_AXI_WDATA,
            M_AXI_WSTRB     => M_AXI_WSTRB,
            M_AXI_WLAST     => M_AXI_WLAST,
            M_AXI_WVALID    => M_AXI_WVALID,
            M_AXI_WREADY    => M_AXI_WREADY,
            M_AXI_BID       => M_AXI_BID,
            M_AXI_BRESP     => M_AXI_BRESP,
            M_AXI_BVALID    => M_AXI_BVALID,
            M_AXI_BREADY    => M_AXI_BREADY,
            M_AXI_ARID      => M_AXI_ARID,
            M_AXI_ARADDR    => M_AXI_ARADDR,
            M_AXI_ARLEN     => M_AXI_ARLEN,
            M_AXI_ARSIZE    => M_AXI_ARSIZE,
            M_AXI_ARBURST   => M_AXI_ARBURST,
            M_AXI_ARLOCK    => M_AXI_ARLOCK,
            M_AXI_ARCACHE   => M_AXI_ARCACHE,
            M_AXI_ARPROT    => M_AXI_ARPROT,
            M_AXI_ARQOS     => M_AXI_ARQOS,
            M_AXI_ARVALID   => M_AXI_ARVALID,
            M_AXI_ARREADY   => M_AXI_ARREADY,
            M_AXI_RID       => M_AXI_RID,
            M_AXI_RDATA     => M_AXI_RDATA,
            M_AXI_RRESP     => M_AXI_RRESP,
            M_AXI_RLAST     => M_AXI_RLAST,
            M_AXI_RVALID    => M_AXI_RVALID,
            M_AXI_RREADY    => M_AXI_RREADY
        );

end architecture rtl;
