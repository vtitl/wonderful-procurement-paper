use "$WONDERFUL_PROJECT_PATH/data/processed/main.dta", clear


do "$WONDERFUL_PROJECT_PATH/code/scalars/scalar_utils.do"


sum price_weight

local wonderfulConstant = r(mean)

save_scalar "wonderfulConstant" ///
    "`wonderfulConstant'"                      ///
    "$WONDERFUL_PROJECT_PATH/output/scalars.tex"

estpost tabstat tender_estimated_price, stat(n mean sd min max) col(stat)
esttab using "$WONDERFUL_PROJECT_PATH/output/summaryTable.tex", replace ///
    cells("count mean sd min max") ///
    label nonumber noobs
