# reticulate::source_python("save_mudata.py")
# source("save_mae.R")
#
#
# save_gz <- function(object, dname=NULL, x_name=NULL, y_name=NULL, prefix="", ...) {
#   if (is.null(x_name)) {
#     stop("Need to provide key name of list containing list of X matrices")
#   }
#
#   if (is.null(y_name)) {
#     stop("Need to provide key name of list containing dataframe of metadata")
#   }
#
#   if (is.null(dname)) {
#     stop("Did not provide unique dataset name")
#   }
#
#   # Var names being the column ones
#   # Sample names being the row names
#   X <- object[[x_name]]
#   X_dim <- dim(X[[1]])
#
#   y <- object[[y_name]]
#
#   if (length(y) == X_dim[1] ) {
#     # Found rows being samples here
#     var_names <- lapply(X, colnames)
#     sample_names <- X[[1]] |> rownames()
#   } else if (length(y) == X_dim[2]) {
#     # Found rows being variables here
#     var_names <- lapply(X, rownames)
#     sample_names <- X[[1]] |> colnames()
#   }
#
#
#   save_mudata(object = object, dname = dname, x_name = x_name, y_name = y_name,
#               var_names = var_names, sample_names = sample_names)
#
#   save_mae(object = object, dname = dname, x_name = x_name, y_name = y_name)
#
#   # Then move this to unique folder
#   dname_folder <- dir.create(dname)
#
#   # Move the generated files or folders into the directory
#   mudata_file <- paste0(dname, ".h5mu")
#   mae_folder <- paste0(dname, "_mae_data")
#
#
#   # Move the mudata file
#   if (file.exists(mudata_file)) {
#     file.rename(mudata_file, file.path(dname, mudata_file))
#   }
#
#   # Move the mae folder (if it exists)
#   if (dir.exists(mae_folder)) {
#     file.rename(mae_folder, file.path(dname, mae_folder))
#   }
#
#   # Compress the directory into a .tar.gz file
#   gz_file <- paste0(dname, ".tar.gz")
#   tar(gz_file, files = dname, compression = "gzip")
#
#   # Clean up: Remove the uncompressed directory after archiving
#   unlink(dname, recursive = TRUE)
#
#   message("Saved and compressed dataset as ", gz_file)
# }
