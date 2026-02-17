library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avmm_to_axi4_rd is

    generic
    (
        g_ADDR_WIDTH            : integer := 29;
        g_DATA_WIDTH            : integer := 128
    );
    port 
    (
        axi_aresetn             : in std_logic;
        axi_aclk                : in std_logic;

        avmm_s_read             : in std_logic;
        avmm_s_address          : in std_logic_vector(g_ADDR_WIDTH-1 downto 0);
        avmm_s_readdata_val     : out std_logic;
        avmm_s_readdata         : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
        avmm_s_busy             : out std_logic;

        axi_m_axi_arid          : out std_logic_vector(3 downto 0);
        axi_m_axi_araddr        : out std_logic_vector(28 downto 0);
        axi_m_axi_arlen         : out std_logic_vector(7 downto 0);
        axi_m_axi_arsize        : out std_logic_vector(2 downto 0);
        axi_m_axi_arburst       : out std_logic_vector(1 downto 0);
        axi_m_axi_arlock        : out std_logic_vector(0 downto 0);
        axi_m_axi_arcache       : out std_logic_vector(3 downto 0);
        axi_m_axi_arprot        : out std_logic_vector(2 downto 0);
        axi_m_axi_arqos         : out std_logic_vector(3 downto 0);
        axi_m_axi_arvalid       : out std_logic;
        axi_m_axi_arready       : in std_logic;
        axi_m_axi_rready        : out std_logic;
        axi_m_axi_rlast         : in std_logic;
        axi_m_axi_rvalid        : in std_logic;
        axi_m_axi_rresp         : in std_logic_vector(1 downto 0);
        axi_m_axi_rid           : in std_logic_vector(3 downto 0);
        axi_m_axi_rdata         : in std_logic_vector(127 downto 0)
   );

end entity;

architecture arc_avmm_to_axi4_rd of avmm_to_axi4_rd is
   
   -- SM Definition
   type state_type is (idle, process_read_op_set_read_address, process_read_op_get_read_responce, trap);
                       
   signal next_state, current_state: state_type;
   
   
    -- Output Registers
 
   
   
    -- Input Registers

   
    -- Temp Signals
    signal r_avmm_s_read             : std_logic;
    signal r_avmm_s_address          : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    signal r_avmm_s_readdata_val     : std_logic;
    signal r_avmm_s_readdata         : std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal r_avmm_s_busy             : std_logic;


    signal r_axi_m_axi_arid          : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_araddr        : std_logic_vector(28 downto 0);
    signal r_axi_m_axi_arlen         : std_logic_vector(7 downto 0);
    signal r_axi_m_axi_arsize        : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_arburst       : std_logic_vector(1 downto 0);
    signal r_axi_m_axi_arlock        : std_logic_vector(0 downto 0);
    signal r_axi_m_axi_arcache       : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_arprot        : std_logic_vector(2 downto 0);
    signal r_axi_m_axi_arqos         : std_logic_vector(3 downto 0);
    signal r_axi_m_axi_arvalid       : std_logic;
    signal w_axi_m_axi_arready       : std_logic;
    signal r_axi_m_axi_rready        : std_logic;
    signal w_axi_m_axi_rlast         : std_logic;
    signal w_axi_m_axi_rvalid        : std_logic;
    signal w_axi_m_axi_rresp         : std_logic_vector(1 downto 0);
    signal w_axi_m_axi_rid           : std_logic_vector(3 downto 0);
    signal w_axi_m_axi_rdata         : std_logic_vector(127 downto 0);
   
   
   
   
   
    -- Temp SM Signals
    signal r_sm_process_read_op_set_read_address_arready_asserted       : std_logic := 'U';
    signal r_sm_process_read_op_set_read_address_rvalid_asserted        : std_logic := 'U';

   
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
    w_axi_m_axi_arready <=   axi_m_axi_arready;
    axi_m_axi_rready    <= r_axi_m_axi_rready;
    w_axi_m_axi_rlast   <=   axi_m_axi_rlast;
    w_axi_m_axi_rvalid  <=   axi_m_axi_rvalid;
    w_axi_m_axi_rresp   <=   axi_m_axi_rresp;
    w_axi_m_axi_rid     <=   axi_m_axi_rid;
    w_axi_m_axi_rdata   <=   axi_m_axi_rdata;

    main_process:
    process(axi_aresetn, axi_aclk)
    begin
    if axi_aresetn = '0' then


        -- Temp Signals
        r_avmm_s_read         <= '0';
        r_avmm_s_address      <= (others => '0');
        r_avmm_s_readdata_val <= '0';
        r_avmm_s_readdata     <= (others => '0');
        r_avmm_s_busy         <= '0';


        r_axi_m_axi_arid            <= (others => '0');
        r_axi_m_axi_araddr          <= (others => '0');
        r_axi_m_axi_arlen           <= (others => '0');
        r_axi_m_axi_arsize          <= (others => '0');
        r_axi_m_axi_arburst         <= (others => '0');
        r_axi_m_axi_arlock          <= (others => '0');
        r_axi_m_axi_arcache         <= (others => '0');
        r_axi_m_axi_arprot          <= (others => '0');
        r_axi_m_axi_arqos           <= (others => '0');
        r_axi_m_axi_arvalid         <= '0';
--      w_axi_m_axi_arready         <= '0';
        r_axi_m_axi_rready          <= '0';
--      w_axi_m_axi_rlast           <= '0';
--      w_axi_m_axi_rvalid          <= '0';
--      w_axi_m_axi_rresp           <= (others => '0');
--      w_axi_m_axi_rid             <= (others => '0');
--      w_axi_m_axi_rdata           <= (others => '0');


        -- Temp SM Signals
        r_sm_process_read_op_set_read_address_arready_asserted  <= '0';
        r_sm_process_read_op_set_read_address_rvalid_asserted   <= '0';

  
        current_state <= idle;
      
      
    elsif axi_aclk'event and axi_aclk = '1' then
      


        r_avmm_s_read          <= avmm_s_read and not(r_avmm_s_busy);
        if avmm_s_read = '1' and r_avmm_s_busy = '0' then
            r_avmm_s_address    <= avmm_s_address;
        end if;

        r_avmm_s_readdata_val <= w_axi_m_axi_rvalid and not(r_sm_process_read_op_set_read_address_rvalid_asserted);
        if w_axi_m_axi_rvalid = '1' and r_sm_process_read_op_set_read_address_rvalid_asserted = '0' then
            r_avmm_s_readdata     <= w_axi_m_axi_rdata;
        end if;






        -- SM Derived Signals
        r_avmm_s_busy <= avmm_s_read or r_avmm_s_read;


        r_sm_process_read_op_set_read_address_arready_asserted  <= '0';
        r_sm_process_read_op_set_read_address_rvalid_asserted   <= '0';



        r_axi_m_axi_arid            <= X"8";
        r_axi_m_axi_araddr          <= (others => '0');
        r_axi_m_axi_arlen           <= (others => '0');
        r_axi_m_axi_arsize          <= "100";
        r_axi_m_axi_arburst         <= "01";
        r_axi_m_axi_arlock          <= "0";
        r_axi_m_axi_arcache         <= X"3";    -- Normal, non-cacheable
        r_axi_m_axi_arprot          <= "000";
        r_axi_m_axi_arqos           <= X"F";
        r_axi_m_axi_arvalid         <= '0';

        r_axi_m_axi_rready          <= '0';




        

        case current_state is

            when idle =>
                

            when process_read_op_set_read_address =>

                r_avmm_s_busy <= '1';

                r_axi_m_axi_araddr      <= r_avmm_s_address;
                r_axi_m_axi_arvalid     <= not(r_sm_process_read_op_set_read_address_arready_asserted);

                if w_axi_m_axi_arready = '1' then
                    r_sm_process_read_op_set_read_address_arready_asserted <= '1';
                else
                    r_sm_process_read_op_set_read_address_arready_asserted <= r_sm_process_read_op_set_read_address_arready_asserted;
                end if;


            when process_read_op_get_read_responce =>

                r_avmm_s_busy <= '1';

                r_axi_m_axi_rready      <= w_axi_m_axi_rvalid and not(r_sm_process_read_op_set_read_address_rvalid_asserted);

                if w_axi_m_axi_rvalid = '1' then
                    r_sm_process_read_op_set_read_address_rvalid_asserted <= '1';
                else
                    r_sm_process_read_op_set_read_address_rvalid_asserted <= r_sm_process_read_op_set_read_address_rvalid_asserted;
                end if;
                

            when trap =>


            
    


        end case;
      
        current_state <= next_state;
       


   

    end if;
    end process;
   
   
    sm_process:
    process(current_state, avmm_s_read, r_avmm_s_busy, w_axi_m_axi_arready, w_axi_m_axi_rvalid)
                  
    begin

    case current_state is

        when idle =>
            if avmm_s_read = '1' and r_avmm_s_busy = '0' then
                next_state <= process_read_op_set_read_address;
            else
                next_state <= idle;
            end if;
      
        when process_read_op_set_read_address =>
            if w_axi_m_axi_arready = '1' then
                next_state <= process_read_op_get_read_responce;
            else
                next_state <= process_read_op_set_read_address;
            end if;
      

        when process_read_op_get_read_responce =>
            if w_axi_m_axi_rvalid = '1' then
                next_state <= idle;
            else
                next_state <= process_read_op_get_read_responce;
            end if;
         
      

        when trap =>
            next_state <= trap;
            
    end case;

    end process;


end arc_avmm_to_axi4_rd;
