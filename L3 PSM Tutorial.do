* Stata Tutorial - Propensity Score Matching

/***************** PSMATCH2 ******************/
/* install psmatch2 package */
ssc install psmatch2, replace

* Load data
webuse cattaneo2.dta, clear

reg bweight mbsmoke
reg bweight mbsmoke mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order

/* step 1. identify variables of interest */
/*
treatment: mbsmoke (cigarettes smoked during pregnancy)
outcome:   bweight (infant birthweight (grams))

*/
/* then check whether control and treatment groups are similar */
ttest mmarried, by(mbsmoke)
ttest mhisp, by(mbsmoke)
ttest fhisp, by(mbsmoke)
ttest foreign, by(mbsmoke)
ttest mage, by(mbsmoke)
ttest medu, by(mbsmoke)
ttest fage, by(mbsmoke)
ttest fedu, by(mbsmoke)
ttest nprenatal, by(mbsmoke)
ttest monthslb, by(mbsmoke)
ttest order, by(mbsmoke)

/* step 2. propensity score estimation */
probit mbsmoke mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order

predict pscore, pr

/* step 3 and 4 can be done using psmatch2 package */
psmatch2 mbsmoke mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order, common
/****** figure 1 distribution of p-score ******/
psgraph

pstest mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order
pstest mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order, both


/* step 5. ATT estimation */
* 1-to-1 matching
psmatch2 mbsmoke, outcome(bweight) pscore(pscore) common

* 10-to-1 matching
psmatch2 mbsmoke, outcome(bweight) pscore(pscore) common neighbor(10)

* kernel matching
psmatch2 mbsmoke, outcome(bweight) pscore(pscore) common kernel

* local linear regression matching
psmatch2 mbsmoke, outcome(bweight) pscore(pscore) common llr

/* take a look at data */

* bootstrap standard error
bootstrap "psmatch2 mbsmoke, outcome(bweight) pscore(pscore) common" "r(att)"

/***************** TEFFECTS ******************/
teffects psmatch (bweight) (mbsmoke mmarried mhisp fhisp foreign alcohol mage medu fage fedu nprenatal monthslb order, probit), atet
