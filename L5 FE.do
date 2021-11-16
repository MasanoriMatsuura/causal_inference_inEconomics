* Stata Tutorial - Fixed effect estimation

* Load data
use "http://cameron.econ.ucdavis.edu/musbook/mus08psidextract.dta", clear

/*
exp             years of full-time work experience
wks             weeks worked
occ             occupation; occ==1 if in a blue-collar occupation
ind             industry; ind==1 if working in a manufacturing industry
south           residence; south==1 if in the South area
smsa            smsa==1 if in the Standard metropolitan statistical area
ms              marital status
fem             female or male
union           if wage set be a union contract
ed              years of education
blk             black
lwage           log wage
id              individual identifier
t               time of survey
tdum1-tdum7		time dummy variables
exp				the squared term of experience

*/

/************************** 1. Pooled OLS model **************************/
global xvar union ed exp exp2 fem ms blk wks occ ind south smsa

* Pooled OLS estimator
	* Use both the between and within variation to estimate the parameters
reg lwage $xvar


/************************** 2. Fixed effect model **************************/
/*** set up the panel data structure in STATA ***/
xtset id t

/****** Fixed effects or within estimator ******/
* Uses the within variation (across time)
* Uses the individual-specific deviations of variables from their time-averaged values
* Note that individual specific effect cancels out
xtreg lwage $xvar, fe

* alternatively
egen avg_lwage = mean(lwage), by(id)
egen avg_union = mean(union), by(id)
egen avg_ed = mean(ed), by(id)
egen avg_exp = mean(exp), by(id)
egen avg_exp2 = mean(exp2), by(id)
egen avg_ms = mean(ms), by(id)
egen avg_wks = mean(wks), by(id)
egen avg_occ= mean(occ), by(id)
egen avg_ind= mean(ind), by(id)
egen avg_south= mean(south), by(id)
egen avg_smsa= mean(smsa), by(id)

gen de_lwage=lwage-avg_lwage
gen de_union=union-avg_union
gen de_ed=ed-avg_ed
gen de_exp=exp-avg_exp
gen de_exp2=exp2-avg_exp2
gen de_ms=ms-avg_ms
gen de_wks=wks-avg_wks
gen de_occ=occ-avg_occ
gen de_ind=ind-avg_ind
gen de_south=south-avg_south
gen de_smsa=smsa-avg_smsa

reg de_lwage de_union de_exp de_exp2 de_ms de_wks de_occ de_ind de_south de_smsa

* recover fixed effects after xtreg, fe
predict alphafehat, u


/****** dummy variable regression ******/
* generate dummy variables for each individual
qui tabulate id, generate(pid)

set matsize 800
reg lwage $xvar pid1-pid595

* alternatively
reg lwage $xvar i.id

* we can suppress the fixed effects by areg
areg lwage $xvar, absorb(id)


/****** first difference model ******/
* coefficients are the same when there are only 2 periods
reg D.(lwage $xvar) if t<=2, noconstant
xtreg lwage $xvar if t<=2, fe

* they are different when t>2, both are unbiased
reg D.(lwage $xvar), noconstant
xtreg lwage $xvar, fe



/************************************************************************/
* Stata Tutorial - Difference-in-Difference

* Load data
use "E:\Stata Tutorial\hospital.dta", clear

drop if r_uncompensated_cost<=0
drop if r_uncompensated_cost>=99

/****** Graphical analysis ******/ 
collapse (mean) uncompensated_cost, by(treat year)

twoway (connected uncompensated_cost year if treat==1, lpattern(solid)) ///
        (connected uncompensated_cost year if treat==0, lpattern(dash)), ///
		xlabel(2011(1)2015) xline(2013.5) legend(order(1 "Expansion states" 2 "non-Expansion states")) ///
		xtitle("Year") ytitle("Uncompensated Care Cost (2014 dollars in millions)")
		
use "E:\Stata Tutorial\hospital.dta", clear

drop if r_operating_margin<=0
drop if r_operating_margin>=99

* create data for DiD figures
collapse (mean) operating_margin, by(treat year)

twoway (connected operating_margin year if treat==1,lpattern(solid)) ///
        (connected operating_margin year if treat==0,lpattern(dash)), ///
		xlabel(2011(1)2015) xline(2013.5) legend(order(1 "Expansion states" 2 "non-Expansion states")) ///
		xtitle("Year") ytitle("Operating Margin")

		
		
/****** regression analysis ******/ 		
use "E:\Stata Tutorial\hospital.dta", clear
		
gen post=1 if year>=2014
	replace post=0 if year<=2013
	
gen int_treat_post=treat*post

reg uncompensated_cost int_treat_post treat post if r_uncompensated_cost>0 & r_uncompensated_cost<99, cluster(mcare_num)
reg operating_margin int_treat_post treat post if r_operating_margin>0 & r_operating_margin<99, cluster(mcare_num)

