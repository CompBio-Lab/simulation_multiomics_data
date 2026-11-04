#!/usr/bin/env Rscript
# Generation only: no glmnet, CV fitting, or plots.
# Rscript generate_final.R /path/final_simulation
args <- commandArgs(trailingOnly=TRUE)
script <- sub("^--file=","",commandArgs()[grepl("^--file=",commandArgs())][1])
root <- dirname(normalizePath(script))
source(file.path(root,"simulation.R"))
out <- if(length(args)) args[1] else file.path(root,"final_simulation")
if(dir.exists(out) && length(list.files(out,all.files=TRUE,no..=TRUE)))
  stop("Output directory is not empty. Choose a new directory to preserve existing data.")
dir.create(out,recursive=TRUE,showWarnings=FALSE)



cfg <- list(n=500,p=3000,j=3,pc_mu=0,weight_sampler="efficient")
generation_seed <- 101L

deltas <- 0:3
rhos <- c(0,.5,1)
scenarios <- list(
  S0_linear=list(effect="linear",noise_sd=c(1,1,1),n_batches=0,batch_sd=0),
  S1_nonlinear=list(effect="two_sided",noise_sd=c(1,1,1),n_batches=0,batch_sd=0),
  S2_batch=list(effect="linear",noise_sd=c(1,1,1),n_batches=2,batch_sd=1),
  S3_noise=list(effect="linear",noise_sd=c(1,1,3),n_batches=0,batch_sd=0))
id_for <- function(sc,dt,rho) paste0(sc,"_n-",cfg$n,"_p-",cfg$p,
                                     "_dt-",dt,"_rho-",gsub("\\.","p",as.character(rho)))
# Every data set has the same sample IDs and class allocation.
# Save once and reuse across all scenarios/methods, not dataset-name hashes.
y <- make_labels(cfg$n)
ids <- paste0("patient_",seq_len(cfg$n))



manifest <- list(); mapping <- list(); batch_tables <- list()
for(rho in rhos) for(dt in deltas) for(sc in names(scenarios)) {
  id <- id_for(sc,dt,rho)
  reuse <- sc=="S1_nonlinear" && dt==0
  physical_id <- if(reuse) id_for("S0_linear",dt,rho) else id
  mapping[[length(mapping)+1L]] <- data.frame(scenario=sc,dt=dt,rho=rho,
                                              logical_dataset=id,physical_dataset=physical_id,reused_reference=reuse,
                                              data_path=paste0(physical_id,"/data.rds"))
  if(reuse) next
  set.seed(generation_seed)
  d <- do.call(sim_data,c(cfg,list(dt=dt,rho=rho,return_truth=TRUE),scenarios[[sc]]))


  stopifnot(identical(d$Y,y),length(d$X)==cfg$j,
            length(d$truth$signal_index)==if(dt==0) 0L else floor(.1*cfg$p))
  for(x in d$X) stopifnot(identical(dim(x),as.integer(c(cfg$n,cfg$p))),
                          identical(rownames(x),ids),!anyDuplicated(colnames(x)),
                          all(is.finite(x)))
  #folder <- file.path(out,id); dir.create(folder)
  # write.csv(data.frame(sample_name=ids,response=d$Y,batch=d$truth$batch,
  #                      outer_fold=fold),file.path(folder,"metadata.csv"),row.names=FALSE)

  saveRDS(d[c("X","Y")],file.path(out, paste0(id,".rds")))




  if(sc=="S2_batch") {
    tab <- as.data.frame(table(response=y,batch=d$truth$batch))
    if(any(tab$Freq==0)) stop("A fold is missing a batch/class combination: ",id)
    tab$dataset <- id; batch_tables[[id]] <- tab
  }

  rm(d); invisible(gc())
}

message("Finished: 45 data sets, 48 logical combinations. No model diagnostics run.")
