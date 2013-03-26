
source("en_newapi_baseline.R")

## ------------------------------------------------------------------------

# datasets <- c("lin_auto_mpg_wi")
datasets <- c(  "lin_auto_mpg_wi",
                "lin_auto_mpg_wi",
                "lin_forestfires_wi",
                "lin_housing_wi",
                "lin_imports_85_wi",
                "lin_machine_wi",
                "lin_parkinsons_updrs_wi",
                "lin_servo_wi",
                "lin_slump_wi",
                "lin_winequality_red_wi",
                "lin_winequality_white_wi",
                "lin_ornstein_wi",
                "lin_auto_mpg_oi",
                "lin_auto_mpg_oi",
                "lin_forestfires_oi",
                "lin_housing_oi",
                "lin_imports_85_oi",
                "lin_machine_oi",
                "lin_parkinsons_updrs_oi",
                "lin_servo_oi",
                "lin_slump_oi",
                "lin_winequality_red_oi",
                "lin_winequality_white_oi",
                "lin_ornstein_oi")

out_file = "evaluation_elastic_net_train.sql"
system(paste("rm -rf ", out_file, "; cp template.sql ", 
                    out_file, sep=""))

for (data.set in datasets) 
    eval.en.append.results( data.set = data.set, 
                            output_filename="evaluation_elastic_net_train.sql")

## ------------------------------------------------------------------------

## create R table for binomial case
datasets <- c("log_breast_cancer_wisconsin",
              "log_ticdata2000",
              "log_wpbc",
              "log_wdbc")

out.file <- "evaluation_elastic_net_binomial_train.sql"
system(paste("rm -f ", out.file, "; cp template_binomial.sql ", out.file, sep = ""))

for (data.set in datasets) {
    eval.en.binomial.append.results(data.set = data.set,
                                    output_filename = out.file)
}
