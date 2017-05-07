library(networkD3)
library(dplyr)


# read files in -- these are processed files using Python
cinfo = read.csv('./data_safe/channelsinfo_clean.csv')
ginfo = read.csv('./data_safe/teamsinfo_clean.csv')
c2g   = read.csv('./data_safe/testc2g.csv')
g2c   = read.csv('./data_safe/testg2c.csv')

# ===== input slicing method 1 -- first n edges ====
# n = 200
# c2g_n = c2g[1:n,]


# ===== input slicing method 2 -- random n edges ====
# n = 200
# sample_ind = sample.int(dim(c2g)[1],n)
# c2g_n = c2g[sample_ind,]

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
g_name_ls = c("SoloMid","Riot Games","Cloud9","Tempo Storm")
subset = ginfo %>% 
  arrange(desc(team_view_per_day)) %>% 
  top_n(10)

g_name_ls = subset$team_name

ind_g = which(ginfo$team_name %in% g_name_ls)
c2g_n = c2g[c2g[,3] %in% (ind_g-1),]
n = dim(c2g_n)[1]




# define links (or edges) in the graph
links      = data.frame(c2g_n)
links$X    = NULL
links$wid = rep_len(5,n)
# c    g wid
# 1    0 2112   5
# 2    3 1865   5
# 3    3 2097   5
# 4    3 1814   5
# 5    4 1470   5
# 6    6 2106   5

Nodes_c      = data.frame(links$c,cinfo$display_name[links$c+1])
Nodes_c$size = log2(cinfo$channel_followers[links$c+1])   
# links.c cinfo.display_name.links.c...1.
# 1        0                        Janowicz
# 2        3                       cnotbusch
# 3        3                       cnotbusch
# 4        3                       cnotbusch
# 5        4                       GruntarTV
# 6        6                        Freezecz
# 7        7                      UmiNoKaiju
# 8        7                      UmiNoKaiju
# 9        7                      UmiNoKaiju
# 10       7                      UmiNoKaiju

Nodes_cu = unique.data.frame(Nodes_c)
# links.c cinfo.display_name.links.c...1.
# 1       0                        Janowicz
# 2       3                       cnotbusch
# 5       4                       GruntarTV
# 6       6                        Freezecz
# 7       7                      UmiNoKaiju

nc = dim(Nodes_cu)[1]

Nodes_cu$group = rep_len(1,nc)
Nodes_cu$group = cinfo$last_game[Nodes_cu$link]

rownames(Nodes_cu) <- 1:nc-1
Nodes_cu = Nodes_cu[,c(1,2,4,3)]




Nodes_g = data.frame(links$g,ginfo$team_name[links$g+1])
Nodes_gu = unique.data.frame(Nodes_g)

ng = dim(Nodes_gu)[1]

Nodes_gu$group = rep_len(2,ng)
Nodes_gu$size  = seq(5,5+ng-1)

rownames(Nodes_gu) <- 1:ng-1


names(Nodes_gu) = c('link','name','group','size')
names(Nodes_cu) = c('link','name','group','size')

Nodes_gcu = rbind.data.frame(Nodes_gu,Nodes_cu)

rownames(Nodes_gcu) <- 1:dim(Nodes_gcu)[1]-1


links$g = match(links$g, Nodes_gu$link) - 1   # remapping
links$c = match(links$c, Nodes_cu$link) + dim(Nodes_gu)[1] - 1


MyClickScript <- 'alert("You clicked " + d.name + " which is in row " +
       (d.index + 1) +  " of your original R data frame");'

forceNetwork(Links = links, Nodes = Nodes_gcu, Source = "c",
             Target = "g", Value = "wid", NodeID = "name",
             Group = "group", Nodesize = "size",opacity = 1, 
             zoom = TRUE,legend = TRUE,
             clickAction = MyClickScript)
