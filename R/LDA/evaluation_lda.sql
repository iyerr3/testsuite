drop table if exists madlibtestdata.evaluation_lda;

create table madlibtestdata.evaluation_lda (
    eval_src            text,   -- 'R'
    dataset             text,   -- Name of data set
    topic_no            integer,-- Number of topics
    perplexity          double precision
);

alter table madlibtestdata.evaluation_lda owner to madlibtester;

----------------------------------------------------------------------------

insert into madlibtestdata.evaluation_lda values
    ('R', 'AssociatedPress', 10, 2356.61687563252),
    ('R', 'AssociatedPress', 20, 1987.22860262696),
    ('R', 'AssociatedPress', 30, 1792.40716887695),
    ('R', 'AssociatedPress', 40, 1680.8284780254),
    ('R', 'AssociatedPress', 50, 1597.29612635741),
    ('R', 'AssociatedPress', 60, 1544.01058613653),
    ('R', 'AssociatedPress', 70, 1503.20411970059),
    ('R', 'AssociatedPress', 80, 1468.83501487259),
    ('R', 'AssociatedPress', 90, 1446.54200105897),
    ('R', 'AssociatedPress', 100, 1429.71636336914);
