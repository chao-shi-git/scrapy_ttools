library(networkD3)
library(dplyr)

get_links <- function(c2g_n){
  
  links      = data.frame(c2g_n)
  links$X    = NULL
  links$wid  = rep_len(5,n)
  links
  
}

get_Nodes_cu <- function(){
  
  Nodes_c      = data.frame(links$c,cinfo$display_name[links$c+1])
  Nodes_c$size = sqrt(cinfo$view_per_day[links$c+1])   
  
  Nodes_cu = unique.data.frame(Nodes_c)
  nc       = dim(Nodes_cu)[1]
  
  Nodes_cu$group = rep_len(1,nc)
  Nodes_cu$group = cinfo$last_game[Nodes_cu$link]
  
  Nodes_cu        = Nodes_cu[,c(1,2,4,3)]
  names(Nodes_cu) = c('link','name','group','size')
  
  Nodes_cu
  
}

get_Nodes_gu <- function(){
  
  Nodes_g = data.frame(links$g,ginfo$team_name[links$g+1])
  Nodes_gu = unique.data.frame(Nodes_g)
  
  ng = dim(Nodes_gu)[1]
  
  Nodes_gu$group = rep_len('TEAMS',ng)
  Nodes_gu$size  = sqrt(ginfo$team_view_per_day[Nodes_gu$link+1])
  
  names(Nodes_gu) = c('link','name','group','size')
  Nodes_gu
  
}


# read files in -- these are processed files using Python
cinfo = read.csv('./data_safe/channelsinfo_clean.csv')
ginfo = read.csv('./data_safe/teamsinfo_clean.csv')
c2g   = read.csv('./data_safe/testc2g.csv')
g2c   = read.csv('./data_safe/testg2c.csv')


# # ===== input slicing method 3 -- search with channel name ====
# c_name_ls = c("towelliee","sodapoppin","trumpsc","thijshs","forsenlol")
# ind_c = which(cinfo$engid %in% c_name_ls)
# c2g_n = c2g[c2g[,2] %in% (ind_c-1),]
# n = dim(c2g_n)[1]

# # ===== input slicing method 4 -- search with team name ====
# g_name_ls = c("SoloMid","Riot Games","Cloud9","Tempo Storm")
# ind_g = which(ginfo$team_name %in% g_name_ls)
# g2c_n = g2c[g2c[,2] %in% (ind_g-1),]
# n = dim(g2c_n)[1]
# 
# c2g_n = data.frame(g2c_n$c, g2c_n$g)


# ===== input slicing method 4.2 -- search with channel name using c2g ===
# g_name_ls = c("SoloMid","Riot Games","Cloud9","Tempo Storm")
subset = ginfo %>% 
  arrange(desc(team_view_per_day)) %>% 
  top_n(10)

g_name_ls = subset$team_name

ind_g = which(ginfo$team_name %in% g_name_ls)
c2g_n = c2g[c2g[,3] %in% (ind_g-1),]
n = dim(c2g_n)[1]


links = get_links(c2g_n)

Nodes_cu  = get_Nodes_cu() # nodes from channels
Nodes_gu  = get_Nodes_gu() # nodes from teams / groups

Nodes_gcu = rbind.data.frame(Nodes_gu,Nodes_cu)

rownames(Nodes_gcu) <- 1:dim(Nodes_gcu)[1]-1

# need to remap indecies here -- pointers now need to point to the subset of data
links$g = match(links$g, Nodes_gu$link) - 1   # remapping, -1 is package specific
links$c = match(links$c, Nodes_cu$link) + dim(Nodes_gu)[1] - 1  # cu comes after gu


forceNetwork(Links = links, Nodes = Nodes_gcu, Source = "c",
             Target = "g", Value = "wid", NodeID = "name",
             Group = "group", Nodesize = "size",opacity = 1, 
             zoom = TRUE,legend = TRUE)
