/*********************************************************************************************
Program: T1_ST1_2_4_6_8_10_antico (anticoagulant medications)

Study name: Pancreatic cancer is associated with multiple medication changes prior to clinical diagnosis

Study baseline: 1996 (NHS) and 1998 (HPFS)

Study endpoint: June 2012 (NHS) and Jan 2012 (HPFS)

Prupose: generate tables/figures for risk analyses conducted in the pooled cohorts by anticoagulant medications

************************************************************************************************/
/***********************NHS************************/
libname NHS '.';
data NHS; 
   set NHS.nhsone; 

        /************EXCLUSIONS**************/
        %beginex();
        if i=5 then do;
            %exclude(exrec eq 1);
            %exclude(0 lt dtdxca le irt96); 
            %exclude(0 lt dtdth  lt irt96); 
            %exclude(dtdxca eq 9999);   
            %exclude(mqx eq 1); 
            %exclude(can7696 eq 1);  
            %exclude(coumachngc eq .);                 
            %exclude(id gt 0, nodelete=t);
            %output(); 
        end;

        if i>5 then do; 
            %exclude(irt{i-1} lt dtdxca le irt{i});  
            %exclude(irt{i-1} le dtdth  lt irt{i});
            %exclude(id gt 0, nodelete=t);
            %output();
        end;

    end;
    %endex();

    keep id bdt race &race_ 
    t_start interval
    t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 cutoff
    irt: 
    agemo ageyr agec
    db: dbmonth: type prob supp 
    wtlosspt &wtlosspt505c_
    mvt
    ht76 bmi: wt:
    act: 
    alcocum alc5cum &alc5cum_ 
    pckyr pckgrp &pckgrp_
    dt_pancreas t_pancreas dt_dead dtdth dt_digestive t_digestive dtdxca dtdxca2 dtdx_digestive 
    stage
    antidepi antidep1 antidepchng antidepchngc &antidepchngc_ antidepchngcc &antidepchngcc_
    anyni  anyn1  anynchng anynchngc  &anynchngc_  anynchngcc  &anynchngcc_
    anyi  any1  anychng anychngc  &anychngc_   anychngcc  &anychngcc_ 
    coumai couma1 coumachng coumachngc &coumachngc_  coumachngcc &coumachngcc_
    ohypoi ohypo1 ohypochng ohypochngc &ohypochngc_  ohypochngcc &ohypochngcc_ 
    insuli insul1 insulchng insulchngc &insulchngc_  insulchngcc &insulchngcc_
    insuohchngc  &insuohchngc_ insuohchngcc  &insuohchngcc_
    h2i  h21  h2chng  h2chngc  &h2chngc_  
    ppii ppi1 ppichng ppichngc &ppichngc_ 
    h2ppichngc   &h2ppichngc_  h2ppichngcc   &h2ppichngcc_ 
    comboc &comboc_ combinec &combinec_
    ;
    
run;



data NHS;
    set NHS end=_end_;

    sex=0;
    id=id+10000000;
    irt86=0;              
    t86=0;
    interval=interval+1;
run;


/***********************HPFS************************/
libname HPFS '.';
data HPFS; 
   set HPFS.hpfsone; 

        /************EXCLUSIONS**************/
        %beginex();
        if i=7 then do;
            %exclude(exrec eq 1); 
            %exclude(0 lt dtdxca le irt98);
            %exclude(0 lt dtdth  lt irt98); 
            %exclude(dtdxca eq 9999);
            %exclude(can8698 eq 1);
            %exclude(mqx eq 1);                         
            %exclude(coumachngc eq .); 
            %exclude(id gt 0, nodelete=t);
            %output(); 
        end;

        if i>7 then do; 
            %exclude(irt{i-1} lt dtdxca le irt{i}); 
            %exclude(irt{i-1} le dtdth  lt irt{i});               
            %exclude(id gt 0, nodelete=t);
            %output();
        end;

    end;
%endex();

keep    id dbmy09 race &race_
        t_start interval t86 t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10 cutoff
        irt:
        agemo ageyr agec
        db: dbmonth: type supp
        wtlosspt &wtlosspt505c_
        mvt
        bmi: wt: 
        act:
        pckyr pckgrp &pckgrp_
        alcocum alc5cum &alc5cum_
        dt_pancreas t_pancreas dt_dead dtdth dt_digestive t_digestive dtdxca dtdxca2 dtdx_digestive
        stage
        antidepi antidep1 antidepchng antidepchngc &antidepchngc_ antidepchngcc &antidepchngcc_
        anyni  anyn1  anynchng anynchngc  &anynchngc_  anynchngcc  &anynchngcc_
        anyi  any1  anychng anychngc  &anychngc_   anychngcc  &anychngcc_ 
        coumai couma1 coumachng coumachngc &coumachngc_  coumachngcc &coumachngcc_
        h2i  h21  h2chng  h2chngc  &h2chngc_  
        ppii ppi1 ppichng ppichngc &ppichngc_ 
        h2ppichngc   &h2ppichngc_  h2ppichngcc   &h2ppichngcc_ 

    ;
run;


data HPFS;
    set HPFS end=_end_;
    sex=1;

run;



/****combine the two cohorts***/
data ALL;
set NHS HPFS end=_end_;

run;


data ALL;
  set ALL; 

if race=1           then white=1;          else white=0;
if wtlosspt505c=1   then wtlosspt505c1=1;  else wtlosspt505c1=0;
    
label 

     ageyr = 'Age, years'
     sex='Male, %'
     white ='Caucasians vs not'
     bmicum = 'Body mass index, kg/mBYTE(178)'
     wtlosspt505c='Weight loss'
     pckyr= 'pack-years'
     db='Type 2 diabetes'
     actcum = 'Physical activity, MET-h/week'
     alcocum='Alcohol, drinks/day' 
     mvt='Multivitamin use'
     ;
run;

/**STable 2 anticoagulant medications**/
%table1(data=ALL, exposure=coumai, agegroup=agec,
        varlist=ageyr sex white bmicum wtlosspt505c1 &wtlosspt505c_ pckyr db actcum alcocum mvt,
        cat=sex white wtlosspt505c1 &wtlosspt505c_ db mvt,
        noadj=ageyr, landscape=F, 
        fn=@bmi Body mass index was calculated as weight in kilograms divided by the square of height in meters.
        @act Hours of metabolic equivalent tasks.,
        file=ALL_coumai.table1, uselbl=F,dec=1);

run;


/**STable 1 summary of study populations by anticoagulant medications**/

/**NHS person years**/
%pre_pm (
    data=NHS, 
    out=pmNHS, 
    case=dt_pancreas,
    var=coumachngc coumachngcc,
    timevar=interval, 
    irt=irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10, 
    cutoff=cutoff, 
    dtdx=dtdxca, 
    dtdth=dtdth);

%pm (data=pmNHS, 
     case=dt_pancreas, 
     exposure=coumachngc coumachngcc,
     ref=1 1);

run;


/**HPFS person years**/
%pre_pm (
    data=HPFS, 
    out=pmHPFS, 
    timevar=interval, 
    irt=irt98 irt00 irt02 irt04 irt06 irt08 irt10, 
    cutoff=cutoff, 
    dtdx=dtdxca, 
    dtdth=dtdth, 
    case=dt_pancreas,
    var=coumachngc coumachngcc);

%pm (data=pmHPFS, 
     case=dt_pancreas, 
     exposure=coumachngc coumachngcc,
     ref=1 1);

run;

/**Pooled person years**/
data pmALL;
set pmNHS(in=n) pmHPFS(in=h) end=_end_;

if n then coh=1;
if h then coh=2;


%pm(data=pmALL, case=dt_pancreas, exposure=coumachngc coumachngcc, ref=1 1); 

run;


/**Table 1 & STable 4_6_8_10 anticoagulant medications**/
%mphreg9(
         data     =NHS,
         event    =dt_pancreas,
         id       =id,
         qret     =irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdxca,
         timevar  =t96 t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval,
         labels   =T,
        outdat    =allpacNHS,
        model1    =&coumachngc_ ,
        model2    =&coumachngcc_ ,
        model3    =&coumachngc_                race  bmicum  actcum pckyr alcocum mvt db  couma1,
        model4    =&coumachngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*couma1*/,
        model5    =&coumachngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db couma1,
        model6    =&coumachngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db /*couma1*/
);
run;




%mphreg9(
         data     =HPFS,
         event    =dt_pancreas,
         id       =id,
         qret     =irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdxca,
         timevar  =t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval,
         labels   =T,
        outdat    =allpacHPFS,
        model1    =&coumachngc_ ,
        model2    =&coumachngcc_ ,
        model3    =&coumachngc_                race  bmicum  actcum pckyr alcocum mvt db  couma1,
        model4    =&coumachngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*couma1*/,
        model5    =&coumachngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  couma1,
        model6    =&coumachngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*couma1*/ 
 );

run;



%mphreg9(
         data     =ALL,
         event    =dt_pancreas,
         id       =id,
         qret     =irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdxca,
         timevar  =t96 t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval sex,
         labels   =T,
        outdat    =allpacALL,
        model1    =&coumachngc_ ,
        model2    =&coumachngcc_ ,
        model3    =&coumachngc_                race  bmicum  actcum pckyr alcocum mvt db  couma1,
        model4    =&coumachngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*couma1*/,
        model5    =&coumachngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  couma1,
        model6    =&coumachngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*couma1*/
 );
run;

