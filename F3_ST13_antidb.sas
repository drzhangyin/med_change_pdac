/*********************************************************************************************
Program: F3_ST13_antidb (antidiabetic medications)

Study name: Pancreatic cancer is associated with multiple medication changes prior to clinical diagnosis

Study baseline: 1990 (NHS)

Study endpoint: June 2012 (NHS)

Prupose: generate tables/figures for GI cancer risk analyses conducted in the NHS by antidiabetic medication to assess specificity

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
            %exclude(insuohchngc eq .);                 
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
run;


/**NHS person years**/
%pre_pm (
    data=NHS, 
    out=pmNHS, 
    case=dt_digestive,
    var=ohypochngc ohypochngcc insulchngc insulchngcc insuohchngc insuohchngcc,
    timevar=interval, 
    irt=irt90 irt92 irt94 irt96 irt98 irt00 irt02 irt04 irt06 irt08 irt10, 
    cutoff=cutoff, 
    dtdx=dtdx_digestive, 
    dtdth=dtdth);

%pm (data=pmNHS, 
     case=dt_digestive, 
     exposure=ohypochngc ohypochngcc insulchngc insulchngcc insuohchngc insuohchngcc,
     ref=1 1 1 1 1 1);

run;



/**Figure 3 & STable 13 antidiabetic medication**/
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
        outdat    =allGINHSI,
        model1    =&ohypochngc_ ,
        model2    =&ohypochngcc_ ,
        model3    =&ohypochngc_                race  bmicum  actcum pckyr alcocum mvt db  ohypo1,
        model4    =&ohypochngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*ohypo1*/,
        model5    =&ohypochngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  ohypo1,
        model6    =&ohypochngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*ohypo1*/,
        model7    =&ohypochngc_                bmicum db,
        model8    =&ohypochngcc_               bmicum db,
        model9    =&ohypochngc_                &wtlosspt505c_ db,
        model10   =&ohypochngcc_               &wtlosspt505c_ db
);
run;


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
        outdat    =allGINHSII,
        model1    =&insulchngc_ ,
        model2    =&insulchngcc_ ,
        model3    =&insulchngc_                race  bmicum  actcum pckyr alcocum mvt db  insul1,
        model4    =&insulchngcc_               race  bmicum  actcum pckyr alcocum mvt db  /*insul1*/,
        model5    =&insulchngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  insul1,
        model6    =&insulchngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  /*insul1*/,
        model7    =&insulchngc_                bmicum db,
        model8    =&insulchngcc_               bmicum db,
        model9    =&insulchngc_                &wtlosspt505c_ db,
        model10   =&insulchngcc_               &wtlosspt505c_ db
);
run;



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
        outdat    =allGINHSIII,
        model1    =&insuohchngc_ ,
        model2    =&insuohchngcc_ ,
        model3    =&insuohchngc_                race  bmicum  actcum pckyr alcocum mvt db  insul1 ohypo1,
        model4    =&insuohchngcc_               race  bmicum  actcum pckyr alcocum mvt db  insul1 ohypo1,
        model5    =&insuohchngc_                race  &wtlosspt505c_  actcum pckyr alcocum mvt db  insul1 ohypo1,
        model6    =&insuohchngcc_               race  &wtlosspt505c_  actcum pckyr alcocum mvt db  insul1 ohypo1,
        model7    =&insuohchngc_                bmicum db,
        model8    =&insuohchngcc_               bmicum db,
        model9    =&insuohchngc_                &wtlosspt505c_ db,
        model10   =&insuohchngcc_               &wtlosspt505c_ db
);
run;

