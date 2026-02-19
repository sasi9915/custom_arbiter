library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_rd is

    generic(
        g_ADDR_WIDTH : integer := 29;
        g_DATA_WIDTH : integer := 32
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
        axi_m_axi_rdata     : in  std_logic_vector(31 downto 0)
    );
end entity;

architecture arc_avmm_to_axi4_rd of avmm_to_axi4_rd is

    -- Temp Signals
    signal r_avmm_s_readdata_val : std_logic;
    signal r_avmm_s_readdata     : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_avmm_s_busy         : std_logic;
    signal rd_req_pending        : std_logic;

    signal r_axi_m_axi_arid    : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_araddr  : std_logic_vector(28 downto 0);
    signal r_axi_m_axi_arlen   : std_logic_vector(7 downto 0);
    signal r_axi_m_axi_arsize  : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_arburst : std_logic_vector(1 downto 0);
    signal r_axi_m_axi_arlock  : std_logic_vector(0 downto 0);
    signal r_axi_m_axi_arcache : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_arprot  : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_arqos   : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_arvalid : std_logic;
    signal w_axi_m_axi_arready : std_logic;
    signal r_axi_m_axi_rready  : std_logic;
    signal w_axi_m_axi_rlast   : std_logic;
    signal w_axi_m_axi_rvalid  : std_logic;
    signal w_axi_m_axi_rresp   : std_logic_vector(1 downto 0);
    signal w_axi_m_axi_rid     : std_logic_vector(3 downto 0);
    signal w_axi_m_axi_rdata   : std_logic_vector(31 downto 0);

begin

    avmm_s_readdata_val <= r_avmm_s_readdata_val;
    avmm_s_readdata     <= r_avmm_s_readdata;
    avmm_s_busy         <= r_avmm_s_busy;

    axi_m_axi_arid      <= r_axi_m_axi_arid;
    axi_m_axi_araddr    <= r_axi_m_axi_araddr;
    axi_m_axi_arlen     <= r_axi_m_axi_arlen;
    axi_m_axi_arsize    <= r_axi_m_axi_arsize;
    axi_m_axi_arburst   <= r_axi_m_axi_arburst;
    axi_m_axi_arlock    <= r_axi_m_axi_arlock;
    axi_m_axi_arcache   <= r_axi_m_axi_arcache;
    axi_m_axi_arprot    <= r_axi_m_axi_arprot;
    axi_m_axi_arqos     <= r_axi_m_axi_arqos;
    axi_m_axi_arvalid   <= r_axi_m_axi_arvalid;
    w_axi_m_axi_arready <= axi_m_axi_arready;
    axi_m_axi_rready    <= r_axi_m_axi_rready;
    w_axi_m_axi_rlast   <= axi_m_axi_rlast;
    w_axi_m_axi_rvalid  <= axi_m_axi_rvalid;
    w_axi_m_axi_rresp   <= axi_m_axi_rresp;
    w_axi_m_axi_rid     <= axi_m_axi_rid;
    w_axi_m_axi_rdata   <= axi_m_axi_rdata;

    -- Main Process: Clocked synchronous logic
    main_process : process(axi_aresetn, axi_aclk)
    begin
        if axi_aresetn = '0' then
            -- Reset outputs and internal signals
            r_avmm_s_readdata_val <= '0';
            r_avmm_s_readdata     <= (others => '0');
            r_avmm_s_busy         <= '0';

            r_axi_m_axi_arid    <= X"0";
            r_axi_m_axi_araddr  <= (others => '0');
            r_axi_m_axi_arlen   <= (others => '0');
            r_axi_m_axi_arsize  <= "010"; -- 16 bytes
            r_axi_m_axi_arburst <= "01"; -- INCR
            r_axi_m_axi_arvalid <= '0';
            r_axi_m_axi_rready  <= '0';

        elsif rising_edge(axi_aclk) then

            r_avmm_s_busy <= r_axi_m_axi_arvalid and not w_axi_m_axi_arready;

            if avmm_s_read = '1' then
                rd_req_pending <= '1';
            end if;

            if avmm_s_address_val = '1' and r_avmm_s_busy = '0' then
                r_axi_m_axi_araddr  <= avmm_s_address;
                r_axi_m_axi_arvalid <= '1';
            end if;

            if r_axi_m_axi_arvalid = '1' and w_axi_m_axi_arready = '1' then
                r_axi_m_axi_arvalid <= '0';
            end if;

            -- Provide to AVMM only when avmm_s_read is high
            if w_axi_m_axi_rvalid = '1' then
                r_avmm_s_readdata     <= w_axi_m_axi_rdata;
                r_avmm_s_readdata_val <= '1';
            else
                r_avmm_s_readdata_val <= '0';
            end if;

            r_axi_m_axi_rready <= '1';

        end if;
    end process;

end arc_avmm_to_axi4_rd;
