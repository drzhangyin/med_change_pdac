/*********************************************************************************************
Program: F3_ST13_antihp (antihypertensive medications)

Study name: Pancreatic cancer is associated with multiple medication changes prior to clinical diagnosis

Study baseline: 1990 (NHS) and 1988 (HPFS)

Study endpoint: June 2012 (NHS) and Jan 2012 (HPFS)

Prupose: generate tables/figures for GI cancer risk analyses conducted in the pooled cohorts by antihypertensive medication to assess specificity

************************************************************************************************/
/***********************NHS************************/
libname NHS '.';
data NHS; 
   set NHS.nhsone; 

        /************EXCLUSIONS**************/
        %beginex();
        if i=2 then do;
            %exclude(exrec eq 1);
            %exclude(0 lt dtdx_digestive le irt90); 
            %exclude(0 lt dtdth  lt irt90); 
            %exclude(dtdx_digestive eq 9999);   
            %exclude(mqx eq 1); 
            %exclude(can7690 eq 1);  
            %exclude(anychngc eq .);                 
            %exclude(id gt 0, nodelete=t);
            %output(); 
        end;

        if i>2 then do; 
            %exclude(irt{i-1} lt dtdx_digestive le irt{i});  
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
        if i=2 then do;
            %exclude(exrec eq 1); 
            %exclude(0 lt dtdx_digestive le irt88);
            %exclude(0 lt dtdth  lt irt88); 
            %exclude(dtdx_digestive eq 9999);
            %exclude(can8688 eq 1);
            %exclude(mqx eq 1);                         
            %exclude(anychngc eq .); 
            %exclude(id gt 0, nodelete=t);
            %output(); 
        end;

        if i>2 then do; 
            %exclude(irt{i-1} lt dtdx_digestive le irt{i}); 
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


/**NHS person years**/
%pre_pm (
    data=NHS, 
    out=pmNHS, 
    case=dt_digestive,
    var=anychngc anychngcc,
    timevar=interval, 
    irt=irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10, 
    cutoff=cutoff, 
    dtdx=dtdx_digestive, 
    dtdth=dtdth);

%pm (data=pmNHS, 
     case=dt_digestive, 
     exposure=anychngc anychngcc,
     ref=1 1);

run;


/**HPFS person years**/
%pre_pm (
    data=HPFS, 
    out=pmHPFS, 
    timevar=interval, 
    irt=irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10, 
    cutoff=cutoff, 
    dtdx=dtdx_digestive, 
    dtdth=dtdth, 
    case=dt_digestive,
    var=anychngc anychngcc);

%pm (data=pmHPFS, 
     case=dt_digestive, 
     exposure=anychngc anychngcc,
     ref=1 1);

run;

/**Pooled person years**/
data pmALL;
set pmNHS(in=n) pmHPFS(in=h) end=_end_;

if n then coh=1;
if h then coh=2;


%pm(data=pmALL, case=dt_digestive, exposure=anychngc anychngcc, ref=1 1); 

run;


/**Figure 3 & STable 13 antihypertensive medication**/
%mphreg9(
         data     =NHS,
         event    =dt_digestive,
         id       =id,
         qret     =irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdx_digestive,
         timevar  =t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval,
         labels   =T,
        outdat    =allGINHS,
        model1    =&anychngc_ ,
        model2    =&anychngcc_ ,
        model3    =&anychngc_                race  bmicum  actcum pckyr alcocum mvt db  any1,
        model4    =&anychngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*any1*/,
        model5    =&anychngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  any1,
        model6    =&anychngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*any1*/
);
run;




%mphreg9(
         data     =HPFS,
         event    =dt_digestive,
         id       =id,
         qret     =irt88 irt90
                   irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdx_digestive,
         timevar  =t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval,
         labels   =T,
        outdat    =allGIHPFS,
        model1    =&anychngc_ ,
        model2    =&anychngcc_ ,
        model3    =&anychngc_                race  bmicum  actcum pckyr alcocum mvt db  any1,
        model4    =&anychngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*any1*/,
        model5    =&anychngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  any1,
        model6    =&anychngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*any1*/  
 );

run;



%mphreg9(
         data     =ALL,
         event    =dt_digestive,
         id       =id,
         qret     =irt88 irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10,
         cutoff   =cutoff,
         dtdth    =dtdth,
         dtdx     =dtdx_digestive,
         timevar  =t88 t90 t92 t94 t96 t98 t00 t02 t04 t06 t08 t10,
         tvar     =interval,
         agevar   =agemo,
         strata   =agemo interval sex,
         labels   =T,
        outdat    =allGIALL,
        model1    =&anychngc_ ,
        model2    =&anychngcc_ ,
        model3    =&anychngc_                race  bmicum  actcum pckyr alcocum mvt db  any1,
        model4    =&anychngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*any1*/,
        model5    =&anychngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  any1,
        model6    =&anychngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*any1*/ 
 );
run;

