
library(lineup)
library(ggplot2)
library(reshape2)

# set working dir
setwd("/projects/loliver/SPINS_GLM_Test")

#glob2rx("sub*spm_mat.csv")

# find spm and afni design matrices for each participant
spm_mat_list <- list.files(path= ".", recursive=T, pattern="^sub.*spm_mat\\.csv$")
afni_mat_list <- list.files(path= "./", recursive=T, pattern="^sub.*mat.xmat\\.1D$")

# find nistats design matrices for each participant
nistats_mat_list <- list.files(path= "/projects/ttan/fMRI_tools/analysis/first_lvl",recursive=T,full.names=T, 
                               pattern="^sub.*emp_combined_dm\\.tsv$")
nistats_mat_list <- nistats_mat_list[1:10]  # cut ones in tmp folder

# read in mats
spm_mat <- lapply(spm_mat_list, read.csv, header=F, col.names=c("ea_block","ea_pmod","circles","ea_press","circ_press",
                    rep("confounds",19)))

afni_mat <- lapply(afni_mat_list, read.table, header=F, skip=32, sep=" ", col.names=c("skip",rep("polort",18),"ea_block",
                    "ea_pmod","circles","ea_press","circ_press","FD","x","y","z","roll","pitch","yaw","xder","yder","zder",
                    "rollder","pitchder","yawder","mean_wm","mean_csf"))

nistats_mat <- lapply(nistats_mat_list, read.table, header=F, skip=1, col.names=c("skip","ea_block","ea_press","circles",
                    "circ_press","ea_pmod","mean_csf","mean_wm","FD","trans_x","trans_x_der","trans_y",
                    "trans_y_der","trans_z","trans_z_der","rot_x","rot_x_der","rot_y","rot_y_der","rot_z","rot_z_der",
                    "drift_1","drift_2","drift_3","drift_4","drift_5","constant"))


# add subject ids
names(spm_mat) <- substring(spm_mat_list,1,11)
names(afni_mat) <- substring(afni_mat_list,1,11)
names(nistats_mat) <- substring(nistats_mat_list,58,68)

# collapse values across runs (SPM and nistats - not necessary with changes) and remove unwanted columns
for (i in names(spm_mat)) {
  spm_mat[[i]]$TR <- 1:819
  #  spm_mat[[i]][274:546,1:19] <- spm_mat[[i]][274:546,20:38]
  #  spm_mat[[i]][547:819,1:19] <- spm_mat[[i]][547:819,39:57]
}

for (i in names(nistats_mat)) {
  nistats_mat[[i]] <- nistats_mat[[i]][,-1]
  nistats_mat[[i]]$TR <- 1:819
  #  nistats_mat[[i]][274:546,1:26] <- nistats_mat[[i]][274:546,27:52]
  #  nistats_mat[[i]][547:819,1:26] <- nistats_mat[[i]][547:819,53:78]
}

for (i in names(afni_mat)) {
  afni_mat[[i]] <- afni_mat[[i]][,-1]
  afni_mat[[i]]$TR <- 1:819
}

# correlate columns across programs for each participant

all_corrs <- matrix(ncol=15,nrow=9) 
rownames(all_corrs)=names(spm_mat)
colnames(all_corrs)=c("SA_ea_block","SA_ea_pmod","SA_circles","SA_ea_press","SA_circ_press",
                      "SN_ea_block","SN_ea_pmod","SN_circles","SN_ea_press","SN_circ_press",
                      "AN_ea_block","AN_ea_pmod","AN_circles","AN_ea_press","AN_circ_press")

for (i in names(spm_mat)) {
  all_corrs[i,1:5] <- corbetw2mat(spm_mat[[i]][,1:5],afni_mat[[i]][,19:23], what="paired")
  all_corrs[i,6:10] <- corbetw2mat(spm_mat[[i]][,1:5],nistats_mat[[i]][,c(1,5,3,2,4)], what="paired")
  all_corrs[i,11:15] <- corbetw2mat(afni_mat[[i]][,19:23],nistats_mat[[i]][,c(1,5,3,2,4)], what="paired")
}

all_corrs <- all_corrs[,c(1,6,11,2,7,12,3,8,13,4,9,14,5,10,15)]

#write.csv(all_corrs,file="/projects/loliver/SPINS_GLM_Test/design_mat_corrs_fixed.csv",row.names = T)


# melt df to visualize across programs
spm_mat_long <- lapply(spm_mat, melt, id.vars = "TR")
afni_mat_long <- lapply(afni_mat, melt, id.vars = "TR")
nistats_mat_long <- lapply(nistats_mat, melt, id.vars = "TR")

all_mats <- vector(mode = "list", length = 9)
names(all_mats) <- names(spm_mat)

for (i in names(spm_mat)) {
  spm_mat_long[[i]]$program <- c(rep("SPM",19656))
  afni_mat_long[[i]]$program <- c(rep("afni",31122))
  nistats_mat_long[[i]]$program <- c(rep("ni",21294))
  all_mats[[i]] <- rbind(spm_mat_long[[i]],afni_mat_long[[i]],nistats_mat_long[[i]])
}


# visualize 

for (i in names(spm_mat)) {
   ggplot(data.frame(all_mats[[i]][all_mats[[i]]$variable=="ea_pmod",]), aes(x = TR, y = value, col=program)) + 
   geom_line()
}
  
ggplot(data.frame(all_mats[["sub-CMH0057"]][all_mats[["sub-CMH0057"]]$variable=="ea_pmod",]), aes(x = TR, y = value, col=program)) + 
  geom_line() #+ facet_wrap("variable")

ggplot(data.frame(all_mats[["sub-CMH0057"]][all_mats[["sub-CMH0057"]]$variable=="ea_block",]), aes(x = TR, y = value, col=program)) + 
  geom_line() #+ facet_wrap("variable")

ggplot(data.frame(all_mats[["sub-CMH0065"]][all_mats[["sub-CMH0065"]]$variable=="ea_pmod",]), aes(x = TR, y = value, col=program)) + 
  geom_line() #+ facet_wrap("variable")

ggplot(data.frame(all_mats[["sub-CMH0093"]][all_mats[["sub-CMH0093"]]$variable=="ea_pmod",]), aes(x = TR, y = value, col=program)) + 
  geom_line() #+ facet_wrap("variable")



# visualize 

ggplot(data.frame(spm_mat[["sub-CMH0057"]]), aes(x = 1:819, y = ea_press)) + 
  geom_line()

ggplot(data.frame(afni_mat[["sub-CMH0057"]]), aes(x = 1:819, y = ea_press)) + 
  geom_line()

ggplot(data.frame(nistats_mat[["sub-CMH0057"]]), aes(x = 1:819, y = ea_press)) + 
  geom_line()


ggplot(data.frame(spm_mat[["sub-CMH0159"]]), aes(x = 1:819, y = ea_pmod)) + 
  geom_line()

ggplot(data.frame(afni_mat[["sub-CMH0159"]]), aes(x = 1:819, y = ea_pmod)) + 
  geom_line()

ggplot(data.frame(nistats_mat[["sub-CMH0159"]]), aes(x = 1:819, y = ea_pmod)) + 
  geom_line()


ggplot(data.frame(afni_mat[["sub-CMH0093"]]), aes(x = 1:819, y = ea_pmod)) + 
  geom_line()

ggplot(data.frame(nistats_mat[["sub-CMH0093"]]), aes(x = 1:819, y = ea_pmod)) + 
  geom_line()


