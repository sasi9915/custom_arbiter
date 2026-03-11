library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_rd is

    generic(
        g_ADDR_WIDTH      : integer := 29;
        g_DATA_WIDTH      : integer := 128;
        g_MAX_OUTSTANDING : positive := 16
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

    function f_next_ptr(ptr : natural; depth : natural) return natural is
    begin
        if ptr = depth - 1 then
            return 0;
        end if;
        return ptr + 1;
    end function;

    constant C_CACHE_LINES    : natural := 4;
    constant C_BURST_BEATS    : natural := 16;
    constant C_ARLEN_U        : unsigned(7 downto 0) := to_unsigned(C_BURST_BEATS - 1, 8);
    constant C_AXI_BEAT_BYTES : natural := g_DATA_WIDTH / 8;
    constant C_BEAT_SHIFT     : natural := f_log2_ceil(C_AXI_BEAT_BYTES);
    constant C_LINE_SHIFT     : natural := C_BEAT_SHIFT + f_log2_ceil(C_BURST_BEATS);
    constant C_BURST_IDX_W    : natural := f_log2_ceil(C_BURST_BEATS);

    subtype t_addr is std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
    subtype t_data is std_logic_vector(g_DATA_WIDTH - 1 downto 0);

    type t_req_fifo is array (0 to g_MAX_OUTSTANDING - 1) of t_addr;
    type t_cache_line is array (0 to C_BURST_BEATS - 1) of t_data;
    type t_cache_mem is array (0 to C_CACHE_LINES - 1) of t_cache_line;
    type t_cache_base is array (0 to C_CACHE_LINES - 1) of t_addr;
    type t_fill_base_q is array (0 to g_MAX_OUTSTANDING - 1) of t_addr;
    type t_fill_line_q is array (0 to g_MAX_OUTSTANDING - 1) of natural range 0 to C_CACHE_LINES - 1;

    signal r_avmm_s_readdata_val : std_logic;
    signal r_avmm_s_readdata     : t_data;
    signal r_avmm_s_busy         : std_logic;

    signal r_req_mem   : t_req_fifo;
    signal r_req_rdptr : natural range 0 to g_MAX_OUTSTANDING - 1;
    signal r_req_wrptr : natural range 0 to g_MAX_OUTSTANDING - 1;
    signal r_req_count : natural range 0 to g_MAX_OUTSTANDING;

    signal r_cache_data  : t_cache_mem;
    signal r_cache_base  : t_cache_base;
    signal r_cache_valid : std_logic_vector(C_CACHE_LINES - 1 downto 0);
    signal r_cache_victim: natural range 0 to C_CACHE_LINES - 1;

    signal r_fill_base_mem : t_fill_base_q;
    signal r_fill_line_mem : t_fill_line_q;
    signal r_fill_rdptr    : natural range 0 to g_MAX_OUTSTANDING - 1;
    signal r_fill_wrptr    : natural range 0 to g_MAX_OUTSTANDING - 1;
    signal r_fill_count    : natural range 0 to g_MAX_OUTSTANDING;
    signal r_fill_beat_idx : natural range 0 to C_BURST_BEATS - 1;

    signal r_issue_base  : t_addr;
    signal r_issue_line  : natural range 0 to C_CACHE_LINES - 1;
    signal r_arvalid     : std_logic;
    signal r_araddr      : t_addr;

begin

    assert g_DATA_WIDTH mod 8 = 0
    report "g_DATA_WIDTH must be byte-aligned."
    severity failure;

    assert C_LINE_SHIFT <= g_ADDR_WIDTH
    report "Address width is too small for configured burst line size."
    severity failure;

    avmm_s_readdata_val <= r_avmm_s_readdata_val;
    avmm_s_readdata     <= r_avmm_s_readdata;
    avmm_s_busy         <= r_avmm_s_busy;

    axi_m_axi_arid    <= X"0";
    axi_m_axi_araddr  <= r_araddr;
    axi_m_axi_arlen   <= std_logic_vector(C_ARLEN_U);
    axi_m_axi_arsize  <= std_logic_vector(to_unsigned(C_BEAT_SHIFT, 3));
    axi_m_axi_arburst <= "01";
    axi_m_axi_arlock  <= "0";
    axi_m_axi_arcache <= X"3";
    axi_m_axi_arprot  <= "000";
    axi_m_axi_arqos   <= X"0";
    axi_m_axi_arvalid <= r_arvalid;

    axi_m_axi_rready <= '1';

    -- avmm_s_read is intentionally ignored for compatibility with existing callers,
    -- which use avmm_s_address_val as the request qualifier.
    main_process : process(axi_aresetn, axi_aclk)
        variable v_req_rdptr  : natural range 0 to g_MAX_OUTSTANDING - 1;
        variable v_req_wrptr  : natural range 0 to g_MAX_OUTSTANDING - 1;
        variable v_req_count  : natural range 0 to g_MAX_OUTSTANDING;

        variable v_fill_rdptr : natural range 0 to g_MAX_OUTSTANDING - 1;
        variable v_fill_wrptr : natural range 0 to g_MAX_OUTSTANDING - 1;
        variable v_fill_count : natural range 0 to g_MAX_OUTSTANDING;
        variable v_fill_beat  : natural range 0 to C_BURST_BEATS - 1;

        variable v_cache_valid : std_logic_vector(C_CACHE_LINES - 1 downto 0);
        variable v_cache_victim: natural range 0 to C_CACHE_LINES - 1;

        variable v_arvalid    : std_logic;
        variable v_araddr     : t_addr;
        variable v_issue_base : t_addr;
        variable v_issue_line : natural range 0 to C_CACHE_LINES - 1;

        variable v_head_addr  : t_addr;
        variable v_req_base   : t_addr;
        variable v_req_beat   : natural range 0 to C_BURST_BEATS - 1;

        variable v_hit        : boolean;
        variable v_hit_line   : natural range 0 to C_CACHE_LINES - 1;
        variable v_pending    : boolean;
        variable v_idx        : natural;

        variable v_dequeue    : boolean;
        variable v_enqueue    : boolean;
    begin
        if axi_aresetn = '0' then
            r_avmm_s_readdata_val <= '0';
            r_avmm_s_readdata     <= (others => '0');
            r_avmm_s_busy         <= '0';

            r_req_mem   <= (others => (others => '0'));
            r_req_rdptr <= 0;
            r_req_wrptr <= 0;
            r_req_count <= 0;

            r_cache_data   <= (others => (others => (others => '0')));
            r_cache_base   <= (others => (others => '0'));
            r_cache_valid  <= (others => '0');
            r_cache_victim <= 0;

            r_fill_base_mem <= (others => (others => '0'));
            r_fill_line_mem <= (others => 0);
            r_fill_rdptr    <= 0;
            r_fill_wrptr    <= 0;
            r_fill_count    <= 0;
            r_fill_beat_idx <= 0;

            r_issue_base <= (others => '0');
            r_issue_line <= 0;
            r_arvalid    <= '0';
            r_araddr     <= (others => '0');

        elsif rising_edge(axi_aclk) then
            r_avmm_s_readdata_val <= '0';

            v_req_rdptr := r_req_rdptr;
            v_req_wrptr := r_req_wrptr;
            v_req_count := r_req_count;

            v_fill_rdptr := r_fill_rdptr;
            v_fill_wrptr := r_fill_wrptr;
            v_fill_count := r_fill_count;
            v_fill_beat  := r_fill_beat_idx;

            v_cache_valid  := r_cache_valid;
            v_cache_victim := r_cache_victim;

            v_arvalid    := r_arvalid;
            v_araddr     := r_araddr;
            v_issue_base := r_issue_base;
            v_issue_line := r_issue_line;

            v_dequeue := false;
            v_enqueue := false;

            -- Complete AR handshake and enqueue an in-flight line descriptor.
            if (v_arvalid = '1') and (axi_m_axi_arready = '1') then
                if v_fill_count < g_MAX_OUTSTANDING then
                    r_fill_base_mem(v_fill_wrptr) <= v_issue_base;
                    r_fill_line_mem(v_fill_wrptr) <= v_issue_line;
                    v_fill_wrptr := f_next_ptr(v_fill_wrptr, g_MAX_OUTSTANDING);
                    v_fill_count := v_fill_count + 1;
                end if;
                v_arvalid := '0';
            end if;

            -- Capture burst data into cache line selected when the AR was issued.
            if (v_fill_count > 0) and (axi_m_axi_rvalid = '1') then
                r_cache_data(r_fill_line_mem(v_fill_rdptr))(v_fill_beat) <= axi_m_axi_rdata;

                if axi_m_axi_rlast = '1' then
                    r_cache_base(r_fill_line_mem(v_fill_rdptr))  <= r_fill_base_mem(v_fill_rdptr);
                    v_cache_valid(r_fill_line_mem(v_fill_rdptr)) := '1';

                    v_fill_rdptr := f_next_ptr(v_fill_rdptr, g_MAX_OUTSTANDING);
                    v_fill_count := v_fill_count - 1;
                    v_fill_beat  := 0;
                else
                    if v_fill_beat < C_BURST_BEATS - 1 then
                        v_fill_beat := v_fill_beat + 1;
                    end if;
                end if;
            end if;

            -- Serve the head request from cache when possible.
            if v_req_count > 0 then
                v_head_addr := r_req_mem(v_req_rdptr);
                v_req_base  := v_head_addr;
                v_req_base(C_LINE_SHIFT - 1 downto 0) := (others => '0');
                v_req_beat := to_integer(unsigned(v_head_addr(C_LINE_SHIFT - 1 downto C_BEAT_SHIFT)));

                v_hit      := false;
                v_hit_line := 0;
                for i in 0 to C_CACHE_LINES - 1 loop
                    if (v_cache_valid(i) = '1') and (r_cache_base(i) = v_req_base) then
                        v_hit      := true;
                        v_hit_line := i;
                    end if;
                end loop;

                if v_hit then
                    r_avmm_s_readdata     <= r_cache_data(v_hit_line)(v_req_beat);
                    r_avmm_s_readdata_val <= '1';
                    v_dequeue := true;
                else
                    -- If a fill for this cache line is already pending, wait for it.
                    v_pending := false;

                    if (v_arvalid = '1') and (v_issue_base = v_req_base) then
                        v_pending := true;
                    end if;

                    if (not v_pending) and (v_fill_count > 0) then
                        for k in 0 to v_fill_count - 1 loop
                            v_idx := (v_fill_rdptr + k) mod g_MAX_OUTSTANDING;
                            if r_fill_base_mem(v_idx) = v_req_base then
                                v_pending := true;
                            end if;
                        end loop;
                    end if;

                    -- Schedule a burst read for this cache line on a miss.
                    if (not v_pending) and (v_fill_count < g_MAX_OUTSTANDING) and (v_arvalid = '0') then
                        v_issue_base := v_req_base;
                        v_issue_line := v_cache_victim;
                        v_araddr     := v_req_base;
                        v_arvalid    := '1';

                        v_cache_valid(v_cache_victim) := '0';
                        v_cache_victim := f_next_ptr(v_cache_victim, C_CACHE_LINES);
                    end if;
                end if;
            end if;

            -- Accept one new request each cycle while the request FIFO has space.
            if (avmm_s_address_val = '1') and ((v_req_count < g_MAX_OUTSTANDING) or v_dequeue) then
                r_req_mem(v_req_wrptr) <= avmm_s_address;
                v_enqueue := true;
            end if;

            if v_enqueue then
                v_req_wrptr := f_next_ptr(v_req_wrptr, g_MAX_OUTSTANDING);
                v_req_count := v_req_count + 1;
            end if;

            if v_dequeue then
                v_req_rdptr := f_next_ptr(v_req_rdptr, g_MAX_OUTSTANDING);
                if v_req_count > 0 then
                    v_req_count := v_req_count - 1;
                end if;
            end if;

            if v_req_count = g_MAX_OUTSTANDING then
                r_avmm_s_busy <= '1';
            else
                r_avmm_s_busy <= '0';
            end if;

            r_req_rdptr <= v_req_rdptr;
            r_req_wrptr <= v_req_wrptr;
            r_req_count <= v_req_count;

            r_fill_rdptr    <= v_fill_rdptr;
            r_fill_wrptr    <= v_fill_wrptr;
            r_fill_count    <= v_fill_count;
            r_fill_beat_idx <= v_fill_beat;

            r_cache_valid  <= v_cache_valid;
            r_cache_victim <= v_cache_victim;

            r_arvalid    <= v_arvalid;
            r_araddr     <= v_araddr;
            r_issue_base <= v_issue_base;
            r_issue_line <= v_issue_line;

        end if;
    end process;

end arc_avmm_to_axi4_rd;
