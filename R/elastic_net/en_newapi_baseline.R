source("../utils/utils.r")
library(glmnet)
# -----------------------------------------------------------------------
# Function to combine each string in multiple vectors to produce a single
# concatenated string with double quotes escaped appropriately
# @param cats A list where each item is a vector of strings
str.combine <- function (cats)
{
    rst <- character(0)
    n <- length(cats)
    if (n > 1) {
        for (i in seq(length(cats[1][[1]]))) {
            pre <- str.combine(cats[2:n])
            rst <- c(rst, paste("\"", cats[1][[1]][i], "\", ", pre, sep = ""))
        }
    } else {
        for (i in seq(length(cats[1][[1]]))) {
            rst <- c(rst, paste("\"", cats[1][[1]][i], "\"", sep = ""))
        }
    }
    return (rst)
}

## ------------------------------------------------------------------------

## append R calculation result into the SQL table file
eval.en.append.results <- function (
                data.set, # data set name
                output_filename,
                target = "y", # fitting target column
                predictors = "~ . - 1", # fitting formula
                grouping.cols = character(0), # a vector of strings
                not.xcols = grouping.cols,
                    # x colums that are not predictors also a vector of strings
                    # not.xcols might not be the same as grouping.cols
                sql.path = "../../dataset/sql/",
                    # where the original .gz data files are located
                data.path = "../data/",
                    # where to unpack .gz file and store the temporary SQL
                    #  data file. It is also the folder that the text data
                    # file generated from these SQL data file will be stored
                py.path = "../utils/"
                    # location of the Python script that extracts data
                    # from SQL data file and converts into text file that
                    # R can read without error
                )
{
    ## copy the original .gz dataset, extract it, convert it into R compatible
    ## format, and then read in
    dat <- prepare.dataset(data.set, sql.path = sql.path,
                            data.path = data.path,
                            py.path = py.path)
    ##
    if (! is.null(dat))
    {
        ## The independent variable columns
        xcols <- setdiff(names(dat), c(target, not.xcols))
        n <- length(xcols)
        conn <- file(output_filename, "a")
        ##
        if (length(grouping.cols) != 0) {
            ## grouping the original data
            grps <- by(dat, dat[grouping.cols], rbind)
            ## extract grouping column values
            cats <- attr(grps, "dimnames")
            ## for each combination of grouping column values, form a string
            grouping.vals <- str.combine(cats)
        } else {
            grps <- list(dat = dat)
            grouping.vals <- ""
        }

        ##
        for (gval in grouping.vals)
        {
            ## extract the data for a specific combination of grouping column values
            dat.use <- eval(parse(text=paste("grps[", gval, "][[1]]",
                                  sep="")))
            ##  All the previous parts should be refactored out later, and can
            ##  be utilized in other modules that support grouping  The
            ##  following computation & output parts are just module-specific
            # -----------------------------------------------------------
            ##  Actual computation part
            X <- as.matrix(dat.use[xcols])
            Y <- dat.use[target][[1]]
			Y1 <- scale(Y)
            fit <- glmnet(X, Y1, family="gaussian",
                alpha=0.5, lambda=0.5,
                standardize=TRUE,
                thresh = 1e-8, maxit = 10000)
            # sapply(fit, print)
            log_likelihood <- log.likelihood(X, Y1, fit$beta, fit$a0, 
                                                0.5, 0.5, TRUE)
			Ymean <- mean(Y)
			Ysd <- sd(Y)
            # --------------------------------------------------------
            ## Output the result to SQL table
            output.head("madlibtestdata.evaluation_en_train", conn)
            output.one("R", "text", ",\n", conn)
            output.one(data.set, "text", ",\n", conn)
            if (gval == "") {
                output.one(NULL, "text", ",\n", conn)
                output.one(NULL, "text", ",\n", conn)
            } else {
                output.one(grouping.str, "text", ",\n", conn)
                output.one(gval, "text", ",\n", conn)
            }
            output.vec(fit$beta, "double precision[]", ",\n", conn)
            output.one(fit$a0, "double precision", ",\n", conn)
            output.one(log_likelihood, "double precision", ",\n",
                                conn)
			output.one('True', "boolean", ",\n", conn)
			output.one(Ymean, "double precision", ",\n", conn)
			output.one(Ysd, "double precision", ");\n\n", conn)
            # --------------------------------------------------------
        }
        ##
        close(conn)
    }
}

## ------------------------------------------------------------------------

## append R calculation result into the SQL table file
eval.en.binomial.append.results <- function (
                data.set, # data set name
                output_filename,
                target = "y", # fitting target column
                predictors = "~ . - 1", # fitting formula
                grouping.cols = character(0), # a vector of strings
                not.xcols = grouping.cols,
                    # x colums that are not predictors also a vector of strings
                    # not.xcols might not be the same as grouping.cols
                sql.path = "../../dataset/sql/",
                    # where the original .gz data files are located
                data.path = "../data/",
                    # where to unpack .gz file and store the temporary SQL
                    #  data file. It is also the folder that the text data
                    # file generated from these SQL data file will be stored
                py.path = "../utils/"
                    # location of the Python script that extracts data
                    # from SQL data file and converts into text file that
                    # R can read without error
                )
{
    ## copy the original .gz dataset, extract it, convert it into R compatible
    ## format, and then read in
    dat <- prepare.dataset(data.set, sql.path = sql.path,
                            data.path = data.path,
                            py.path = py.path)
    ##
    if (! is.null(dat))
    {
        ## The independent variable columns
        xcols <- setdiff(names(dat), c(target, not.xcols))
        n <- length(xcols)
        conn <- file(output_filename, "a")
        ##
        if (length(grouping.cols) != 0) {
            ## grouping the original data
            grps <- by(dat, dat[grouping.cols], rbind)
            ## extract grouping column values
            cats <- attr(grps, "dimnames")
            ## for each combination of grouping column values, form a string
            grouping.vals <- str.combine(cats)
        } else {
            grps <- list(dat = dat)
            grouping.vals <- ""
        }

        ##
        for (gval in grouping.vals)
        {
            ## extract the data for a specific combination of grouping column values
            dat.use <- eval(parse(text=paste("grps[", gval, "][[1]]",
                                  sep="")))
            ##  All the previous parts should be refactored out later, and can
            ##  be utilized in other modules that support grouping  The
            ##  following computation & output parts are just module-specific
            # -----------------------------------------------------------
            ##  Actual computation part
            X <- as.matrix(dat.use[xcols])
            Y <- dat.use[target][[1]]
            fit <- glmnet(X, Y, family="binomial",
                alpha=0.5, lambda=0.5,
                standardize=TRUE,
                thresh = 1e-8, maxit = 10000)
            # sapply(fit, print)
            log_likelihood <- log.likelihood2(X, Y, fit$beta, fit$a0, 
                                                0.5, 0.5, TRUE)
            # --------------------------------------------------------
            ## Output the result to SQL table
            output.head("madlibtestdata.evaluation_en_binomial_train", conn)
            output.one("R", "text", ",\n", conn)
            output.one(data.set, "text", ",\n", conn)
            if (gval == "") {
                output.one(NULL, "text", ",\n", conn)
                output.one(NULL, "text", ",\n", conn)
            } else {
                output.one(grouping.str, "text", ",\n", conn)
                output.one(gval, "text", ",\n", conn)
            }
            output.vec(fit$beta, "double precision[]", ",\n", conn)
            output.one(fit$a0, "double precision", ",\n", conn)
            output.one(log_likelihood, "double precision", ",\n",
                                conn)
			output.one('True', "boolean", ");\n\n", conn)
            # --------------------------------------------------------
        }
        ##
        close(conn)
    }
}
