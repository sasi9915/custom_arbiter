library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_wr is

    generic
    (
        g_ADDR_WIDTH            : integer := 29;
        g_DATA_WIDTH            : integer := 128
    );
    port 
    (
        axi_aresetn             : in std_logic;
        axi_aclk                : in std_logic;

        avmm_s_write            : in std_logic;
        avmm_s_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        avmm_s_writedata        : in std_logic_vector(g_DATA_WIDTH-1 downto 0);
        avmm_s_busy             : out std_logic;

        axi_m_axi_awid          : out std_logic_vector(3 downto 0);
        axi_m_axi_awaddr        : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        axi_m_axi_awlen         : out std_logic_vector(7 downto 0);
        axi_m_axi_awsize        : out std_logic_vector(2 downto 0);
        axi_m_axi_awburst       : out std_logic_vector(1 downto 0);
        axi_m_axi_awlock        : out std_logic_vector(0 downto 0);
        axi_m_axi_awcache       : out std_logic_vector(3 downto 0);
        axi_m_axi_awprot        : out std_logic_vector(2 downto 0);
        axi_m_axi_awqos         : out std_logic_vector(3 downto 0);
        axi_m_axi_awvalid       : out std_logic;
        axi_m_axi_awready       : in std_logic;
        axi_m_axi_wdata         : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
        axi_m_axi_wstrb         : out std_logic_vector(15 downto 0);
        axi_m_axi_wlast         : out std_logic;
        axi_m_axi_wvalid        : out std_logic;
        axi_m_axi_wready        : in std_logic;
        axi_m_axi_bready        : out std_logic;
        axi_m_axi_bid           : in std_logic_vector(3 downto 0);
        axi_m_axi_bresp         : in std_logic_vector(1 downto 0);
        axi_m_axi_bvalid        : in std_logic
   );

end entity;

architecture arc_avmm_to_axi4_wr of avmm_to_axi4_wr is
   
   -- SM Definition
   type state_type is (idle, process_write_op_set_write_address, process_write_op_set_write_data, process_write_op_get_write_responce, trap);
                       
   signal next_state, current_state: state_type;
   
   
    -- Output Registers
 
   
   
    -- Input Registers

   
    -- Temp Signals
    signal r_avmm_s_write            : std_logic;
    signal r_avmm_s_address          : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    signal r_avmm_s_writedata        : std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal r_avmm_s_busy             : std_logic;


    signal r_axi_m_axi_awid          : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awaddr        : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    signal r_axi_m_axi_awlen         : std_logic_vector(7 downto 0);
    signal r_axi_m_axi_awsize        : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_awburst       : std_logic_vector(1 downto 0);
    signal r_axi_m_axi_awlock        : std_logic_vector(0 downto 0);
    signal r_axi_m_axi_awcache       : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awprot        : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_awqos         : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_awvalid       : std_logic;
    signal w_axi_m_axi_awready       : std_logic;
    signal r_axi_m_axi_wdata         : std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal r_axi_m_axi_wstrb         : std_logic_vector(g_DATA_WIDTH/8-1 downto 0);
    signal r_axi_m_axi_wlast         : std_logic;
    signal r_axi_m_axi_wvalid        : std_logic;
    signal w_axi_m_axi_wready        : std_logic;
    signal r_axi_m_axi_bready        : std_logic;
    signal w_axi_m_axi_bid           : std_logic_vector(3 downto 0);
    signal w_axi_m_axi_bresp         : std_logic_vector(1 downto 0);
    signal w_axi_m_axi_bvalid        : std_logic;
   
   
   
   
   
    -- Temp SM Signals
    signal r_sm_process_write_op_set_write_address_awready_asserted     : std_logic := 'U';
    signal r_sm_process_write_op_set_write_address_wready_asserted      : std_logic := 'U';
    signal r_sm_process_write_op_set_write_address_bvalid_asserted      : std_logic := 'U';

   
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
    w_axi_m_axi_awready <=   axi_m_axi_awready;
    axi_m_axi_wdata     <= r_axi_m_axi_wdata;
    axi_m_axi_wstrb     <= r_axi_m_axi_wstrb;
    axi_m_axi_wlast     <= r_axi_m_axi_wlast;
    axi_m_axi_wvalid    <= r_axi_m_axi_wvalid;
    w_axi_m_axi_wready  <=   axi_m_axi_wready;
    axi_m_axi_bready    <= r_axi_m_axi_bready;
    w_axi_m_axi_bid     <=   axi_m_axi_bid;
    w_axi_m_axi_bresp   <=   axi_m_axi_bresp;
    w_axi_m_axi_bvalid  <=   axi_m_axi_bvalid;

    main_process:
    process(axi_aresetn, axi_aclk)
    begin
    if axi_aresetn = '0' then


        -- Temp Signals
        r_avmm_s_write     <= '0';
        r_avmm_s_address   <= (others => '0');
        r_avmm_s_writedata <= (others => '0');
        r_avmm_s_busy      <= '0';


        r_axi_m_axi_awid          <= (others => '0');
        r_axi_m_axi_awaddr        <= (others => '0');
        r_axi_m_axi_awlen         <= (others => '0');
        r_axi_m_axi_awsize        <= (others => '0');
        r_axi_m_axi_awburst       <= (others => '0');
        r_axi_m_axi_awlock        <= (others => '0');
        r_axi_m_axi_awcache       <= (others => '0');
        r_axi_m_axi_awprot        <= (others => '0');
        r_axi_m_axi_awqos         <= (others => '0');
        r_axi_m_axi_awvalid       <= '0';
--      w_axi_m_axi_awready       <= '0';
        r_axi_m_axi_wdata         <= (others => '0');
        r_axi_m_axi_wstrb         <= (others => '0');
        r_axi_m_axi_wlast         <= '0';
        r_axi_m_axi_wvalid        <= '0';
--      w_axi_m_axi_wready        <= '0';
        r_axi_m_axi_bready        <= '0';
--      w_axi_m_axi_bid           <= (others => '0');
--      w_axi_m_axi_bresp         <= (others => '0');
--      w_axi_m_axi_bvalid        <= '0';


        -- Temp SM Signals
        r_sm_process_write_op_set_write_address_awready_asserted <= '0';
        r_sm_process_write_op_set_write_address_wready_asserted  <= '0';
        r_sm_process_write_op_set_write_address_bvalid_asserted  <= '0';


  
        current_state <= idle;
      
      
    elsif axi_aclk'event and axi_aclk = '1' then
      


        r_avmm_s_write          <= avmm_s_write and not(r_avmm_s_busy);
        if avmm_s_write = '1' and r_avmm_s_busy = '0' then
            r_avmm_s_address    <= avmm_s_address;
            r_avmm_s_writedata  <= avmm_s_writedata;
        end if;





        -- SM Derived Signals
        r_avmm_s_busy <= avmm_s_write or r_avmm_s_write;


        r_sm_process_write_op_set_write_address_awready_asserted <= '0';
        r_sm_process_write_op_set_write_address_wready_asserted  <= '0';
        r_sm_process_write_op_set_write_address_bvalid_asserted  <= '0';



        r_axi_m_axi_awid        <= X"0";
        r_axi_m_axi_awaddr      <= (others => '0');
        r_axi_m_axi_awlen       <= X"00";
        r_axi_m_axi_awsize      <= "100";
        r_axi_m_axi_awburst     <= "01";
        r_axi_m_axi_awlock      <= "0";
        r_axi_m_axi_awcache     <= X"3";    -- Normal, non-cacheable
        r_axi_m_axi_awprot      <= "000";
        r_axi_m_axi_awqos       <= X"0";
        r_axi_m_axi_awvalid     <= '0';

        r_axi_m_axi_wdata       <= (others => '0');
        r_axi_m_axi_wstrb       <= (others => '1');
        r_axi_m_axi_wlast       <= '1';
        r_axi_m_axi_wvalid      <= '0';

        r_axi_m_axi_bready      <= '0';

        

        case current_state is

            when idle =>
                

            when process_write_op_set_write_address =>

                r_avmm_s_busy <= '1';

                r_axi_m_axi_awaddr      <= r_avmm_s_address;
                r_axi_m_axi_awvalid     <= not(r_sm_process_write_op_set_write_address_awready_asserted);

                if w_axi_m_axi_awready = '1' then
                    r_sm_process_write_op_set_write_address_awready_asserted <= '1';
                else
                    r_sm_process_write_op_set_write_address_awready_asserted <= r_sm_process_write_op_set_write_address_awready_asserted;
                end if;


            when process_write_op_set_write_data =>

                r_avmm_s_busy <= '1';

                r_axi_m_axi_wdata       <= r_avmm_s_writedata;
                r_axi_m_axi_wvalid      <= not(r_sm_process_write_op_set_write_address_wready_asserted);
                
                if w_axi_m_axi_wready = '1' then
                    r_sm_process_write_op_set_write_address_wready_asserted <= '1';
                else
                    r_sm_process_write_op_set_write_address_wready_asserted <= r_sm_process_write_op_set_write_address_wready_asserted;
                end if;


            when process_write_op_get_write_responce =>

                r_avmm_s_busy <= '1';

                r_axi_m_axi_bready      <= w_axi_m_axi_bvalid and not(r_sm_process_write_op_set_write_address_bvalid_asserted);

                if w_axi_m_axi_bvalid = '1' then
                    r_sm_process_write_op_set_write_address_bvalid_asserted <= '1';
                else
                    r_sm_process_write_op_set_write_address_bvalid_asserted <= r_sm_process_write_op_set_write_address_bvalid_asserted;
                end if;
                

            when trap =>


            
    


        end case;
      
        current_state <= next_state;
       


   

    end if;
    end process;
   
   
    sm_process:
    process(current_state, avmm_s_write, r_avmm_s_busy, w_axi_m_axi_awready, w_axi_m_axi_wready, w_axi_m_axi_bvalid)
                  
    begin

    case current_state is

        when idle =>
            if avmm_s_write = '1' and r_avmm_s_busy = '0' then
                next_state <= process_write_op_set_write_address;
            else
                next_state <= idle;
            end if;
      
        when process_write_op_set_write_address =>
            if w_axi_m_axi_awready = '1' then
                next_state <= process_write_op_set_write_data;
            else
                next_state <= process_write_op_set_write_address;
            end if;
      
        when process_write_op_set_write_data =>
            if w_axi_m_axi_wready = '1' then
                next_state <= process_write_op_get_write_responce;
            else
                next_state <= process_write_op_set_write_data;
            end if;

        when process_write_op_get_write_responce =>
            if w_axi_m_axi_bvalid = '1' then
                next_state <= idle;
            else
                next_state <= process_write_op_get_write_responce;
            end if;
         
      

        when trap =>
            next_state <= trap;
            
    end case;

    end process;


end arc_avmm_to_axi4_wr;
