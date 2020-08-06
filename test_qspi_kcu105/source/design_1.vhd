library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity design_1 is
  port (
    CLK_IN1_D_clk_n : in STD_LOGIC;
    CLK_IN1_D_clk_p : in STD_LOGIC;
    SPI_0_io0_i : in STD_LOGIC;
    SPI_0_io0_o : out STD_LOGIC;
    SPI_0_io0_t : out STD_LOGIC;
    SPI_0_io1_i : in STD_LOGIC;
    SPI_0_io1_o : out STD_LOGIC;
    SPI_0_io1_t : out STD_LOGIC;
    SPI_0_io2_i : in STD_LOGIC;
    SPI_0_io2_o : out STD_LOGIC;
    SPI_0_io2_t : out STD_LOGIC;
    SPI_0_io3_i : in STD_LOGIC;
    SPI_0_io3_o : out STD_LOGIC;
    SPI_0_io3_t : out STD_LOGIC;
    SPI_0_sck_i : in STD_LOGIC;
    SPI_0_sck_o : out STD_LOGIC;
    SPI_0_sck_t : out STD_LOGIC;
    SPI_0_ss_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    SPI_0_ss_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    SPI_0_ss_t : out STD_LOGIC;
    UART_rxd : in STD_LOGIC;
    UART_txd : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    reset : in STD_LOGIC
  );
end design_1;

architecture STRUCTURE of design_1 is

  component design_1_clk_wiz_0_0 is
  port (
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC;
    reset : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_out3 : out STD_LOGIC
  );
  end component design_1_clk_wiz_0_0;

  component design_1_axi_quad_spi_0_0 is
  port (
    ext_spi_clk : in STD_LOGIC;
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    io0_i : in STD_LOGIC;
    io0_o : out STD_LOGIC;
    io0_t : out STD_LOGIC;
    io1_i : in STD_LOGIC;
    io1_o : out STD_LOGIC;
    io1_t : out STD_LOGIC;
    io2_i : in STD_LOGIC;
    io2_o : out STD_LOGIC;
    io2_t : out STD_LOGIC;
    io3_i : in STD_LOGIC;
    io3_o : out STD_LOGIC;
    io3_t : out STD_LOGIC;
    sck_i : in STD_LOGIC;
    sck_o : out STD_LOGIC;
    sck_t : out STD_LOGIC;
    ss_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    ss_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    ss_t : out STD_LOGIC;
    ip2intc_irpt : out STD_LOGIC
  );
  end component design_1_axi_quad_spi_0_0;

  signal CLK_IN1_D_1_CLK_N : STD_LOGIC;
  signal CLK_IN1_D_1_CLK_P : STD_LOGIC;

  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  attribute MARK_DEBUG of clk_wiz_0_clk_out1 : signal is std.standard.true;
  signal clk_wiz_0_clk_out2 : STD_LOGIC;
  signal clk_wiz_0_clk_out3 : STD_LOGIC;
  attribute MARK_DEBUG of clk_wiz_0_clk_out3 : signal is std.standard.true;

  signal reset_1 : STD_LOGIC;

  signal axi_quad_spi_0_SPI_0_IO0_O : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO0_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO0_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO0_T : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO1_I : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO1_I : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO1_O : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO1_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO1_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO1_T : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO2_I : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO2_I : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO2_O : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO2_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO2_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO2_T : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO3_I : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO3_I : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO3_O : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO3_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_IO3_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_IO3_T : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SCK_I : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SCK_I : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SCK_O : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SCK_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SCK_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SCK_T : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SS_I : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SS_I : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SS_O : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SS_O : signal is std.standard.true;
  signal axi_quad_spi_0_SPI_0_SS_T : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_SPI_0_SS_T : signal is std.standard.true;

  signal axi_uartlite_0_UART_TxD : STD_LOGIC;

  signal axi_quad_spi_0_ip2intc_irpt : STD_LOGIC;
  attribute MARK_DEBUG of axi_quad_spi_0_ip2intc_irpt : signal is std.standard.true;

  signal axi_interconnect_0_M03_AXI_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M03_AXI_ARREADY : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_ARVALID : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M03_AXI_AWREADY : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_AWVALID : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_BREADY : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_M03_AXI_BVALID : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M03_AXI_RREADY : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_0_M03_AXI_RVALID : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_0_M03_AXI_WREADY : STD_LOGIC;
  signal axi_interconnect_0_M03_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_0_M03_AXI_WVALID : STD_LOGIC;

  signal proc_sys_reset_0_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );

begin

clk_wiz_0: component design_1_clk_wiz_0_0
     port map (
      clk_in1_n => CLK_IN1_D_1_CLK_N,
      clk_in1_p => CLK_IN1_D_1_CLK_P,
      clk_out1 => clk_wiz_0_clk_out1,
      clk_out2 => clk_wiz_0_clk_out2,
      clk_out3 => clk_wiz_0_clk_out3,
      reset => reset_1
    );

axi_quad_spi_0: component design_1_axi_quad_spi_0_0
     port map (
      ext_spi_clk => clk_wiz_0_clk_out3,
      io0_i => axi_quad_spi_0_SPI_0_IO0_I,
      io0_o => axi_quad_spi_0_SPI_0_IO0_O,
      io0_t => axi_quad_spi_0_SPI_0_IO0_T,
      io1_i => axi_quad_spi_0_SPI_0_IO1_I,
      io1_o => axi_quad_spi_0_SPI_0_IO1_O,
      io1_t => axi_quad_spi_0_SPI_0_IO1_T,
      io2_i => axi_quad_spi_0_SPI_0_IO2_I,
      io2_o => axi_quad_spi_0_SPI_0_IO2_O,
      io2_t => axi_quad_spi_0_SPI_0_IO2_T,
      io3_i => axi_quad_spi_0_SPI_0_IO3_I,
      io3_o => axi_quad_spi_0_SPI_0_IO3_O,
      io3_t => axi_quad_spi_0_SPI_0_IO3_T,
      ip2intc_irpt => axi_quad_spi_0_ip2intc_irpt,
      s_axi_aclk => clk_wiz_0_clk_out1,
      s_axi_araddr(6 downto 0) => axi_interconnect_0_M03_AXI_ARADDR(6 downto 0),
      s_axi_aresetn => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arready => axi_interconnect_0_M03_AXI_ARREADY,
      s_axi_arvalid => axi_interconnect_0_M03_AXI_ARVALID,
      s_axi_awaddr(6 downto 0) => axi_interconnect_0_M03_AXI_AWADDR(6 downto 0),
      s_axi_awready => axi_interconnect_0_M03_AXI_AWREADY,
      s_axi_awvalid => axi_interconnect_0_M03_AXI_AWVALID,
      s_axi_bready => axi_interconnect_0_M03_AXI_BREADY,
      s_axi_bresp(1 downto 0) => axi_interconnect_0_M03_AXI_BRESP(1 downto 0),
      s_axi_bvalid => axi_interconnect_0_M03_AXI_BVALID,
      s_axi_rdata(31 downto 0) => axi_interconnect_0_M03_AXI_RDATA(31 downto 0),
      s_axi_rready => axi_interconnect_0_M03_AXI_RREADY,
      s_axi_rresp(1 downto 0) => axi_interconnect_0_M03_AXI_RRESP(1 downto 0),
      s_axi_rvalid => axi_interconnect_0_M03_AXI_RVALID,
      s_axi_wdata(31 downto 0) => axi_interconnect_0_M03_AXI_WDATA(31 downto 0),
      s_axi_wready => axi_interconnect_0_M03_AXI_WREADY,
      s_axi_wstrb(3 downto 0) => axi_interconnect_0_M03_AXI_WSTRB(3 downto 0),
      s_axi_wvalid => axi_interconnect_0_M03_AXI_WVALID,
      sck_i => axi_quad_spi_0_SPI_0_SCK_I,
      sck_o => axi_quad_spi_0_SPI_0_SCK_O,
      sck_t => axi_quad_spi_0_SPI_0_SCK_T,
      ss_i(0) => axi_quad_spi_0_SPI_0_SS_I(0),
      ss_o(0) => axi_quad_spi_0_SPI_0_SS_O(0),
      ss_t => axi_quad_spi_0_SPI_0_SS_T
    );

xlconcat_0: component design_1_xlconcat_0_0
     port map (
      In0(0) => axi_uartlite_0_interrupt,
      In1(0) => axi_timer_0_interrupt,
      In2(0) => axi_quad_spi_0_ip2intc_irpt,
      dout(2 downto 0) => xlconcat_0_dout(2 downto 0)
    );

  -- from clock manager
  CLK_IN1_D_1_CLK_N <= CLK_IN1_D_clk_n;
  CLK_IN1_D_1_CLK_P <= CLK_IN1_D_clk_p;
  SPI_0_io0_o <= axi_quad_spi_0_SPI_0_IO0_O;
  SPI_0_io0_t <= axi_quad_spi_0_SPI_0_IO0_T;
  SPI_0_io1_o <= axi_quad_spi_0_SPI_0_IO1_O;
  SPI_0_io1_t <= axi_quad_spi_0_SPI_0_IO1_T;
  SPI_0_io2_o <= axi_quad_spi_0_SPI_0_IO2_O;
  SPI_0_io2_t <= axi_quad_spi_0_SPI_0_IO2_T;
  SPI_0_io3_o <= axi_quad_spi_0_SPI_0_IO3_O;
  SPI_0_io3_t <= axi_quad_spi_0_SPI_0_IO3_T;
  SPI_0_sck_o <= axi_quad_spi_0_SPI_0_SCK_O;
  SPI_0_sck_t <= axi_quad_spi_0_SPI_0_SCK_T;
  SPI_0_ss_o(0) <= axi_quad_spi_0_SPI_0_SS_O(0);
  SPI_0_ss_t <= axi_quad_spi_0_SPI_0_SS_T;
  UART_txd <= axi_uartlite_0_UART_TxD;
  axi_quad_spi_0_SPI_0_IO0_I <= SPI_0_io0_i;
  axi_quad_spi_0_SPI_0_IO1_I <= SPI_0_io1_i;
  axi_quad_spi_0_SPI_0_IO2_I <= SPI_0_io2_i;
  axi_quad_spi_0_SPI_0_IO3_I <= SPI_0_io3_i;
  axi_quad_spi_0_SPI_0_SCK_I <= SPI_0_sck_i;
  axi_quad_spi_0_SPI_0_SS_I(0) <= SPI_0_ss_i(0);
  axi_uartlite_0_UART_RxD <= UART_rxd;
  clk_out2 <= clk_wiz_0_clk_out2;
  reset_1 <= reset;

end STRUCTURE;
