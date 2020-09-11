vivado -nojournal -nolog -mode batch -notrace -source getBER.tcl -tclargs 0 2 "/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0"  "20200612_v1"
# awk -F "," '{print $10,$11,$12,$13,$14,$15,$16,$17,$18}' promcontent/ila_data_addr_000000C0_nwd_00000050.csv | head > test.txt
