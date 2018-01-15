#' Binarize a vector of posterior probabilities.
#'
#' This function allows to binarize a matrix of posterior probabilities. Input is a matrix containing the posterior probabilities for the component with the larger mean from a Gaussian Mixture Model across different regions. 
#' @param mixmdl Vector of posterior probabilities between 0 and 1.
#' @param normal Vector of positions indicating the indices that identify posteriors assigned to normal cells.
#' @param tumor Vector of positions indicating the indices that identify posteriors assigned to tumor cells.
#' @param threshold Posterior threshold level. The presence of a CNV is assigned to a cell if its posterior exceeds the threshold.
#' @param withna Should posteriors that can't be assigned to component 1, but also not to component2, be set to 0 or NA (defualt is set to NA).
#' @keywords Binarizee vector
#' @export
#' @examples
#' binarizeCalls(mixmdl,normal,tumor,threshold,withna=T)

binarizeCalls = function (mixmdl,normal,tumor,threshold,withna=T){
  g1=length(which(mixmdl[normal]>threshold))
  g2=length(which((1-mixmdl[normal])>threshold))
  status=""
  if (g1>g2){
    status="del"
    resV=ifelse(mixmdl<(1-threshold),1,0)
    if (withna==T){
      resV[which(mixmdl<threshold & mixmdl>(1-threshold))]=NA
    }
    
  }
  else{
    status="amp"
    resV=ifelse(mixmdl>threshold,1,0)
    if (withna==T){
      resV[which(mixmdl<threshold & mixmdl>(1-threshold))]=NA
    }
  }
  res <- list("integer" = resV, "status" = status)
  return(res)
}

#' Binarize a matrix of posterior probabilities.
#'
#' This function calls binarizeCalls() on all rows of a matrix
#' @param mixmdl Vector of posterior probabilities between 0 and 1.
#' @param normal Vector of positions indicating the indices that identify posteriors assigned to normal cells.
#' @param tumor Vector of positions indicating the indices that identify posteriors assigned to tumor cells.
#' @param threshold Posterior threshold level. The presence of a CNV is assigned to a cell if its posterior exceeds the threshold.
#' @param withna Should posteriors that can't be assigned to component 1, but also not to component2, be set to 0 or NA (defualt is set to NA).
#' @keywords Binarizee vector
#' @export
#' @examples
#' binarizeCalls(mixmdl,normal,tumor,threshold,withna=T)

binarizeMatrix = function (mixmat,normal,tumor,threshold,withna=T){
  res=apply(mixmat,2,function (x) binarizeCalls(x,normal,tumor,threshold,withna=T)$integer)
  nms=apply(mixmat,2,function (x) binarizeCalls(x,normal,tumor,threshold,withna=T)$status)
  colnames(res)=paste(nms,colnames(res),sep="_")
  return(res)
}

#' Visualize a matrix of binary CNV assignments.
#'
#' This function visualizes a matrix of binary CNV assignment. A 1 indicates the presence, a 0 the absence of a CNV
#' @param mati A cells X regions matrix 
#' @param normal Vector of positions indicating the indices that identify posteriors assigned to normal cells.
#' @param tumor Vector of positions indicating the indices that identify posteriors assigned to tumor cells.
#' @param patients A vector of length(nrow(mati)) indicating the patient for each cell.
#' @param patient Optional: Which patient should the matrix be plotted for.
#' @keywords Binarizee vector
#' @export
#' @examples
#' plotBinaryMat(mati,patients,normal,tumor,patient="MGH96")

plotBinaryMat = function(mati,patients,normal,tumor,patient=NULL){
  celltypes=rep("Tumor",length(normal)+length(tumor));celltypes[normal]="Normal";names(celltypes)=c(names(normal),names(tumor))
  patientcolors =data.frame(celltypes)
  patientcolors=cbind(patientcolors,patients)
  rownames(patientcolors)=names(celltypes)
  rownames(mati)=names(celltypes)
  if (!is.null(patient)){
    pheatmap::pheatmap(t(mati[which(patients==patient),]),cluster_cols=T, cutree_cols = 3,annotation=patientcolors, col=c("lightgrey","black"),border_color = "grey60",show_colnames = F,clustering_distance_cols="euclidean")
  }
  else{
    pheatmap::pheatmap(t(mati),cluster_cols=T, cutree_cols = 3,annotation=patientcolors, col=c("lightgrey","black"),border_color = "grey60",show_colnames = F,clustering_distance_cols="euclidean")
  }
}

