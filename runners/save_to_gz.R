# This script reads in simulation experiment data
# then saved them into gz consists of the following:
# - dname_MAE_data
# - dname.h5mu

library(devtools)
load_all()


sim_data_list <- readRDS("simulation_data_list_format.rds")


d <- sim_data_list$`simdata_n-100_p-1000_j-3_rho-0_dt-0`



save_gz(object = d, dname = d$label, x_name = "X", y_name = "Y")





