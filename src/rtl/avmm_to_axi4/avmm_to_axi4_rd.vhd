library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_rd is

    generic(
        g_ADDR_WIDTH       : integer := 29;
        g_DATA_WIDTH       : integer := 128;
        g_MAX_OUTSTANDING  : positive := 16
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
end entity;

architecture arc_avmm_to_axi4_rd of avmm_to_axi4_rd is

    function f_log2_ceil(A : natural) return natural is
        variable v_pow : natural := 1;
        variable v_log : natural := 0;
    begin
        while v_pow < A loop
            v_pow := v_pow * 2;
            v_log := v_log + 1;
        end loop;

        if v_log = 0 then
            return 1;
        end if;
        return v_log;
    end function;

    constant C_OUTSTANDING_W : natural := f_log2_ceil(g_MAX_OUTSTANDING + 1);
    constant C_MAX_OUTSTANDING_U : unsigned(C_OUTSTANDING_W - 1 downto 0) := to_unsigned(g_MAX_OUTSTANDING, C_OUTSTANDING_W);

    signal r_avmm_s_readdata_val : std_logic;
    signal r_avmm_s_readdata     : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_avmm_s_busy         : std_logic;

    signal r_req0_valid : std_logic;
    signal r_req1_valid : std_logic;
    signal r_req0_addr  : std_logic_vector(28 downto 0);
    signal r_req1_addr  : std_logic_vector(28 downto 0);

    signal r_outstanding_cnt : unsigned(C_OUTSTANDING_W - 1 downto 0);

    signal w_axi_m_axi_arready : std_logic;
    signal r_axi_m_axi_rready  : std_logic;
    signal w_axi_m_axi_rvalid  : std_logic;
    signal w_axi_m_axi_rdata   : std_logic_vector(127 downto 0);

    signal w_ar_credit_available : std_logic;
    signal w_ar_fire             : std_logic;
    signal w_r_fire              : std_logic;

    signal w_req0_valid_deq : std_logic;
    signal w_req1_valid_deq : std_logic;
    signal w_req0_addr_deq  : std_logic_vector(28 downto 0);

    signal w_store_req0 : std_logic;
    signal w_store_req1 : std_logic;

    signal w_req0_valid_next : std_logic;
    signal w_req1_valid_next : std_logic;
    signal w_req0_addr_next  : std_logic_vector(28 downto 0);
    signal w_req1_addr_next  : std_logic_vector(28 downto 0);

    signal w_outstanding_inc      : std_logic;
    signal w_outstanding_dec      : std_logic;
    signal w_outstanding_cnt_next : unsigned(C_OUTSTANDING_W - 1 downto 0);

    signal w_busy_next : std_logic;

begin

    avmm_s_readdata_val <= r_avmm_s_readdata_val;
    avmm_s_readdata     <= r_avmm_s_readdata;
    avmm_s_busy         <= r_avmm_s_busy;

    -- Single-ID, single-beat reads. Keep static attributes stable.
    axi_m_axi_arid    <= X"0";
    axi_m_axi_araddr  <= r_req0_addr;
    axi_m_axi_arlen   <= (others => '0');
    axi_m_axi_arsize  <= "100"; -- 16 bytes
    axi_m_axi_arburst <= "01";  -- INCR
    axi_m_axi_arlock  <= "0";
    axi_m_axi_arcache <= X"3";  -- Normal, non-cacheable
    axi_m_axi_arprot  <= "000";
    axi_m_axi_arqos   <= X"0";

    axi_m_axi_arvalid     <= r_req0_valid and w_ar_credit_available;

    w_axi_m_axi_arready <= axi_m_axi_arready;
    axi_m_axi_rready    <= r_axi_m_axi_rready;
    w_axi_m_axi_rvalid  <= axi_m_axi_rvalid;
    w_axi_m_axi_rdata   <= axi_m_axi_rdata;

    p_ar_credit_available : process(r_outstanding_cnt)
    begin
        w_ar_credit_available <= '0';
        if r_outstanding_cnt < C_MAX_OUTSTANDING_U then
            w_ar_credit_available <= '1';
        end if;
    end process;

    p_ar_fire : process(r_req0_valid, w_ar_credit_available, w_axi_m_axi_arready)
    begin
        w_ar_fire <= '0';
        if (r_req0_valid = '1') and (w_ar_credit_available = '1') and (w_axi_m_axi_arready = '1') then
            w_ar_fire <= '1';
        end if;
    end process;

    p_r_fire : process(w_axi_m_axi_rvalid, r_axi_m_axi_rready)
    begin
        w_r_fire <= '0';
        if (w_axi_m_axi_rvalid = '1') and (r_axi_m_axi_rready = '1') then
            w_r_fire <= '1';
        end if;
    end process;

    p_req_dequeue : process(w_ar_fire, r_req1_valid, r_req1_addr, r_req0_valid, r_req0_addr)
    begin
        w_req0_valid_deq <= r_req0_valid;
        w_req1_valid_deq <= r_req1_valid;
        w_req0_addr_deq  <= r_req0_addr;

        if w_ar_fire = '1' then
            if r_req1_valid = '1' then
                w_req0_valid_deq <= '1';
                w_req1_valid_deq <= '0';
                w_req0_addr_deq  <= r_req1_addr;
            else
                w_req0_valid_deq <= '0';
            end if;
        end if;
    end process;

    p_req_store_sel : process(avmm_s_address_val, w_req0_valid_deq, w_req1_valid_deq)
    begin
        w_store_req0 <= '0';
        w_store_req1 <= '0';

        if avmm_s_address_val = '1' then
            if w_req0_valid_deq = '0' then
                w_store_req0 <= '1';
            elsif w_req1_valid_deq = '0' then
                w_store_req1 <= '1';
            end if;
        end if;
    end process;

    p_req_next : process(w_req0_valid_deq, w_req1_valid_deq, w_req0_addr_deq, r_req1_addr, w_store_req0, w_store_req1, avmm_s_address)
    begin
        w_req0_valid_next <= w_req0_valid_deq;
        w_req1_valid_next <= w_req1_valid_deq;
        w_req0_addr_next  <= w_req0_addr_deq;
        w_req1_addr_next  <= r_req1_addr;

        if w_store_req0 = '1' then
            w_req0_valid_next <= '1';
            w_req0_addr_next  <= avmm_s_address;
        elsif w_store_req1 = '1' then
            w_req1_valid_next <= '1';
            w_req1_addr_next  <= avmm_s_address;
        end if;
    end process;

    p_outstanding_next : process(w_ar_fire, w_r_fire, r_outstanding_cnt)
    begin
        w_outstanding_inc      <= '0';
        w_outstanding_dec      <= '0';
        w_outstanding_cnt_next <= r_outstanding_cnt;

        if (w_ar_fire = '1') and (w_r_fire = '0') then
            if r_outstanding_cnt < C_MAX_OUTSTANDING_U then
                w_outstanding_inc      <= '1';
                w_outstanding_cnt_next <= r_outstanding_cnt + 1;
            end if;
        elsif (w_r_fire = '1') and (w_ar_fire = '0') then
            if r_outstanding_cnt > 0 then
                w_outstanding_dec      <= '1';
                w_outstanding_cnt_next <= r_outstanding_cnt - 1;
            end if;
        end if;
    end process;

    p_busy_next : process(w_req0_valid_next, w_req1_valid_next)
    begin
        w_busy_next <= '0';
        if (w_req0_valid_next = '1') and (w_req1_valid_next = '1') then
            w_busy_next <= '1';
        end if;
    end process;

    -- avmm_s_read is intentionally ignored for compatibility with the current caller,
    -- which drives address_val as the request qualifier.
    main_process : process(axi_aresetn, axi_aclk)
    begin
        if axi_aresetn = '0' then
            r_avmm_s_readdata_val <= '0';
            r_avmm_s_readdata     <= (others => '0');
            r_avmm_s_busy         <= '0';

            r_req0_valid <= '0';
            r_req1_valid <= '0';
            r_req0_addr  <= (others => '0');
            r_req1_addr  <= (others => '0');

            r_outstanding_cnt <= (others => '0');
            r_axi_m_axi_rready <= '0';

        elsif rising_edge(axi_aclk) then
            r_req0_valid <= w_req0_valid_next;
            r_req1_valid <= w_req1_valid_next;
            r_req0_addr  <= w_req0_addr_next;
            r_req1_addr  <= w_req1_addr_next;

            r_outstanding_cnt <= w_outstanding_cnt_next;

            -- Busy means the 2-entry staging buffer is full.
            r_avmm_s_busy <= w_busy_next;

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
