library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_wr is

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
        axi_m_axi_wstrb   : out std_logic_vector(g_DATA_WIDTH / 8 - 1 downto 0);
        axi_m_axi_wlast   : out std_logic;
        axi_m_axi_wvalid  : out std_logic;
        axi_m_axi_wready  : in  std_logic;
        axi_m_axi_bready  : out std_logic;
        axi_m_axi_bid     : in  std_logic_vector(3 downto 0);
        axi_m_axi_bresp   : in  std_logic_vector(1 downto 0);
        axi_m_axi_bvalid  : in  std_logic
    );
end entity;

architecture arc_avmm_to_axi4_wr of avmm_to_axi4_wr is

    -- SM Definition
    type state_type is (
        idle,
        collect_avmm,
        send_aw,
        send_w,
        wait_b
    );

    signal next_state, current_state : state_type;

    -- Output Registers
    signal r_avmm_s_write   : std_logic;
    signal r_avmm_s_address : std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
    signal r_avmm_s_busy    : std_logic;

    signal r_axi_m_axi_awid    : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awaddr  : std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
    signal r_axi_m_axi_awlen   : std_logic_vector(7 downto 0);
    signal r_axi_m_axi_awsize  : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_awburst : std_logic_vector(1 downto 0);
    signal r_axi_m_axi_awlock  : std_logic_vector(0 downto 0);
    signal r_axi_m_axi_awcache : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awprot  : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_awqos   : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awvalid : std_logic;
    signal w_axi_m_axi_awready : std_logic;
    signal r_axi_m_axi_wdata   : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_axi_m_axi_wstrb   : std_logic_vector(g_DATA_WIDTH / 8 - 1 downto 0);
    signal r_axi_m_axi_wlast   : std_logic;
    signal r_axi_m_axi_wvalid  : std_logic;
    signal w_axi_m_axi_wready  : std_logic;
    signal r_axi_m_axi_bready  : std_logic;
    signal w_axi_m_axi_bid     : std_logic_vector(3 downto 0);
    signal w_axi_m_axi_bresp   : std_logic_vector(1 downto 0);
    signal w_axi_m_axi_bvalid  : std_logic;

    constant C_BURST_LEN : integer := 8;

    type buf_burst_t is array (0 to C_BURST_LEN - 1) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);

    signal buf_burst   : buf_burst_t;
    signal r_burst_cnt : unsigned(2 downto 0); -- 0..7
    signal r_beat_cnt  : unsigned(2 downto 0);

begin

    avmm_s_busy <= r_avmm_s_busy;

    axi_m_axi_awid      <= r_axi_m_axi_awid;
    axi_m_axi_awaddr    <= r_axi_m_axi_awaddr;
    axi_m_axi_awlen     <= r_axi_m_axi_awlen;
    axi_m_axi_awsize    <= r_axi_m_axi_awsize;
    axi_m_axi_awburst   <= r_axi_m_axi_awburst;
    axi_m_axi_awlock    <= r_axi_m_axi_awlock;
    axi_m_axi_awcache   <= r_axi_m_axi_awcache;
    axi_m_axi_awprot    <= r_axi_m_axi_awprot;
    axi_m_axi_awqos     <= r_axi_m_axi_awqos;
    axi_m_axi_awvalid   <= r_axi_m_axi_awvalid;
    w_axi_m_axi_awready <= axi_m_axi_awready;
    axi_m_axi_wdata     <= r_axi_m_axi_wdata;
    axi_m_axi_wstrb     <= r_axi_m_axi_wstrb;
    axi_m_axi_wlast     <= r_axi_m_axi_wlast;
    axi_m_axi_wvalid    <= r_axi_m_axi_wvalid;
    w_axi_m_axi_wready  <= axi_m_axi_wready;
    axi_m_axi_bready    <= r_axi_m_axi_bready;
    w_axi_m_axi_bid     <= axi_m_axi_bid;
    w_axi_m_axi_bresp   <= axi_m_axi_bresp;
    w_axi_m_axi_bvalid  <= axi_m_axi_bvalid;

    main_process : process(axi_aresetn, axi_aclk)
    begin
        if axi_aresetn = '0' then

            -- Temp Signals
            r_avmm_s_write   <= '0';
            r_avmm_s_address <= (others => '0');
            r_avmm_s_busy    <= '0';

            r_axi_m_axi_awid    <= (others => '0');
            r_axi_m_axi_awaddr  <= (others => '0');
            r_axi_m_axi_awlen   <= (others => '0');
            r_axi_m_axi_awsize  <= (others => '0');
            r_axi_m_axi_awburst <= (others => '0');
            r_axi_m_axi_awlock  <= (others => '0');
            r_axi_m_axi_awcache <= (others => '0');
            r_axi_m_axi_awprot  <= (others => '0');
            r_axi_m_axi_awqos   <= (others => '0');
            r_axi_m_axi_awvalid <= '0';
            r_axi_m_axi_wdata   <= (others => '0');
            r_axi_m_axi_wstrb   <= (others => '0');
            r_axi_m_axi_wlast   <= '0';
            r_axi_m_axi_wvalid  <= '0';
            r_axi_m_axi_bready  <= '0';

            r_burst_cnt <= (others => '0');
            r_beat_cnt  <= (others => '0');
            buf_burst   <= (others => (others => '0'));

            current_state <= idle;

        elsif axi_aclk'event and axi_aclk = '1' then

            r_avmm_s_write <= avmm_s_write and not (r_avmm_s_busy);
            if avmm_s_write = '1' and r_avmm_s_busy = '0' then
                r_avmm_s_address <= avmm_s_address;
            end if;

            -- SM Derived Signals
            r_avmm_s_busy <= avmm_s_write or r_avmm_s_write;

            r_axi_m_axi_awid    <= X"0";
            r_axi_m_axi_awaddr  <= (others => '0');
            r_axi_m_axi_awlen   <= "00000111";
            r_axi_m_axi_awsize  <= "100";
            r_axi_m_axi_awburst <= "01";
            r_axi_m_axi_awlock  <= "0";
            r_axi_m_axi_awcache <= X"3"; -- Normal, non-cacheable
            r_axi_m_axi_awprot  <= "000";
            r_axi_m_axi_awqos   <= X"0";
            r_axi_m_axi_awvalid <= '0';

            r_axi_m_axi_wdata  <= (others => '0');
            r_axi_m_axi_wstrb  <= (others => '1');
            r_axi_m_axi_wlast  <= '0';
            r_axi_m_axi_wvalid <= '0';

            r_axi_m_axi_bready <= '0';

            case current_state is

                when idle =>

                when collect_avmm =>
                    r_avmm_s_busy <= '1';

                    if avmm_s_write = '1' then
                        buf_burst(to_integer(r_burst_cnt)) <= avmm_s_writedata;

                        if r_burst_cnt = "111" then
                            r_beat_cnt <= (others => '0');
                        else
                            current_state <= collect_avmm;
                            r_burst_cnt   <= r_burst_cnt + 1;
                        end if;
                    end if;

                when send_aw =>
                    r_avmm_s_busy       <= '1';
                    r_axi_m_axi_awaddr  <= r_avmm_s_address;
                    r_axi_m_axi_awvalid <= '1';

                when send_w =>
                    r_avmm_s_busy      <= '1';
                    r_axi_m_axi_wdata  <= buf_burst(to_integer(r_beat_cnt));
                    r_axi_m_axi_wvalid <= '1';

                    if r_beat_cnt = "111" then
                        r_axi_m_axi_wlast <= '1';
                    else
                        r_axi_m_axi_wlast <= '0';
                    end if;

                    if w_axi_m_axi_wready = '1' then
                        r_beat_cnt <= r_beat_cnt + 1;
                    end if;

                when wait_b =>
                    r_avmm_s_busy      <= '1';
                    r_axi_m_axi_bready <= '1';

                    if w_axi_m_axi_bvalid = '1' then
                        r_burst_cnt <= (others => '0');
                        r_beat_cnt  <= (others => '0');
                    end if;

            end case;
            current_state <= next_state;
        end if;
    end process;

    sm_process : process(current_state, avmm_s_write, r_burst_cnt, axi_m_axi_awready, axi_m_axi_wready, r_beat_cnt, axi_m_axi_bvalid)
    begin
        case current_state is

            when idle =>
                if avmm_s_write = '1' then
                    next_state <= collect_avmm;
                end if;

            when collect_avmm =>
                if avmm_s_write = '1' and r_burst_cnt = "111" then
                    next_state <= send_aw;
                else
                    next_state <= collect_avmm;
                end if;

            when send_aw =>
                if axi_m_axi_awready = '1' then
                    next_state <= send_w;
                else
                    next_state <= send_aw;
                end if;

            when send_w =>
                if axi_m_axi_wready = '1' and r_beat_cnt = "111" then
                    next_state <= wait_b;
                else
                    next_state <= send_w;
                end if;

            when wait_b =>
                if axi_m_axi_bvalid = '1' then
                    next_state <= idle;
                else
                    next_state <= wait_b;
                end if;

        end case;

    end process;

end arc_avmm_to_axi4_wr;
