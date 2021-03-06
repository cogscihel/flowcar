# ---
# title: "Flow data pipeline"
# author: "Ben Cowley (from T.Tammi)"
# note: This script depends on data wrangled in combine_data.R
# ---
# attach packages
library(lme4)
library(viridis)
library(here)
library(gghalves)
library(tidyverse)
library(nlme) #for 'growth-curve' models

source(file.path(here(), 'R', 'utils.R'))
source(file.path(here(), 'R', 'znbnUtils.R'))
# create an output dir for figures
FIGOUT <- TRUE
if (FIGOUT){
  odir <- file.path(here(), 'figures')
  dir.create(odir, showWarnings = FALSE)
}

# Basic violin plot
fss_items %>%
  mutate(participant = fct_reorder(participant, desc(flow), .fun='var')) %>%
  ggplot( aes(x=participant, y=flow)) + 
  geom_half_violin(trim=FALSE, fill="gray", side = "r") +
  geom_boxplot(width=0.1, outlier.shape = NA) +
  geom_hline(yintercept = median(fss_items$flow), color = "red") +
  geom_text(aes(length(unique(fss_items$participant)), median(fss_items$flow), label = "med.\nFlow", vjust = -1)) +
  labs(title="Flow scores per participant", x="Participant", y = "Flow") +
  ylim(2, 7) +
  theme_classic()

fss_items %>%
  mutate(participant = fct_reorder(participant, desc(absorption), .fun='var')) %>%
  ggplot( aes(x=participant, y=absorption)) + 
  # geom_half_violin(trim=FALSE, fill="gray", side = "r") +
  geom_boxplot(width=0.3, outlier.shape = NA, notch = TRUE) +
  geom_hline(yintercept = median(fss_items$absorption), color = "red") +
  geom_text(aes(length(unique(fss_items$participant)), median(fss_items$absorption), label = "med.\nabsorption", vjust = -1)) +
  labs(title="absorption scores per participant", x="Participant", y = "absorption") +
  ylim(2, 7) +
  theme_classic()

if (FIGOUT) ggsave(file.path(odir, "FlowXsubj.svg"))

# plot linear performance
ggplot(fss_learning, aes(cumrun, duration)) +
  geom_point(alpha=.6, size=2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 1, size = 0.5, color="red") +
  facet_wrap(~participant) +
  theme_bw(base_size = 14)
if (FIGOUT)  ggsave(file.path(odir, "PerfXsubj.svg"))

# plot linear performance with power law fit
ggplot(fss_learning, aes(cumrun, duration)) +
  geom_point(alpha=.6, size=2) +
  stat_smooth(method = 'nls', formula = 'y~a*x^b', size = 0.5, se=FALSE, color ="red") +
  facet_wrap(~participant) +
  theme_bw(base_size = 14)
if (FIGOUT)  ggsave(file.path(odir, "PerfXsubj_powerlaw.svg"))

# plot linear performance with power law fit and flow z-scores coloring
ggplot(fss_learning, aes(cumrun, duration, color = z.flow)) +
  geom_point(alpha=.6, size=2) +
  stat_smooth(method = 'nls', formula = 'y~a*x^b', size = 0.5, se=FALSE, color ="red") +
  facet_wrap(~participant) +
  scale_color_viridis() +
  theme_bw(base_size = 14)
if (FIGOUT)  ggsave(file.path(odir, "PerfXsubj_powlxFlow.svg"))

# plot log-log with flow z-scores coloring
rq1a <- ggplot(fss_learning, aes(ln.cumrun, ln.duration, color = z.flow)) +
  geom_point(alpha=.6, size=1) +
  geom_smooth(method = "lm", se = FALSE, linetype = 1, size = 0.5, color="red") +
  facet_wrap(~participant) +
  scale_color_viridis(name="Z_Flow", guide = guide_colorbar(title.position = "top")) +
  xlab("ln(Cumulative runs)") + ylab("ln(Duration)") +
  labs(title = "A") +
  theme(legend.position = c(x=.8, y=.1),
        legend.background = element_rect(fill="white"),
        legend.box.background = element_rect(colour = "black"),
        legend.direction='horizontal',
        panel.background = element_rect(fill = "white",
                                        colour = "lightgrey",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.25, linetype = 'solid',
                                        colour = "grey"),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8),
        axis.line = element_line(colour = "black"),
        strip.background=element_rect(fill="lightgrey", color="black"))
if (FIGOUT)  ggsave(file.path(odir, "PerfXsubj_powlxFlow_loglog.svg"))


# same as above, subset for ID > 9
ggplot(subset(fss_learning, as.numeric(ID) > 9), aes(ln.cumrun, ln.duration, color = z.flow)) +
  geom_point(alpha=.6, size=2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 1, size = 0.5, color="red") +
  facet_wrap(~participant) +
  scale_color_viridis() +
  theme_bw(base_size = 14)

# plot deviation from predicted curve
rq1b <- ggplot(fss_learning, aes(deviation, flow)) +
  geom_point(alpha=.4, size=1) +
  geom_smooth(method = "lm", se = FALSE) + 
  xlab("Deviation score") + ylab("Flow") +
  facet_wrap(~participant) +
  labs(title = "B") +
  theme(legend.position = c(x=.8, y=.1),
        legend.background = element_rect(fill="white"),
        legend.box.background = element_rect(colour = "black"),
        legend.direction='horizontal',
        panel.background = element_rect(fill = "white",
                                        colour = "lightgrey",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.25, linetype = 'solid',
                                        colour = "grey"),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8),
        axis.line = element_line(colour = "black"),
        strip.background=element_rect(fill="lightgrey", color="black"))
if (FIGOUT)  ggsave(file.path(odir, "FlowXdevXsubj.svg"))

# same as above, subset for ID > 9
ggplot(subset(fss_learning, as.numeric(ID) > 9), aes(deviation, flow)) +
  geom_point(alpha=.6, size=2) +
  geom_smooth(method = "lm", se = FALSE, linetype = 1, size = 0.5, color="red") +
  facet_wrap(~participant) +
  scale_color_viridis() +
  theme_bw(base_size = 14)

#Combine Rq1a and b into panel figure
RQ1 <- ggarrange(rq1a, rq1b, font.label = list(size = 10, color = "black", face = "bold"), common.legend = FALSE, hjust = -0.25, ncol = 2, nrow = 1)

### statistical test (linear mixed model) ----
# RQ1 - main replication: does the new dataset replicate the old one?
flow_dev_lmer17 <- lmer(flow ~ deviation + (deviation|participant), 
                      data=filter(fss_learning, as.numeric(ID) < 10))
plot(flow_dev_lmer17) # model diagnostics
qqnorm(residuals(flow_dev_lmer17)) #qq-plot
qqline(residuals(flow_dev_lmer17)) #line of "perfect normality"

flow_dev_lmer19 <- lmer(flow ~ deviation + (deviation|participant), 
                        data=filter(fss_learning, as.numeric(ID) > 9))
plot(flow_dev_lmer19) # model diagnostics
qqnorm(residuals(flow_dev_lmer19)) #qq-plot
qqline(residuals(flow_dev_lmer19)) #line of "perfect normality"

anova(flow_dev_lmer17)
anova(flow_dev_lmer19)

flow_dev_lmer <- lmer(flow ~ deviation + (deviation|participant), data=fss_learning)
anova(flow_dev_lmer)
summary(flow_dev_lmer) # model summary
plot(flow_dev_lmer) # model diagnostics
qqnorm(residuals(flow_dev_lmer)) #qq-plot
qqline(residuals(flow_dev_lmer)) #line of "perfect normality"


### statistical test (linear mixed model), subset with ID > 9 ----
fss_learning_lmer_subset <- lmer(flow ~ deviation + (deviation|participant), data=subset(fss_learning, as.numeric(ID) > 9))
summary(fss_learning_lmer_subset) # model summary
plot(fss_learning_lmer_subset) # model diagnostics
qqnorm(residuals(fss_learning_lmer_subset)) #qq-plot
qqline(residuals(fss_learning_lmer_subset)) #line of "perfect normality"

### statistical test (linear mixed model), subset with ID > 9, effect of learning, both power-law and exponential ----
fss_learning_lmer_subset2p <- lmer(ln.duration ~ ln.cumrun + (ln.cumrun|participant), data=subset(fss_learning, as.numeric(ID) > 9))
fss_learning_lmer_subset2e <- lmer(duration ~ ln.cumrun + (ln.cumrun|participant), data=subset(fss_learning, as.numeric(ID) > 9))
summary(fss_learning_lmer_subset2p) # model summary
plot(fss_learning_lmer_subset2p) # model diagnosticsi
qqnorm(residuals(fss_learning_lmer_subset2p)) #qq-plot
qqline(residuals(fss_learning_lmer_subset2p)) #line of "perfect normality"





### exploration with MWE confidence bands as documented in Korpela et al. (2014) ----
# Plots of all signals with mean sample means (thick solid line), their 95% MWEs (dashed lines), 
# and naive 95% quantiles (dotted thin lines) are shown below. The naive quantiles are computed per 
# time instance, without taking other time instances into account. In a way, a naive quantile 
# corresponds to an area where the “unadjusted p-values” are at least 0.05, while the MWE correspond 
# to area where the “adjusted p-values” (here adjusted taking the multiplicity correction due to 
# autocorrelation structure into account) are at least 0.05. The width of the naive quantile 
# typically provides a lower bound for the width of the respective MWE.

# First, make data wide by cumruns on duration
dat <- game_data %>%
  dplyr::select(participant, cumrun, duration) %>%
  pivot_wider(names_from = cumrun, values_from = duration) %>%
  dplyr::select(-participant)
# index NAs - MWE cannot handle these
idx <- which(apply(dat,2,function(x) all(!is.na(x))))

# Commented here is canonical example for finding curves of multiple datasets, e.g. subgroups
# curves <- lapply(data, function(x) findcurves(x))
# rng <- range(sapply(curves,function(x) range(x[,c("mean0","lo","up")])))
curve <- findcurves(as.matrix(dat[,idx]))
rng <- range(curve[,c("mean0","lo","up")])
plot(c(idx[1],idx[length(idx)]), rng
     , type="n", bty="n", xlab="cumrun", ylab="ms", main = "Group performance 95% CB")
plotlines(curve, idx)

curve17 <- findcurves(as.matrix(dat[1:9,idx]))
curve19 <- findcurves(as.matrix(dat[10:18,idx]))
plot(c(idx[1],idx[length(idx)]), rng
     , type="n", bty="n", xlab="cumrun", ylab="ms", main = "Group performance 95% CB")
plotlines_comp(curve17, idx, col="red")
plotlines_comp(curve19, idx, col="blue")






### SOME BASIC GROWTH CURVE ANALYSIS ----
# All this is doing is testing a series of LMEs on the effect of cumrun on duration. Not
# very exciting. But it is an example of growth curve modelling, for whatever that's worth.
# NB: non-linear factors can be added as (or whatever model you want): 
#   duration + I(duration^2) 
#   duration + I(log(duration))
df.growth <- fss_game %>% dplyr::select(1:9)
# ---- UNCONDITIONAL MEANS MODEL - BASE COMPARISON MODEL ----
um.fit <- lme(fixed = duration ~ 1, 
              random = ~ 1|participant, 
              data = df.growth,
              na.action = na.exclude)
summary(um.fit)
VarCorr(um.fit)
RandomEffects <- as.numeric(VarCorr(um.fit)[,1])
ICC_between <- RandomEffects[1]/(RandomEffects[1]+RandomEffects[2]) # between-person variance
# within-person variance = 100 - (ICC_between * 100)
df.growth$pred.um <- predict(um.fit)
df.growth$resid.um <- residuals(um.fit)
#plotting PREDICTED intraindividual change; overlay PROTOTYPE (average individual)
#create the function for the prototype
fun.um <- function(x) {
  as.numeric(um.fit$coefficients$fixed) + 0*x
}
#add the prototype as an additional layer
ggplot(data = df.growth, aes(x = cumrun, y = pred.um, group = participant)) +
  ggtitle("Unconditional Means Model") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("PREDICTED duration") + #ylim(0,50) +
  stat_function(fun=fun.um, color="red", size = 2)
#plotting RESIDUAL intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = resid.um, group = participant)) +
  ggtitle("Unconditional Means Model") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("RESIDUAL duration")

# ---- FIXED LINEAR RANDOM INTERCEPT GROWTH MODEL (SESSION AS TIME)
fl.ri.fit <- lme(fixed = duration ~ 1 + cumrun, 
                 random = ~ 1|participant, 
                 data = df.growth,
                 na.action = na.exclude)
summary(fl.ri.fit)
#Place individual predictions and residuals into the dataframe
df.growth$pred.fl.ri <- predict(fl.ri.fit)
df.growth$resid.fl.ri <- residuals(fl.ri.fit)
#Create a function for the prototype
fun.fl.ri <- function(x) {
  as.numeric(fl.ri.fit$coefficients$fixed[1]) + as.numeric(fl.ri.fit$coefficients$fixed[2])*x
}
#plotting PREDICTED intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = pred.fl.ri, group = participant)) +
  ggtitle("Fixed Linear, Random Intercept") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("PREDICTED duration") + 
  stat_function(fun=fun.fl.ri, color="red", size = 2)
#plotting RESIDUAL intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = resid.fl.ri, group = participant)) +
  ggtitle("Fixed Linear, Random Intercept") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("RESIDUAL duration")

# ---- RANDOM LINEAR FIXED INTERCEPT GROWTH MODEL (SESSION AS TIME)
ctrl <- lmeControl(opt='optim')
rl.fi.fit <- lme(fixed = duration ~ 1,
                 random = ~ 1 + cumrun|participant,
                 data = df.growth,
                 na.action = na.exclude,
                 control = ctrl)
summary(rl.fi.fit)
#Place individual predictions and residuals into the dataframe
df.growth$pred.rl.fi <- predict(rl.fi.fit)
df.growth$resid.rl.fi <- residuals(rl.fi.fit)
#Create a function for the prototype
fun.rl.fi <- function(x) {
  as.numeric(rl.fi.fit$coefficients$fixed[1]) + 0*x
}
#plotting PREDICTED intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = pred.rl.fi, group = participant)) +
  ggtitle("Random Linear, Fixed Intercept") +
  geom_line() +
  xlab("cumrun") +
  ylab("PREDICTED duration") +
  stat_function(fun=fun.rl.fi, color="red", size = 2)
#plotting RESIDUAL intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = resid.rl.fi, group = participant)) +
  ggtitle("Random Linear, Fixed Intercept") +
  geom_line() +
  xlab("cumrun") +
  ylab("RESIDUAL duration")

# ---- RANDOM LINEAR SLOPES AND INTERCEPTS ----
rl.ri.fit <- lme(fixed = duration ~ 1 + cumrun,
                 random = ~ 1 + cumrun|participant,
                 data = df.growth,
                 na.action = na.exclude,
                 control = ctrl)
summary(rl.ri.fit)
intervals(rl.ri.fit)
#Place individual predictions and residuals into the dataframe
df.growth$pred.rl.ri <- predict(rl.ri.fit)
df.growth$resid.rl.ri <- residuals(rl.ri.fit)
#Create a function for the prototype
fun.rl.ri <- function(x) {
  as.numeric(rl.ri.fit$coefficients$fixed[1]) + as.numeric(rl.ri.fit$coefficients$fixed[2])*x
}
#plotting PREDICTED intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = pred.rl.ri, group = participant)) +
  ggtitle("Random Linear, Random Intercept") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("PREDICTED duration") +
  stat_function(fun=fun.rl.ri, color="red", size = 2)
#plotting RESIDUAL intraindividual change
ggplot(data = df.growth, aes(x = cumrun, y = resid.rl.ri, group = participant)) +
  ggtitle("Random Linear, Random Intercept") +
  #  geom_point() + 
  geom_line() +
  xlab("cumrun") + 
  ylab("RESIDUAL duration")
# significance of random slopes: compare models by anova() for difference in fit between two nested models
anova(um.fit,fl.ri.fit)
anova(fl.ri.fit,rl.ri.fit)
