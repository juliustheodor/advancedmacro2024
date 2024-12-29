************************************************************
* Advanced Macroeconomics, Problem Set 7, Exercise 2.3 and 2.4 
* Julius Schoelkopf, M.Sc. (November 2024) 
************************************************************

************************************************************
* Clear environment and set up
************************************************************
clear all
set more off

************************************************************
* Set number of periods
************************************************************
local t = 10
set obs `t'

************************************************************
* Define the shock vector epsilon: a one-time unity 
* shock hits the economy in period 1
************************************************************
generate epsilon = 0
replace epsilon = 1 in 1

************************************************************
* Define rho (persistence of AR(1))
************************************************************
local rho = 0.5

* Create the A_tilde variable and initialize
generate A_tilde = .
replace A_tilde = 0 in 1

* Declare time series 
gen t =_n 
tsset t 

* A_tilde(i+1) = rho * A_tilde(i) + epsilon(i)
replace A_tilde = `rho' * L.A_tilde + L.epsilon if t > 1
generate ln_A = F.A_tilde

************************************************************
* Plot the process ln_A
************************************************************
twoway (line ln_A t, lcolor(red) lwidth(thick)) ///
    , title("\ln A_t", size(medium)) ///
    legend(order(1 "ρ_A = 0.5"))  ylabel(, nogrid) name(lnA, replace)

************************************************************
* Plot the shock sequence epsilon
************************************************************
twoway (line epsilon t, lpattern(dash) lcolor(blue) lwidth(thick)) ///
    , title("Sequence of Shocks", size(medium))  ylabel(, nogrid) name(epsilons, replace)


graph combine lnA epsilons, col(1)
	
************************************************************
* Now compare with rho = 0, 1, 1.5
************************************************************
clear
local t = 11
set obs `t'
generate epsilon = 0
replace epsilon = 1 in 1

* Declare time series 
gen t =_n 
tsset t 

* Rho values
local rho_values = "0 0.5 1 1.5"

foreach r of local rho_values {
	local rho_f = 10*`r'
    generate A_tilde_`rho_f' = .
    replace A_tilde_`rho_f' = 0 in 1
	replace A_tilde_`rho_f' = `r' * L.A_tilde_`rho_f' + L.epsilon if t > 1
	generate ln_A_`rho_f' = F.A_tilde_`rho_f'
}

* Create individual graphs for each rho
twoway (line ln_A_0 t, lcolor(red) lwidth(thick)) ///
    , title("ln A_t, ρ_A=0") ///
    name(g0, replace)

twoway (line ln_A_5 t, lcolor(red) lwidth(thick)) ///
    , title("ln A_t, ρ_A=0.5") ///
    name(g05, replace)

twoway (line ln_A_10 t, lcolor(red) lwidth(thick)) ///
    , title("ln A_t, ρ_A=1") ///
    name(g1, replace)

twoway (line ln_A_15 t, lcolor(red) lwidth(thick)) ///
    , title("ln A_t, ρ_A=1.5") ///
    name(g15, replace)

* Combine all four graphs into a 2x2 grid
graph combine g0 g05 g1 g15, col(2) row(2)
