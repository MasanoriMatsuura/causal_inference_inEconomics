* Stata Tutorial - Instrumental Variable



* Load data
use "https://www.stata.com/data/jwooldridge/eacsap/card.dta", clear

/*
lwage			log of hourly wages in 1976
educ			years of education
exper			years of labor market experience
expersq			the square of years of labor market experience
married			married
black			black
south76			lives in the south
smsa66			lives in a standard metropolitan statistical area
reg661-reg669	regional dummy variables

nearc4			lived close to a college that offered 4 year courses in 1966

*/

/***** OLS regression *****/
reg lwage educ exper expersq black south smsa smsa66 reg661-reg668

/***** 2SLS *****/
ivregress 2sls lwage (educ=nearc4) exper expersq black south smsa smsa66 reg661-reg668

reg educ nearc4 exper expersq black south smsa smsa66 reg661-reg668
predict edu_hat, xb

reg lwage edu_hat exper expersq black south smsa smsa66 reg661-reg668
* note that the standard error is incorrect here

/***** Wald estimator *****/
gen college=1 if educ>=16
	replace college=0 if educ<16


/* first stage*/
reg college nearc4 exper expersq black south smsa smsa66 reg661-reg668
local a=_b[nearc4]

/* reduced form */
reg lwage nearc4 exper expersq black south smsa smsa66 reg661-reg668
local b=_b[nearc4]

display `b'/`a'

ivregress 2sls lwage (college=nearc4) exper expersq black south smsa smsa66 reg661-reg668

/* over-identification test */
ivregress 2sls lwage (college=nearc2 nearc4) exper expersq black south smsa smsa66 reg661-reg668

estat overid
