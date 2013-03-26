
drop table if exists madlibtestdata.evaluation_en_train; 

create table madlibtestdata.evaluation_en_train (
    eval_src            text,   -- 'R'
    dataset             text,   -- Name of data set
    grouping_cols       text,   -- String of grouping columns delimited by comma
    grouping_vals       text,   -- Values converted into a string
    coef                double precision[],
    intercept           double precision,
    log_likelihood      double precision,
    standardize			boolean,
    y_mean              double precision,
    y_sd                double precision
);

alter table madlibtestdata.evaluation_en_train owner to madlibtester;

----------------------------------------------------------------------------


