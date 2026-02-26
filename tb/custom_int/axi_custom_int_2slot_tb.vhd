library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_xpm_fifo_sync_wrap is
    generic (
        g_TYPE                   : string  := "block";
        g_DATA_WIDTH             : natural := 10;
        g_DEPTH                  : natural := 2048;
        g_FWFT_MODE_ENA          : boolean := true;
        g_ALMOST_FULL_THRESHOLD  : integer := 1920;
        g_ALMOST_EMPTY_THRESHOLD : integer := 128
    );
    port (
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
end entity tb_xpm_fifo_sync_wrap;

architecture model of tb_xpm_fifo_sync_wrap is
    type mem_t is array (0 to g_DEPTH - 1) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);

    function f_inc_ptr(ptr : integer) return integer is
    begin
        if ptr = g_DEPTH - 1 then
            return 0;
        else
            return ptr + 1;
        end if;
    end function f_inc_ptr;

    signal mem   : mem_t := (others => (others => '0'));
    signal wrptr : integer range 0 to g_DEPTH - 1 := 0;
    signal rdptr : integer range 0 to g_DEPTH - 1 := 0;
    signal count : integer range 0 to g_DEPTH := 0;
    signal q_val : std_logic := '0';
begin
    process (i_clk, i_resetn)
        variable wr_fire : boolean;
        variable rd_fire : boolean;
    begin
        if i_resetn = '0' then
            wrptr <= 0;
            rdptr <= 0;
            count <= 0;
            q_val <= '0';
        elsif rising_edge(i_clk) then
            wr_fire := (i_wrreq = '1') and (count < g_DEPTH);
            rd_fire := (i_rdreq = '1') and (count > 0);

            if wr_fire then
                mem(wrptr) <= i_data;
                wrptr      <= f_inc_ptr(wrptr);
            end if;

            if rd_fire then
                rdptr <= f_inc_ptr(rdptr);
            end if;

            if wr_fire and (not rd_fire) then
                count <= count + 1;
            elsif rd_fire and (not wr_fire) then
                count <= count - 1;
            end if;

            if rd_fire then
                q_val <= '1';
            else
                q_val <= '0';
            end if;
        end if;
    end process;

    o_q            <= mem(rdptr);
    o_q_val        <= q_val;
    o_full         <= '1' when count = g_DEPTH else '0';
    o_empty        <= '1' when count = 0 else '0';
    o_almost_full  <= '1' when count >= g_ALMOST_FULL_THRESHOLD else '0';
    o_almost_empty <= '1' when count <= g_ALMOST_EMPTY_THRESHOLD else '0';
    o_usedw        <= std_logic_vector(to_unsigned(count, o_usedw'length));
end architecture model;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

configuration axi_custom_int_2slot_with_tb_fifo_cfg of axi_custom_int_2slot is
    for rtl
        for aw_slot0_fifo_inst : xpm_fifo_sync_wrap
            use entity work.tb_xpm_fifo_sync_wrap(model);
        end for;
        for aw_slot1_fifo_inst : xpm_fifo_sync_wrap
            use entity work.tb_xpm_fifo_sync_wrap(model);
        end for;
        for ar_slot0_fifo_inst : xpm_fifo_sync_wrap
            use entity work.tb_xpm_fifo_sync_wrap(model);
        end for;
        for ar_slot1_fifo_inst : xpm_fifo_sync_wrap
            use entity work.tb_xpm_fifo_sync_wrap(model);
        end for;
    end for;
end configuration axi_custom_int_2slot_with_tb_fifo_cfg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_custom_int_2slot_tb is
end entity axi_custom_int_2slot_tb;

architecture sim of axi_custom_int_2slot_tb is
    constant CLK_PERIOD : time := 10 ns;

    constant G_ADDR_WIDTH : positive := 29;
    constant G_DATA_WIDTH : positive := 128;
    constant G_S_ID_WIDTH : positive := 1;
    constant G_M_ID_WIDTH : positive := 4;

    signal aclk    : std_logic := '0';
    signal aresetn : std_logic := '0';

    signal s0_awid    : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := (others => '0');
    signal s0_awaddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s0_awlen   : std_logic_vector(7 downto 0) := (others => '0');
    signal s0_awsize  : std_logic_vector(2 downto 0) := (others => '0');
    signal s0_awburst : std_logic_vector(1 downto 0) := (others => '0');
    signal s0_awlock  : std_logic := '0';
    signal s0_awcache : std_logic_vector(3 downto 0) := (others => '0');
    signal s0_awprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal s0_awqos   : std_logic_vector(3 downto 0) := (others => '0');
    signal s0_awvalid : std_logic := '0';
    signal s0_awready : std_logic;
    signal s0_wdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s0_wstrb   : std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0) := (others => '0');
    signal s0_wlast   : std_logic := '0';
    signal s0_wvalid  : std_logic := '0';
    signal s0_wready  : std_logic;
    signal s0_bid     : std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
    signal s0_bresp   : std_logic_vector(1 downto 0);
    signal s0_bvalid  : std_logic;
    signal s0_bready  : std_logic := '1';
    signal s0_arid    : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := (others => '0');
    signal s0_araddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s0_arlen   : std_logic_vector(7 downto 0) := (others => '0');
    signal s0_arsize  : std_logic_vector(2 downto 0) := (others => '0');
    signal s0_arburst : std_logic_vector(1 downto 0) := (others => '0');
    signal s0_arlock  : std_logic := '0';
    signal s0_arcache : std_logic_vector(3 downto 0) := (others => '0');
    signal s0_arprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal s0_arqos   : std_logic_vector(3 downto 0) := (others => '0');
    signal s0_arvalid : std_logic := '0';
    signal s0_arready : std_logic;
    signal s0_rid     : std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
    signal s0_rdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal s0_rresp   : std_logic_vector(1 downto 0);
    signal s0_rlast   : std_logic;
    signal s0_rvalid  : std_logic;
    signal s0_rready  : std_logic := '1';

    signal s1_awid    : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := (others => '0');
    signal s1_awaddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s1_awlen   : std_logic_vector(7 downto 0) := (others => '0');
    signal s1_awsize  : std_logic_vector(2 downto 0) := (others => '0');
    signal s1_awburst : std_logic_vector(1 downto 0) := (others => '0');
    signal s1_awlock  : std_logic := '0';
    signal s1_awcache : std_logic_vector(3 downto 0) := (others => '0');
    signal s1_awprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal s1_awqos   : std_logic_vector(3 downto 0) := (others => '0');
    signal s1_awvalid : std_logic := '0';
    signal s1_awready : std_logic;
    signal s1_wdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s1_wstrb   : std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0) := (others => '0');
    signal s1_wlast   : std_logic := '0';
    signal s1_wvalid  : std_logic := '0';
    signal s1_wready  : std_logic;
    signal s1_bid     : std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
    signal s1_bresp   : std_logic_vector(1 downto 0);
    signal s1_bvalid  : std_logic;
    signal s1_bready  : std_logic := '1';
    signal s1_arid    : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := (others => '0');
    signal s1_araddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s1_arlen   : std_logic_vector(7 downto 0) := (others => '0');
    signal s1_arsize  : std_logic_vector(2 downto 0) := (others => '0');
    signal s1_arburst : std_logic_vector(1 downto 0) := (others => '0');
    signal s1_arlock  : std_logic := '0';
    signal s1_arcache : std_logic_vector(3 downto 0) := (others => '0');
    signal s1_arprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal s1_arqos   : std_logic_vector(3 downto 0) := (others => '0');
    signal s1_arvalid : std_logic := '0';
    signal s1_arready : std_logic;
    signal s1_rid     : std_logic_vector(G_S_ID_WIDTH - 1 downto 0);
    signal s1_rdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal s1_rresp   : std_logic_vector(1 downto 0);
    signal s1_rlast   : std_logic;
    signal s1_rvalid  : std_logic;
    signal s1_rready  : std_logic := '1';

    signal m_awid    : std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
    signal m_awaddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal m_awlen   : std_logic_vector(7 downto 0);
    signal m_awsize  : std_logic_vector(2 downto 0);
    signal m_awburst : std_logic_vector(1 downto 0);
    signal m_awlock  : std_logic;
    signal m_awcache : std_logic_vector(3 downto 0);
    signal m_awprot  : std_logic_vector(2 downto 0);
    signal m_awqos   : std_logic_vector(3 downto 0);
    signal m_awvalid : std_logic;
    signal m_awready : std_logic := '1';
    signal m_wdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal m_wstrb   : std_logic_vector(G_DATA_WIDTH / 8 - 1 downto 0);
    signal m_wlast   : std_logic;
    signal m_wvalid  : std_logic;
    signal m_wready  : std_logic := '1';
    signal m_bid     : std_logic_vector(G_M_ID_WIDTH - 1 downto 0) := (others => '0');
    signal m_bresp   : std_logic_vector(1 downto 0) := (others => '0');
    signal m_bvalid  : std_logic := '0';
    signal m_bready  : std_logic;
    signal m_arid    : std_logic_vector(G_M_ID_WIDTH - 1 downto 0);
    signal m_araddr  : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal m_arlen   : std_logic_vector(7 downto 0);
    signal m_arsize  : std_logic_vector(2 downto 0);
    signal m_arburst : std_logic_vector(1 downto 0);
    signal m_arlock  : std_logic;
    signal m_arcache : std_logic_vector(3 downto 0);
    signal m_arprot  : std_logic_vector(2 downto 0);
    signal m_arqos   : std_logic_vector(3 downto 0);
    signal m_arvalid : std_logic;
    signal m_arready : std_logic := '1';
    signal m_rid     : std_logic_vector(G_M_ID_WIDTH - 1 downto 0) := (others => '0');
    signal m_rdata   : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal m_rresp   : std_logic_vector(1 downto 0) := (others => '0');
    signal m_rlast   : std_logic := '0';
    signal m_rvalid  : std_logic := '0';
    signal m_rready  : std_logic;

    signal wr_rsp_pending : std_logic := '0';
    signal rd_rsp_pending : std_logic := '0';
    signal wr_id_hold     : std_logic_vector(G_M_ID_WIDTH - 1 downto 0) := (others => '0');
    signal rd_id_hold     : std_logic_vector(G_M_ID_WIDTH - 1 downto 0) := (others => '0');
    signal rd_addr_hold   : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := (others => '0');

    constant AW_SIZE_128B : std_logic_vector(2 downto 0) := "100";
    constant INCR_BURST   : std_logic_vector(1 downto 0) := "01";

    constant WR0_ID   : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := "0";
    constant WR1_ID   : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := "1";
    constant WR0_ADDR : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0100#, G_ADDR_WIDTH));
    constant WR1_ADDR : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0200#, G_ADDR_WIDTH));
    constant WR0_DATA : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#1A2A3A4#, G_DATA_WIDTH));
    constant WR1_DATA : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#1B2B3B4#, G_DATA_WIDTH));
    constant WRB_ID   : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := "0";
    constant WRB_ADDR : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0500#, G_ADDR_WIDTH));
    constant WRB_LEN  : std_logic_vector(7 downto 0) := x"07"; -- 8 beats

    constant RD0_ID   : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := "1";
    constant RD1_ID   : std_logic_vector(G_S_ID_WIDTH - 1 downto 0) := "0";
    constant RD0_ADDR : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0300#, G_ADDR_WIDTH));
    constant RD1_ADDR : std_logic_vector(G_ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0400#, G_ADDR_WIDTH));
begin
    aclk <= not aclk after CLK_PERIOD / 2;

    dut_i : configuration work.axi_custom_int_2slot_with_tb_fifo_cfg
        generic map (
            G_ADDR_WIDTH     => G_ADDR_WIDTH,
            G_DATA_WIDTH     => G_DATA_WIDTH,
            G_S_ID_WIDTH     => G_S_ID_WIDTH,
            G_M_ID_WIDTH     => G_M_ID_WIDTH,
            G_CMD_FIFO_DEPTH => 16
        )
        port map (
            aclk    => aclk,
            aresetn => aresetn,

            s0_awid    => s0_awid,
            s0_awaddr  => s0_awaddr,
            s0_awlen   => s0_awlen,
            s0_awsize  => s0_awsize,
            s0_awburst => s0_awburst,
            s0_awlock  => s0_awlock,
            s0_awcache => s0_awcache,
            s0_awprot  => s0_awprot,
            s0_awqos   => s0_awqos,
            s0_awvalid => s0_awvalid,
            s0_awready => s0_awready,
            s0_wdata   => s0_wdata,
            s0_wstrb   => s0_wstrb,
            s0_wlast   => s0_wlast,
            s0_wvalid  => s0_wvalid,
            s0_wready  => s0_wready,
            s0_bid     => s0_bid,
            s0_bresp   => s0_bresp,
            s0_bvalid  => s0_bvalid,
            s0_bready  => s0_bready,
            s0_arid    => s0_arid,
            s0_araddr  => s0_araddr,
            s0_arlen   => s0_arlen,
            s0_arsize  => s0_arsize,
            s0_arburst => s0_arburst,
            s0_arlock  => s0_arlock,
            s0_arcache => s0_arcache,
            s0_arprot  => s0_arprot,
            s0_arqos   => s0_arqos,
            s0_arvalid => s0_arvalid,
            s0_arready => s0_arready,
            s0_rid     => s0_rid,
            s0_rdata   => s0_rdata,
            s0_rresp   => s0_rresp,
            s0_rlast   => s0_rlast,
            s0_rvalid  => s0_rvalid,
            s0_rready  => s0_rready,

            s1_awid    => s1_awid,
            s1_awaddr  => s1_awaddr,
            s1_awlen   => s1_awlen,
            s1_awsize  => s1_awsize,
            s1_awburst => s1_awburst,
            s1_awlock  => s1_awlock,
            s1_awcache => s1_awcache,
            s1_awprot  => s1_awprot,
            s1_awqos   => s1_awqos,
            s1_awvalid => s1_awvalid,
            s1_awready => s1_awready,
            s1_wdata   => s1_wdata,
            s1_wstrb   => s1_wstrb,
            s1_wlast   => s1_wlast,
            s1_wvalid  => s1_wvalid,
            s1_wready  => s1_wready,
            s1_bid     => s1_bid,
            s1_bresp   => s1_bresp,
            s1_bvalid  => s1_bvalid,
            s1_bready  => s1_bready,
            s1_arid    => s1_arid,
            s1_araddr  => s1_araddr,
            s1_arlen   => s1_arlen,
            s1_arsize  => s1_arsize,
            s1_arburst => s1_arburst,
            s1_arlock  => s1_arlock,
            s1_arcache => s1_arcache,
            s1_arprot  => s1_arprot,
            s1_arqos   => s1_arqos,
            s1_arvalid => s1_arvalid,
            s1_arready => s1_arready,
            s1_rid     => s1_rid,
            s1_rdata   => s1_rdata,
            s1_rresp   => s1_rresp,
            s1_rlast   => s1_rlast,
            s1_rvalid  => s1_rvalid,
            s1_rready  => s1_rready,

            m_awid    => m_awid,
            m_awaddr  => m_awaddr,
            m_awlen   => m_awlen,
            m_awsize  => m_awsize,
            m_awburst => m_awburst,
            m_awlock  => m_awlock,
            m_awcache => m_awcache,
            m_awprot  => m_awprot,
            m_awqos   => m_awqos,
            m_awvalid => m_awvalid,
            m_awready => m_awready,
            m_wdata   => m_wdata,
            m_wstrb   => m_wstrb,
            m_wlast   => m_wlast,
            m_wvalid  => m_wvalid,
            m_wready  => m_wready,
            m_bid     => m_bid,
            m_bresp   => m_bresp,
            m_bvalid  => m_bvalid,
            m_bready  => m_bready,
            m_arid    => m_arid,
            m_araddr  => m_araddr,
            m_arlen   => m_arlen,
            m_arsize  => m_arsize,
            m_arburst => m_arburst,
            m_arlock  => m_arlock,
            m_arcache => m_arcache,
            m_arprot  => m_arprot,
            m_arqos   => m_arqos,
            m_arvalid => m_arvalid,
            m_arready => m_arready,
            m_rid     => m_rid,
            m_rdata   => m_rdata,
            m_rresp   => m_rresp,
            m_rlast   => m_rlast,
            m_rvalid  => m_rvalid,
            m_rready  => m_rready
        );

    master_rsp_model : process (aclk, aresetn)
    begin
        if aresetn = '0' then 
            wr_rsp_pending <= '0';
            rd_rsp_pending <= '0';
            wr_id_hold     <= (others => '0');
            rd_id_hold     <= (others => '0');
            rd_addr_hold   <= (others => '0');
            m_bid          <= (others => '0');
            m_bresp        <= "00";
            m_bvalid       <= '0';
            m_rid          <= (others => '0');
            m_rdata        <= (others => '0');
            m_rresp        <= "00";
            m_rlast        <= '0';
            m_rvalid       <= '0';
        elsif rising_edge(aclk) then
            if (m_awvalid = '1') and (m_awready = '1') then
                wr_id_hold <= m_awid;
            end if;

            if (m_wvalid = '1') and (m_wready = '1') and (m_wlast = '1') then
                wr_rsp_pending <= '1';
            end if;

            if (m_bvalid = '1') and (m_bready = '1') then
                m_bvalid <= '0';
            elsif (wr_rsp_pending = '1') and (m_bvalid = '0') then
                m_bid          <= wr_id_hold;
                m_bresp        <= "00";
                m_bvalid       <= '1';
                wr_rsp_pending <= '0';
            end if;

            if (m_arvalid = '1') and (m_arready = '1') then
                rd_id_hold     <= m_arid;
                rd_addr_hold   <= m_araddr;
                rd_rsp_pending <= '1';
            end if;

            if (m_rvalid = '1') and (m_rready = '1') then
                m_rvalid <= '0';
            elsif (rd_rsp_pending = '1') and (m_rvalid = '0') then
                m_rid          <= rd_id_hold;
                m_rdata        <= std_logic_vector(resize(unsigned(rd_addr_hold), G_DATA_WIDTH));
                m_rresp        <= "00";
                m_rlast        <= '1';
                m_rvalid       <= '1';
                rd_rsp_pending <= '0';
            end if;
        end if;
    end process;

    stim_proc : process
        variable exp_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        variable exp_last : std_logic;
    begin
        s0_awlen   <= (others => '0');
        s1_awlen   <= (others => '0');
        s0_awsize  <= AW_SIZE_128B;
        s1_awsize  <= AW_SIZE_128B;
        s0_awburst <= INCR_BURST;
        s1_awburst <= INCR_BURST;
        s0_awcache <= "0011";
        s1_awcache <= "0011";

        s0_arlen   <= (others => '0');
        s1_arlen   <= (others => '0');
        s0_arsize  <= AW_SIZE_128B;
        s1_arsize  <= AW_SIZE_128B;
        s0_arburst <= INCR_BURST;
        s1_arburst <= INCR_BURST;
        s0_arcache <= "0011";
        s1_arcache <= "0011";

        aresetn <= '0';
        wait for 10000* CLK_PERIOD;
        wait until rising_edge(aclk);
        aresetn <= '1';
        wait until rising_edge(aclk);


        --* WRITE PHASE *--
        -- Queue one write from each slave slot.
        s0_awid    <= WR0_ID;
        s0_awaddr  <= WR0_ADDR;
        s0_awvalid <= '1';
        s1_awid    <= WR1_ID;
        s1_awaddr  <= WR1_ADDR;
        s1_awvalid <= '1';

        wait until rising_edge(aclk);
        assert (s0_awready = '1') and (s1_awready = '1')
            report "AW enqueue failed for one or both slots."
            severity failure;

        s0_awvalid <= '0';
        s1_awvalid <= '0';

        -- slote selection based on Round Robin method
        -- First granted write should come from slot 0.
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (m_awvalid = '1') and (m_awready = '1');
        end loop;
        assert (m_awvalid = '1') and (m_awready = '1')
            report "Timeout waiting for first master AW handshake."
            severity failure;
        assert m_awid(G_M_ID_WIDTH - 1) = '0'
            report "First master AW should be from slot 0."
            severity failure;
        assert m_awid(G_S_ID_WIDTH - 1 downto 0) = WR0_ID
            report "First master AW low ID bits do not match slot 0 ID."
            severity failure;
        assert m_awaddr = WR0_ADDR
            report "First master AW address mismatch."
            severity failure;

        s0_wdata  <= WR0_DATA;
        s0_wstrb  <= (others => '1');
        s0_wlast  <= '1';
        s0_wvalid <= '1';


        -- check that while slot 0 owns the write data channel, slot 1 WREADY is low and slot 1 cannot enqueue another write
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_wvalid = '1') and (s0_wready = '1');
        end loop;
        assert (s0_wvalid = '1') and (s0_wready = '1')
            report "Timeout waiting for slot 0 W handshake."
            severity failure;
        assert (m_wvalid = '1') and (m_wdata = WR0_DATA) and (m_wlast = '1')
            report "Slot 0 W channel was not forwarded correctly."
            severity failure;
        assert s1_wready = '0'
            report "Slot 1 WREADY should be low while slot 0 owns write data channel."
            severity failure;
        s0_wvalid <= '0';
        -- get the write response for the first write and check that it is correctly routed back to slot 0 with correct ID and response code
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_bvalid = '1') or (s1_bvalid = '1');
        end loop;
        assert (s0_bvalid = '1') and (s1_bvalid = '0')
            report "Write response was not routed to slot 0."
            severity failure;
        assert s0_bid = WR0_ID
            report "Slot 0 BID mismatch."
            severity failure;
        assert s0_bresp = "00"
            report "Slot 0 BRESP mismatch."
            severity failure;

        -- Second granted write should come from slot 1.
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (m_awvalid = '1') and (m_awready = '1');
        end loop;
        assert (m_awvalid = '1') and (m_awready = '1')
            report "Timeout waiting for second master AW handshake."
            severity failure;
        assert m_awid(G_M_ID_WIDTH - 1) = '1'
            report "Second master AW should be from slot 1."
            severity failure;
        assert m_awid(G_S_ID_WIDTH - 1 downto 0) = WR1_ID
            report "Second master AW low ID bits do not match slot 1 ID."
            severity failure;
        assert m_awaddr = WR1_ADDR
            report "Second master AW address mismatch."
            severity failure;

        s1_wdata  <= WR1_DATA;
        s1_wstrb  <= (others => '1');
        s1_wlast  <= '1';
        s1_wvalid <= '1';

        -- check the same conditions for slot 1 owning the write data channel as were checked for slot 0 above
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s1_wvalid = '1') and (s1_wready = '1');
        end loop;
        assert (s1_wvalid = '1') and (s1_wready = '1')
            report "Timeout waiting for slot 1 W handshake."
            severity failure;
        assert (m_wvalid = '1') and (m_wdata = WR1_DATA) and (m_wlast = '1')
            report "Slot 1 W channel was not forwarded correctly."
            severity failure;
        assert s0_wready = '0'
            report "Slot 0 WREADY should be low while slot 1 owns write data channel."
            severity failure;
        s1_wvalid <= '0';

        -- get the write response for the second write and check that it is correctly routed back to slot 1 with correct ID and response code
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_bvalid = '1') or (s1_bvalid = '1');
        end loop;
        assert (s1_bvalid = '1') and (s0_bvalid = '0')
            report "Write response was not routed to slot 1."
            severity failure;
        assert s1_bid = WR1_ID
            report "Slot 1 BID mismatch."
            severity failure;
        assert s1_bresp = "00"
            report "Slot 1 BRESP mismatch."
            severity failure;

        -- Burst write from slot 0: one AW then 8 W beats (AWLEN = 7).
        s0_awid    <= WRB_ID;
        s0_awaddr  <= WRB_ADDR;
        s0_awlen   <= WRB_LEN;
        s0_awvalid <= '1';
        wait until rising_edge(aclk);
        assert s0_awready = '1'
            report "Burst AW enqueue failed for slot 0."
            severity failure;
        s0_awvalid <= '0';

        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (m_awvalid = '1') and (m_awready = '1');
        end loop;
        assert (m_awvalid = '1') and (m_awready = '1')
            report "Timeout waiting for burst AW handshake."
            severity failure;
        assert m_awid(G_M_ID_WIDTH - 1) = '0'
            report "Burst AW should come from slot 0."
            severity failure;
        assert m_awid(G_S_ID_WIDTH - 1 downto 0) = WRB_ID
            report "Burst AW low ID bits mismatch."
            severity failure;
        assert m_awaddr = WRB_ADDR
            report "Burst AW address mismatch."
            severity failure;
        assert m_awlen = WRB_LEN
            report "Burst AWLEN mismatch (expected 7)."
            severity failure;

        for beat in 0 to 7 loop
            exp_data := std_logic_vector(to_unsigned(16#5000# + beat, G_DATA_WIDTH));
            if beat = 7 then
                exp_last := '1';
            else
                exp_last := '0';
            end if;

            s0_wdata  <= exp_data;
            s0_wstrb  <= (others => '1');
            s0_wlast  <= exp_last;
            s0_wvalid <= '1';

            for i in 0 to 100 loop
                wait until rising_edge(aclk);
                exit when (s0_wvalid = '1') and (s0_wready = '1');
            end loop;
            assert (s0_wvalid = '1') and (s0_wready = '1')
                report "Timeout waiting for burst W handshake."
                severity failure;
            assert (m_wvalid = '1') and (m_wdata = exp_data) and (m_wlast = exp_last)
                report "Burst W forwarding mismatch."
                severity failure;
            assert s1_wready = '0'
                report "Slot 1 WREADY should stay low during slot 0 burst."
                severity failure;
        end loop;

        s0_wvalid <= '0';
        s0_wlast  <= '0';
        s0_awlen  <= (others => '0');

        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_bvalid = '1') or (s1_bvalid = '1');
        end loop;
        assert (s0_bvalid = '1') and (s1_bvalid = '0')
            report "Burst write response was not routed to slot 0."
            severity failure;
        assert s0_bid = WRB_ID
            report "Burst slot 0 BID mismatch."
            severity failure;
        assert s0_bresp = "00"
            report "Burst slot 0 BRESP mismatch."
            severity failure;


        -- * READ PHASE * --
        -- Queue one read from each slave slot.
        s0_arid    <= RD0_ID;
        s0_araddr  <= RD0_ADDR;
        s0_arvalid <= '1';
        s1_arid    <= RD1_ID;
        s1_araddr  <= RD1_ADDR;
        s1_arvalid <= '1';

        wait until rising_edge(aclk);
        assert (s0_arready = '1') and (s1_arready = '1')
            report "AR enqueue failed for one or both slots."
            severity failure;
        s0_arvalid <= '0';
        s1_arvalid <= '0';

        -- 7).First granted read should come from slot 0.
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (m_arvalid = '1') and (m_arready = '1');
        end loop;
        assert (m_arvalid = '1') and (m_arready = '1')
            report "Timeout waiting for first master AR handshake."
            severity failure;
        assert m_arid(G_M_ID_WIDTH - 1) = '0'
            report "First master AR should be from slot 0."
            severity failure;
        assert m_arid(G_S_ID_WIDTH - 1 downto 0) = RD0_ID
            report "First master AR low ID bits do not match slot 0 ID."
            severity failure;
        assert m_araddr = RD0_ADDR
            report "First master AR address mismatch."
            severity failure;
        
        -- 8).check the slot0 is get the granst for reading based on ROund Robin Method
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_rvalid = '1') or (s1_rvalid = '1');
        end loop;
        assert (s0_rvalid = '1') and (s1_rvalid = '0')
            report "Read response was not routed to slot 0."
            severity failure;
        assert s0_rid = RD0_ID
            report "Slot 0 RID mismatch."
            severity failure;
        assert s0_rresp = "00"
            report "Slot 0 RRESP mismatch."
            severity failure;
        assert s0_rlast = '1'
            report "Slot 0 RLAST mismatch."
            severity failure;
        assert s0_rdata = std_logic_vector(resize(unsigned(RD0_ADDR), G_DATA_WIDTH))
            report "Slot 0 RDATA mismatch."
            severity failure;

        -- 9). Second granted read should come from slot 1.
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (m_arvalid = '1') and (m_arready = '1');
        end loop;
        assert (m_arvalid = '1') and (m_arready = '1')
            report "Timeout waiting for second master AR handshake."
            severity failure;
        assert m_arid(G_M_ID_WIDTH - 1) = '1'
            report "Second master AR should be from slot 1."
            severity failure;
        assert m_arid(G_S_ID_WIDTH - 1 downto 0) = RD1_ID
            report "Second master AR low ID bits do not match slot 1 ID."
            severity failure;
        assert m_araddr = RD1_ADDR
            report "Second master AR address mismatch."
            severity failure;

            --10). check the read data  , read response and RLAST signal for slot 1 after getting the grant for read transaction based on Round Robin method
        for i in 0 to 100 loop
            wait until rising_edge(aclk);
            exit when (s0_rvalid = '1') or (s1_rvalid = '1');
        end loop;
        assert (s1_rvalid = '1') and (s0_rvalid = '0')
            report "Read response was not routed to slot 1."
            severity failure;
        assert s1_rid = RD1_ID
            report "Slot 1 RID mismatch."
            severity failure;
        assert s1_rresp = "00"
            report "Slot 1 RRESP mismatch."
            severity failure;
        assert s1_rlast = '1'
            report "Slot 1 RLAST mismatch."
            severity failure;
        assert s1_rdata = std_logic_vector(resize(unsigned(RD1_ADDR), G_DATA_WIDTH))
            report "Slot 1 RDATA mismatch."
            severity failure;

        assert false report "axi_custom_int_2slot_tb PASSED" severity note;
        wait;
    end process;
end architecture sim;
