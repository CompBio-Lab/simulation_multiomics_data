# MESSI controlled simulations. Dependency: MASS.
# Source this file instead of the previous generator/helper definitions.

.scalar <- function(x, name, lower=-Inf, upper=Inf, integer=FALSE) {
  if (!is.numeric(x) || length(x)!=1L || !is.finite(x) ||
      x<lower || x>upper || (integer && x!=floor(x)))
    stop(name, " is outside its permitted range", call.=FALSE)
  invisible(x)
}
.per_modality <- function(x, j, name) {
  if (!is.numeric(x) || !(length(x) %in% c(1L,j)) ||
      any(!is.finite(x)) || any(x<0))
    stop(name, " must be a nonnegative scalar or vector of length j")
  rep(x, length.out=j)
}

create_sigma <- function(rho, j) {
  .scalar(j, "j", 2, integer=TRUE)
  .scalar(rho, "rho", 0, 1)
  S <- matrix(rho,j,j); diag(S) <- 1
  S
}
sample_latent <- function(n,j,rho,pc_mu=0) {
  .scalar(n,"n",2,integer=TRUE); .scalar(pc_mu,"pc_mu")
  MASS::mvrnorm(n=n,mu=rep(pc_mu,j),Sigma=create_sigma(rho,j))
}
make_labels <- function(n) c(rep(1,n%/%2),rep(0,n-n%/%2))

apply_class_signal <- function(latent,y,dt,effect="linear",subgroup=NULL) {
  effect <- match.arg(effect,c("linear","two_sided"))
  .scalar(dt,"dt",0)
  if (length(y)!=nrow(latent) || anyNA(y) || any(!y %in% c(0,1)))
    stop("y must contain one binary label per sample")
  if (effect=="linear") return(sweep(latent,1,dt*y,"+"))
  if (is.null(subgroup) || length(subgroup)!=length(y) ||
      anyNA(subgroup) || any(!subgroup %in% c(-1,1)))
    stop("two_sided requires one +/-1 subgroup per sample")
  sweep(latent,1,dt*y*subgroup,"+")
}

create_weight <- function(j,p,type="O",sampler=c("legacy","efficient")) {
  sampler <- match.arg(sampler)
  .scalar(j,"j",2,integer=TRUE); .scalar(p,"p",1,integer=TRUE)
  if (sampler=="efficient")
    return(matrix(runif(j*p,0.2,0.3)*sample(c(-1,1),j*p,TRUE),j,p))
  if (j*p>2*p^2) stop("legacy weight sampler needs j <= 2*p; use efficient")
  # Original draw order retained; O(p^2) temporary storage is intentional.
  d1 <- runif(p^2,-0.3,-0.2)
  d2 <- runif(p^2,0.2,0.3)
  matrix(sample(c(d1,d2),j*p),j,p)
}
project_to_features <- function(latent,weights,is_signal) {
  nm <- paste0("omic",seq_len(ncol(latent)))
  X <- lapply(seq_along(nm),function(m) {
    a <- latent[,m,drop=FALSE] %*% weights[m,,drop=FALSE]
    colnames(a) <- paste(nm[m],if(is_signal) "true_var" else "noise_var",
                         seq_len(ncol(a)),sep="_")
    rownames(a) <- paste("patient",seq_len(nrow(a)),sep="_")
    a
  })
  names(X) <- nm; X
}
# User's original helper was not provided. This defines iid N(0,1) errors.
get_normal_noise_mat <- function(x) {
  matrix(rnorm(length(x)),nrow(x),ncol(x),dimnames=dimnames(x))
}

sim_multiomics <- function(n,p,j,dt,rho=0,pc_mu=0,add_dt=TRUE,
                           return_truth=FALSE,weight_sampler="legacy") {
  .scalar(dt,"dt",0)
  latent_base <- sample_latent(n,j,rho,pc_mu)
  latent <- latent_base; out <- list()
  if (add_dt) {
    out$Y <- make_labels(n)
    latent <- apply_class_signal(latent,out$Y,dt)
  }
  weights <- create_weight(j,p,sampler=weight_sampler)
  out$X <- project_to_features(latent,weights,add_dt)
  if (return_truth) out$truth <- list(latent_base=latent_base,
                                      latent=latent,weights=weights)
  out
}

# Randomized within each outcome class. Per-class counts differ by <=1.
# This is a balanced experimental allocation, not unrestricted iid batching.
make_batch <- function(y,n_batches) {
  .scalar(n_batches,"n_batches",2,integer=TRUE)
  if (min(table(y))<n_batches) stop("Each class needs >= n_batches samples")
  b <- integer(length(y))
  for (cl in c(0,1)) {
    ii <- which(y==cl)
    order <- sample.int(n_batches)
    allocation <- rep(order,length.out=length(ii))
    b[ii] <- allocation[sample.int(length(ii))]
  }
  b
}

sim_data <- function(n,p,j,dt,rho,pc_mu,noise_sd=1,return_truth=FALSE,
                     effect=c("linear","two_sided"),
                     n_batches=0,batch_sd=0,weight_sampler="legacy") {
  effect <- match.arg(effect)
  .scalar(n,"n",4,integer=TRUE); .scalar(p,"p",10,integer=TRUE)
  .scalar(j,"j",2,integer=TRUE); .scalar(dt,"dt",0)
  if(p%%2!=0) stop("p must be even (legacy interface)")
  .scalar(n_batches,"n_batches",0,integer=TRUE)
  if(n_batches==1) stop("n_batches must be 0 or >=2")
  noise_sd <- .per_modality(noise_sd,j,"noise_sd")
  batch_sd <- .per_modality(batch_sd,j,"batch_sd")
  if(n_batches==0 && any(batch_sd>0)) stop("Positive batch_sd needs n_batches >=2")
  if(n_batches>n%/%2) stop("Each class needs >= n_batches samples")
  k <- floor(p*0.1)
  a <- sim_multiomics(n,k,j,dt,rho,pc_mu,TRUE,TRUE,weight_sampler)
  b <- sim_multiomics(n,p-k,j,dt,0,pc_mu,FALSE,TRUE,weight_sampler)
  signal <- Map(cbind,a$X,b$X)
  # All extra draws happen AFTER the original latent/loading/error draws.
  # Same-seed scenario comparisons therefore preserve those draws.
  errors <- lapply(seq_along(signal),function(m)
    get_normal_noise_mat(signal[[m]])*noise_sd[m])
  names(errors) <- names(signal)
  subgroup <- rep(1,n)
  if(effect=="two_sided") {
    # Shared sign across modalities; independently sampled across subjects.
    # Population symmetry holds; finite samples need not be exactly balanced.
    subgroup <- sample(c(-1,1),n,replace=TRUE)
    a$truth$latent <- apply_class_signal(a$truth$latent_base,a$Y,dt,
                                        effect,subgroup)
    a$X <- project_to_features(a$truth$latent,a$truth$weights,TRUE)
    signal <- Map(cbind,a$X,b$X)
  }
  batch <- rep(NA_integer_,n)
  offsets <- lapply(signal,function(x) {x[]<-0; x})
  shifts <- NULL
  if(n_batches>=2) {
    batch <- make_batch(a$Y,n_batches)
    shifts <- lapply(seq_len(j),function(m) {
      z <- matrix(rnorm(n_batches*p),n_batches,p)
      # Center across batches; expected marginal squared shift = batch_sd^2.
      z <- sweep(z,2,colMeans(z),"-")/sqrt(1-1/n_batches)*batch_sd[m]
      colnames(z) <- colnames(signal[[m]])
      rownames(z) <- paste0("batch",seq_len(n_batches))
      z
    })
    names(shifts) <- names(signal)
    offsets <- lapply(seq_len(j),function(m) {
      z <- shifts[[m]][batch,,drop=FALSE]
      dimnames(z) <- dimnames(signal[[m]]); z
    })
    names(offsets) <- names(signal)
  }
  # At dt=0 no feature is outcome-associated. Use unique noise_var names
  # so name-based legacy evaluators do not treat the first block as positive.
  if(dt==0) for(m in seq_len(j)) {
    nm <- paste(names(signal)[m],"noise_var",seq_len(p),sep="_")
    colnames(signal[[m]]) <- nm
    colnames(errors[[m]]) <- nm
    colnames(offsets[[m]]) <- nm
    if(!is.null(shifts)) colnames(shifts[[m]]) <- nm
  }
  active <- if(dt>0) seq_len(k) else integer(0)
  X <- Map(function(s,e,b) s+e+b,signal,errors,offsets)
  out <- list(X=X,Y=a$Y)
  if(return_truth) out$truth <- list(
    # noiseless retains its original meaning: before measurement/batch noise.
    noiseless=signal,error=errors,batch_effect=offsets,
    noise_sd=noise_sd,true_num_vars=length(active),
    signal_index=active,background_index=setdiff(seq_len(p),active),
    candidate_signal_index=seq_len(k),structural_background_index=seq.int(k+1,p),
    latent_base=a$truth$latent_base,latent=a$truth$latent,
    signal_weights=a$truth$weights,background_latent=b$truth$latent,
    background_weights=b$truth$weights,subgroup=subgroup,batch=batch,
    batch_shifts=shifts,
    parameters=list(n=n,p=p,j=j,dt=dt,rho=rho,pc_mu=pc_mu,
      effect=effect,noise_sd=noise_sd,n_batches=n_batches,batch_sd=batch_sd,
      weight_sampler=weight_sampler))
  out
}
