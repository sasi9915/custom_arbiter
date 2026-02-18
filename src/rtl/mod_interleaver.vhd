library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;


entity mod_intrlv is

    port 
    (
        axis_resetn             : in std_logic;
        axis_clk                : in std_logic;
        
        frame_tready            : out std_logic;
        frame_tvalid            : in std_logic;
        frame_tuser             : in std_logic_vector(15 downto 00);
        frame_tdata             : in std_logic_vector(31 downto 00);
        frame_tkeep             : in std_logic_vector(03 downto 00);
        frame_tlast             : in std_logic;
        
        frame_intrlvd_tready    : in std_logic;
        frame_intrlvd_tvalid    : out std_logic;
        frame_intrlvd_tuser     : out std_logic_vector(15 downto 00);
        frame_intrlvd_tdata     : out std_logic_vector(31 downto 00);
        frame_intrlvd_tkeep     : out std_logic_vector(03 downto 00);
        frame_intrlvd_tlast     : out std_logic;

        ddr4_m_axi_awid         : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awaddr       : out std_logic_vector(28 downto 0);
        ddr4_m_axi_awlen        : out std_logic_vector(7 downto 0);
        ddr4_m_axi_awsize       : out std_logic_vector(2 downto 0);
        ddr4_m_axi_awburst      : out std_logic_vector(1 downto 0);
        ddr4_m_axi_awlock       : out std_logic_vector(0 downto 0);
        ddr4_m_axi_awcache      : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awprot       : out std_logic_vector(2 downto 0);
        ddr4_m_axi_awqos        : out std_logic_vector(3 downto 0);
        ddr4_m_axi_awvalid      : out std_logic;
        ddr4_m_axi_awready      : in std_logic;
        ddr4_m_axi_wdata        : out std_logic_vector(127 downto 0);
        ddr4_m_axi_wstrb        : out std_logic_vector(15 downto 0);
        ddr4_m_axi_wlast        : out std_logic;
        ddr4_m_axi_wvalid       : out std_logic;
        ddr4_m_axi_wready       : in std_logic;
        ddr4_m_axi_bready       : out std_logic;
        ddr4_m_axi_bid          : in std_logic_vector(3 downto 0);
        ddr4_m_axi_bresp        : in std_logic_vector(1 downto 0);
        ddr4_m_axi_bvalid       : in std_logic;
        ddr4_m_axi_arid         : out std_logic_vector(3 downto 0);
        ddr4_m_axi_araddr       : out std_logic_vector(28 downto 0);
        ddr4_m_axi_arlen        : out std_logic_vector(7 downto 0);
        ddr4_m_axi_arsize       : out std_logic_vector(2 downto 0);
        ddr4_m_axi_arburst      : out std_logic_vector(1 downto 0);
        ddr4_m_axi_arlock       : out std_logic_vector(0 downto 0);
        ddr4_m_axi_arcache      : out std_logic_vector(3 downto 0);
        ddr4_m_axi_arprot       : out std_logic_vector(2 downto 0);
        ddr4_m_axi_arqos        : out std_logic_vector(3 downto 0);
        ddr4_m_axi_arvalid      : out std_logic;
        ddr4_m_axi_arready      : in std_logic;
        ddr4_m_axi_rready       : out std_logic;
        ddr4_m_axi_rlast        : in std_logic;
        ddr4_m_axi_rvalid       : in std_logic;
        ddr4_m_axi_rresp        : in std_logic_vector(1 downto 0);
        ddr4_m_axi_rid          : in std_logic_vector(3 downto 0);
        ddr4_m_axi_rdata        : in std_logic_vector(127 downto 0)
    );

end entity;

architecture arc_mod_intrlv of mod_intrlv is

    -- Clocks & Resets
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_PARAMETER : string;

    attribute X_INTERFACE_INFO of axis_clk    : signal is "xilinx.com:signal:clock:1.0 axis_clk CLK";
    attribute X_INTERFACE_PARAMETER of axis_clk : signal is "ASSOCIATED_BUSIF frame:frame_intrlvd:ddr4_m, ASSOCIATED_RESET axis_resetn";

    attribute X_INTERFACE_INFO of axis_resetn : signal is "xilinx.com:signal:reset:1.0 axis_resetn RST";
    attribute X_INTERFACE_PARAMETER of axis_resetn : signal is "POLARITY ACTIVE_LOW";


    -- AXI4-Stream Slave (frame)
    attribute X_INTERFACE_INFO of frame_tvalid : signal is "xilinx.com:interface:axis:1.0 frame TVALID";
    attribute X_INTERFACE_INFO of frame_tready : signal is "xilinx.com:interface:axis:1.0 frame TREADY";
    attribute X_INTERFACE_INFO of frame_tuser  : signal is "xilinx.com:interface:axis:1.0 frame TUSER";
    attribute X_INTERFACE_INFO of frame_tdata  : signal is "xilinx.com:interface:axis:1.0 frame TDATA";
    attribute X_INTERFACE_INFO of frame_tkeep  : signal is "xilinx.com:interface:axis:1.0 frame TKEEP";
    attribute X_INTERFACE_INFO of frame_tlast  : signal is "xilinx.com:interface:axis:1.0 frame TLAST";
    attribute X_INTERFACE_PARAMETER of frame_tdata : signal is "TDATA_NUM_BYTES 4, TUSER_WIDTH 16, HAS_TKEEP 1, HAS_TLAST 1";

    -- AXI4-Stream Master (frame_intrlvd)
    attribute X_INTERFACE_INFO of frame_intrlvd_tvalid : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TVALID";
    attribute X_INTERFACE_INFO of frame_intrlvd_tready : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TREADY";
    attribute X_INTERFACE_INFO of frame_intrlvd_tuser  : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TUSER";
    attribute X_INTERFACE_INFO of frame_intrlvd_tdata  : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TDATA";
    attribute X_INTERFACE_INFO of frame_intrlvd_tkeep  : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TKEEP";
    attribute X_INTERFACE_INFO of frame_intrlvd_tlast  : signal is "xilinx.com:interface:axis:1.0 frame_intrlvd TLAST";
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
    generic 
    (
        g_ADDR_WIDTH : integer := 29;
        g_DATA_WIDTH : integer := 128
    );
    port 
    (
        axi_aresetn         : in  std_logic;
        axi_aclk            : in  std_logic;

        avmm_s_write        : in  std_logic;
        avmm_s_address      : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        avmm_s_writedata    : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
        avmm_s_busy         : out std_logic;

        axi_m_axi_awid      : out std_logic_vector(3 downto 0);
        axi_m_axi_awaddr    : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        axi_m_axi_awlen     : out std_logic_vector(7 downto 0);
        axi_m_axi_awsize    : out std_logic_vector(2 downto 0);
        axi_m_axi_awburst   : out std_logic_vector(1 downto 0);
        axi_m_axi_awlock    : out std_logic_vector(0 downto 0);
        axi_m_axi_awcache   : out std_logic_vector(3 downto 0);
        axi_m_axi_awprot    : out std_logic_vector(2 downto 0);
        axi_m_axi_awqos     : out std_logic_vector(3 downto 0);
        axi_m_axi_awvalid   : out std_logic;
        axi_m_axi_awready   : in  std_logic;
        axi_m_axi_wdata     : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
        axi_m_axi_wstrb     : out std_logic_vector(15 downto 0);
        axi_m_axi_wlast     : out std_logic;
        axi_m_axi_wvalid    : out std_logic;
        axi_m_axi_wready    : in  std_logic;
        axi_m_axi_bready    : out std_logic;
        axi_m_axi_bid       : in  std_logic_vector(3 downto 0);
        axi_m_axi_bresp     : in  std_logic_vector(1 downto 0);
        axi_m_axi_bvalid    : in  std_logic
    );
    end component;

    component avmm_to_axi4_rd
    generic
    (
        g_ADDR_WIDTH : integer := 29;
        g_DATA_WIDTH : integer := 128
    );
    port
    (
        axi_aresetn          : in  std_logic;
        axi_aclk             : in  std_logic;

        avmm_s_read          : in  std_logic;
        avmm_s_address       : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        avmm_s_readdata_val  : out std_logic;
        avmm_s_readdata      : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
        avmm_s_busy          : out std_logic;

        axi_m_axi_arid       : out std_logic_vector(3 downto 0);
        axi_m_axi_araddr     : out std_logic_vector(28 downto 0);
        axi_m_axi_arlen      : out std_logic_vector(7 downto 0);
        axi_m_axi_arsize     : out std_logic_vector(2 downto 0);
        axi_m_axi_arburst    : out std_logic_vector(1 downto 0);
        axi_m_axi_arlock     : out std_logic_vector(0 downto 0);
        axi_m_axi_arcache    : out std_logic_vector(3 downto 0);
        axi_m_axi_arprot     : out std_logic_vector(2 downto 0);
        axi_m_axi_arqos      : out std_logic_vector(3 downto 0);
        axi_m_axi_arvalid    : out std_logic;
        axi_m_axi_arready    : in  std_logic;
        axi_m_axi_rready     : out std_logic;
        axi_m_axi_rlast      : in  std_logic;
        axi_m_axi_rvalid     : in  std_logic;
        axi_m_axi_rresp      : in  std_logic_vector(1 downto 0);
        axi_m_axi_rid        : in  std_logic_vector(3 downto 0);
        axi_m_axi_rdata      : in  std_logic_vector(127 downto 0)
    );
    end component;

    -- Component IOs
    signal r_avmm_to_axi4_wr_avmm_write                : std_logic;
    signal r_avmm_to_axi4_wr_avmm_address              : std_logic_vector(28 downto 0);
    signal r_avmm_to_axi4_wr_avmm_writedata            : std_logic_vector(127 downto 0);
    signal w_avmm_to_axi4_wr_avmm_busy                 : std_logic;


    signal r_avmm_to_axi4_rd_avmm_read                 : std_logic;
    signal r_avmm_to_axi4_rd_avmm_address              : std_logic_vector(28 downto 0);
    signal w_avmm_to_axi4_rd_avmm_readdata_val         : std_logic;
    signal w_avmm_to_axi4_rd_avmm_readdata             : std_logic_vector(127 downto 0);
    signal w_avmm_to_axi4_rd_avmm_busy                 : std_logic;

    -- Temp Signals

    signal dbg_counter                                  : integer := 0;


    


begin

  
    
    process(axis_resetn, axis_clk) is
    begin
        if axis_resetn = '0' then

            -- Output Registers
            frame_tready            <= '0';

            frame_intrlvd_tvalid    <= '0';
            frame_intrlvd_tuser     <= (others => '0');
            frame_intrlvd_tdata     <= (others => '0');
            frame_intrlvd_tkeep     <= (others => '0');
            frame_intrlvd_tlast     <= '0';



            r_avmm_to_axi4_wr_avmm_write          <= '0';
            r_avmm_to_axi4_wr_avmm_address        <= (others => '0');
            r_avmm_to_axi4_wr_avmm_writedata      <= (others => '0');

            r_avmm_to_axi4_rd_avmm_read           <= '0';
            r_avmm_to_axi4_rd_avmm_address        <= (others => '0');

            

            dbg_counter <= 0;

        elsif axis_clk'event and axis_clk = '1' then

            frame_tready            <= '1';

            frame_intrlvd_tvalid    <= '0';
            frame_intrlvd_tuser     <= (others => '0');
            frame_intrlvd_tdata     <= (others => '0');
            frame_intrlvd_tkeep     <= (others => '0');
            frame_intrlvd_tlast     <= '0';


            dbg_counter <= dbg_counter + 1;

            if dbg_counter = 100 then

                r_avmm_to_axi4_wr_avmm_write          <= '1';
                r_avmm_to_axi4_wr_avmm_address        <= std_logic_vector(to_unsigned(1000, 29));
                r_avmm_to_axi4_wr_avmm_writedata      <= X"0123456789ABCDEF1011121314151617";

                r_avmm_to_axi4_rd_avmm_read           <= '0';
                r_avmm_to_axi4_rd_avmm_address        <= (others => '0');
            

            elsif dbg_counter = 1500 then

                r_avmm_to_axi4_wr_avmm_write          <= '1';
                r_avmm_to_axi4_wr_avmm_address        <= std_logic_vector(to_unsigned(2000, 29));
                r_avmm_to_axi4_wr_avmm_writedata      <= X"89ABCDEF012345671011121314151617";


                r_avmm_to_axi4_rd_avmm_read           <= '1';
                r_avmm_to_axi4_rd_avmm_address        <= std_logic_vector(to_unsigned(1000, 29));

            else

                r_avmm_to_axi4_wr_avmm_write          <= '0';
                r_avmm_to_axi4_wr_avmm_address        <= (others => '0');
                r_avmm_to_axi4_wr_avmm_writedata      <= (others => '0');

                r_avmm_to_axi4_rd_avmm_read           <= '0';
                r_avmm_to_axi4_rd_avmm_address        <= (others => '0');

            end if;



        end if;
    end process;




    avmm_to_axi4_wr_inst : avmm_to_axi4_wr
    generic map 
    (
        g_ADDR_WIDTH => 29,
        g_DATA_WIDTH => 128
    )
    port map 
    (
        axi_aresetn         => axis_resetn,
        axi_aclk            => axis_clk,

        avmm_s_write        => r_avmm_to_axi4_wr_avmm_write,
        avmm_s_address      => r_avmm_to_axi4_wr_avmm_address,
        avmm_s_writedata    => r_avmm_to_axi4_wr_avmm_writedata,
        avmm_s_busy         => w_avmm_to_axi4_wr_avmm_busy,

        axi_m_axi_awid      => ddr4_m_axi_awid,
        axi_m_axi_awaddr    => ddr4_m_axi_awaddr,
        axi_m_axi_awlen     => ddr4_m_axi_awlen,
        axi_m_axi_awsize    => ddr4_m_axi_awsize,
        axi_m_axi_awburst   => ddr4_m_axi_awburst,
        axi_m_axi_awlock    => ddr4_m_axi_awlock,
        axi_m_axi_awcache   => ddr4_m_axi_awcache,
        axi_m_axi_awprot    => ddr4_m_axi_awprot,
        axi_m_axi_awqos     => ddr4_m_axi_awqos,
        axi_m_axi_awvalid   => ddr4_m_axi_awvalid,
        axi_m_axi_awready   => ddr4_m_axi_awready,

        axi_m_axi_wdata     => ddr4_m_axi_wdata,
        axi_m_axi_wstrb     => ddr4_m_axi_wstrb,
        axi_m_axi_wlast     => ddr4_m_axi_wlast,
        axi_m_axi_wvalid    => ddr4_m_axi_wvalid,
        axi_m_axi_wready    => ddr4_m_axi_wready,

        axi_m_axi_bready    => ddr4_m_axi_bready,
        axi_m_axi_bid       => ddr4_m_axi_bid,
        axi_m_axi_bresp     => ddr4_m_axi_bresp,
        axi_m_axi_bvalid    => ddr4_m_axi_bvalid
    );


    avmm_to_axi4_rd_inst : avmm_to_axi4_rd
    generic map
    (
        g_ADDR_WIDTH => 29,   -- keep default or change as needed
        g_DATA_WIDTH => 128   -- keep default or change as needed
    )
    port map
    (
        axi_aresetn          => axis_resetn,
        axi_aclk             => axis_clk,

        avmm_s_read          => r_avmm_to_axi4_rd_avmm_read,
        avmm_s_address       => r_avmm_to_axi4_rd_avmm_address,
        avmm_s_readdata_val  => w_avmm_to_axi4_rd_avmm_readdata_val,
        avmm_s_readdata      => w_avmm_to_axi4_rd_avmm_readdata,
        avmm_s_busy          => w_avmm_to_axi4_rd_avmm_busy,

        axi_m_axi_arid       => ddr4_m_axi_arid,
        axi_m_axi_araddr     => ddr4_m_axi_araddr,
        axi_m_axi_arlen      => ddr4_m_axi_arlen,
        axi_m_axi_arsize     => ddr4_m_axi_arsize,
        axi_m_axi_arburst    => ddr4_m_axi_arburst,
        axi_m_axi_arlock     => ddr4_m_axi_arlock,
        axi_m_axi_arcache    => ddr4_m_axi_arcache,
        axi_m_axi_arprot     => ddr4_m_axi_arprot,
        axi_m_axi_arqos      => ddr4_m_axi_arqos,
        axi_m_axi_arvalid    => ddr4_m_axi_arvalid,
        axi_m_axi_arready    => ddr4_m_axi_arready,
        axi_m_axi_rready     => ddr4_m_axi_rready,
        axi_m_axi_rlast      => ddr4_m_axi_rlast,
        axi_m_axi_rvalid     => ddr4_m_axi_rvalid,
        axi_m_axi_rresp      => ddr4_m_axi_rresp,
        axi_m_axi_rid        => ddr4_m_axi_rid,
        axi_m_axi_rdata      => ddr4_m_axi_rdata
    );




end arc_mod_intrlv;
