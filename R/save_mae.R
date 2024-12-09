# # mae related
# save_mae <- function(object, dname=NULL, x_name=NULL, y_name=NULL, prefix="", output_dir,...) {
#   blocks <- object[[x_name]]
#   metadata <- object[[y_name]] # Metadata should be dataframe
#   if (!is.data.frame(metadata) & is.atomic(metadata)) {
#     metadata <- data.frame(response = metadata)
#   }
#
#   # Check if all matrices have the same number of rows (n)
#   same_n <- all(sapply(blocks, nrow) == nrow(blocks[[1]]))
#   # Check if its N x p then tranpose it to p x N
#   match_dim <- nrow(metadata) == nrow(blocks[[1]])
#   # ---------------------------------------------------------------------
#   if (same_n & match_dim) {
#     # Need to transpose it to p_i * n for MAE use
#     blocks <- lapply(blocks, t)
#   } else {
#     cat("\nRight format, nothing done\n")
#   }
#   mae <- MultiAssayExperiment::MultiAssayExperiment(
#     experiments = blocks,
#     metadata    = metadata
#   )
#   # Note, the delayed matrix is affecting the subset of metadata
#   # so manually add response here
#   if (! ("response" %in% colnames(metadata))) {
#     stop("Could not find 'response' column in metadata")
#   }
#   mae$response <- metadata$response
#   # Save to HDF5 format
#   outdir <- paste0(dname, "_", "mae_data")
#   MultiAssayExperiment::saveHDF5MultiAssayExperiment(
#     mae, dir=outdir,
#     prefix=prefix,
#     replace=TRUE)
#
#   message("Saved to ", outdir)
# }
