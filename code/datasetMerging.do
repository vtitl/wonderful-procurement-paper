import delimited "$WONDERFUL_DROPBOX_PATH/raw/super_tender_analytics_criteria_202602121648.csv", varnames(1) clear bindquote(strict) maxquotedrows(unlimited)

/* SOME CLEANING AND PROCESSING HAPPENS HERE */


save "$WONDERFUL_PROJECT_PATH/data/processed/main.dta", replace
