##############################################
# Twitch Graph -- 
# Scraping Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 5/7/2017
##############################################

vars_c = sort(cinfo$engid)
vars_g = sort(ginfo$team_name)

# top 3 channels with most viewers per follower per day
c_subset  = cinfo %>% arrange(desc(view_per_follower_per_day)) %>% top_n(1)
c_name_ls = c_subset$engid

# top 3 teams with most viewers per day
g_subset  = ginfo %>% arrange(desc(team_view_per_day)) %>% top_n(10)
g_name_ls = g_subset$team_name

navbarPage(div(style='font-size: 25px;', "Twitch Graph"),
           windowTitle = "Olivia loves colorful bubbles",
           id="nav",
           collapsible = TRUE,
           
           # ======================================================================================
           # ====================                                         =========================
           # ====================     Tab 1 Starts -- Interactive map     =========================
           # ====================                                         =========================
           # ======================================================================================
           
           # --------------------------------------------------------------------------------------
           #   This main tab layout and style are inspired by Joe Cheng's 'superzip' example
           #               https://shiny.rstudio.com/gallery/superzip-example.html
           # --------------------------------------------------------------------------------------
           tabPanel("Interactive Graph",
                    div(class="outer",
                        
                        tags$head(
                          includeCSS("styles.css")
                        ),
                        
                        tags$style(type = "text/css",
                                   ".radio label {font-size: 11px;}
                                   "),
                        
                        # ============================================== #
                        #              THE GRAPH -- networkD3            #
                        # ============================================== #
                        
                        forceNetworkOutput("force",width="100%", height="100%"),
                        

                        # =========================================================== #
                        #    floating control panel hosting most of the user input    #
                        # =========================================================== #
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 300, height = "auto",
                                      
                                      h2("Pick and Choose"),
                                      
                                      # ---------------------------------------------------------------------------
                                      # Each fluidRow is for 1 input check box
                                      # Due to specific contidionalPanel design, checkboxGroupInput is not chosen
                                      # ---------------------------------------------------------------------------
                                      selectizeInput('channalname', 'Channel Name', choices = vars_c, selected = c_name_ls, multiple = TRUE),
                                      selectizeInput('teamname', 'Team Name', choices = vars_g, selected = g_name_ls, multiple = TRUE),
                                      sliderInput("expand", "Extra Expansion", 0, min = 0,
                                                  max = 3, step = 1),
                                      sliderInput("opacity", "Opacity", 0.9, min = 0.1,
                                                  max = 1, step = .1),
                                      # verbatimTextOutput('test'),
                                      
                                      # action button -- user triggers a plot refresh when all changes are made,
                                      #                  since backend calculation and map refresh take some time 
                                      #                  (filtering > weighted average > plot)
                                      actionButton("do", "Update Plots",icon("refresh"), width="100%")
                                      
                        ),  # end of absolutePanel "controls"
                        
                        
                        
                        
                        
                        
                        
                        tags$div(id="cite",
                                 'Twitch Graph --- ', tags$em('Chao Shi'), '05/2017'
                        )
                        
                    ) # end of div
           ),
           
           # ======================================================================================
           # ====================   Tab 1 ENDS -- Interactive Map Tab     =========================
           # ====================                                         =========================
           # ====================              Tab 2 STARTS               =========================
           # ======================================================================================
           
           tabPanel("Channels",
                    
                    DT::dataTableOutput("channelinfo")   # in the server.R logic, user can click 
                                                          # on multiple rows, markers will show
                                                          # up on tab 1 map (read lat-lng, plot)
           ), # end of tabPanel
           
           
           # ======================================================================================
           # ====================                 Tab 2 ENDS              =========================
           # ====================                                         =========================
           # ====================                Tab 3 STARTS             =========================
           # ======================================================================================
           
           tabPanel("Teams",
                    
                    DT::dataTableOutput("teaminfo")   # in the server.R logic, user can click
                                                          # on multiple rows, markers will show
                                                          # up on tab 1 map (read lat-lng, plot)
           ), # end of tabPanel
           
           # ======================================================================================
           # ====================                 Tab 3 Ends              =========================
           # ====================                                         =========================
           # ====================                Tab 4 Starts             =========================
           # ======================================================================================
           
           tabPanel("About",
                    includeMarkdown("README.md")),
           
           conditionalPanel("false", icon("crosshair"))
)
