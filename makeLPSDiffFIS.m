function fis = makeLPSDiffFIS(setting)
% Makes a Matlab Fuzzy Inference System (FIS) structure based on the input
% setting, which dictates the width/narrowness/shape of the anteceded membership
% functions (inc, dec and sim). I use the setting = 3 mostly. 
% This FIS assumes that we have 5 semantically ordered quantifiers 
% (Jain&Keller, 2015, FUZZIEEE): Almost none, Few, Some, Many, Almost all.
% The fuzzy rules need to be different for different set of quantifiers 
% Look at paper Jain et al., FUZZ-IEEE, 2019 for details of various parameters 
% and FIS construction

    fis = newfis('LPSDiffFIS');

    if(setting == 1)
        dec = [-1.0,-1.0,-0.5,-0.0];
        sim = [-0.5,-0.0,0.0,0.5];
        inc = [0.0,0.5,1.0,1.0];
    elseif(setting == 2)    
        dec = [-1.0,-1.0,-0.6,-0.1];
        sim = [-0.6,-0.1,0.1,0.6];
        inc = [0.1,0.6,1.0,1.0];
    elseif(setting == 3)
        dec = [-1.0,-1.0,-0.6,-0.0];
        sim = [-0.6,0.0,0.0,0.6];
        inc = [0.0,0.6,1.0,1.0];
    end
    % Add antecedent membership funcitons for each quantifier. The memberhsip 
    % of change in truth value of each quantifier is defined over increase, 
    % decrease and similar
    fis = addvar(fis,'input','almostNone',[-1 1]);
    fis = addmf(fis,'input',1,'dec','trapmf',dec);
    fis = addmf(fis,'input',1,'sim','trapmf',sim);
    fis = addmf(fis,'input',1,'inc','trapmf',inc);

    fis = addvar(fis,'input','few',[-1 1]);
    fis = addmf(fis,'input',2,'dec','trapmf',dec);
    fis = addmf(fis,'input',2,'sim','trapmf',sim);
    fis = addmf(fis,'input',2,'inc','trapmf',inc);

    fis = addvar(fis,'input','some',[-1 1]);
    fis = addmf(fis,'input',3,'dec','trapmf',dec);
    fis = addmf(fis,'input',3,'sim','trapmf',sim);
    fis = addmf(fis,'input',3,'inc','trapmf',inc);

    fis = addvar(fis,'input','many',[-1 1]);
    fis = addmf(fis,'input',4,'dec','trapmf',dec);
    fis = addmf(fis,'input',4,'sim','trapmf',sim);
    fis = addmf(fis,'input',4,'inc','trapmf',inc);

    fis = addvar(fis,'input','almostAll',[-1 1]);
    fis = addmf(fis,'input',5,'dec','trapmf',dec);
    fis = addmf(fis,'input',5,'sim','trapmf',sim);
    fis = addmf(fis,'input',5,'inc','trapmf',inc);
    
    % Add consequent membership function
    fis = addvar(fis,'output','change',[0 1]);

    fis = addmf(fis,'output',1,'dec','trapmf',[0 0 0.1 0.3]);
    fis = addmf(fis,'output',1,'small dec','trapmf',[0.1 0.3 0.3 0.5]);
    fis = addmf(fis,'output',1,'sim','trapmf',[0.3 0.5 0.5 0.7]);
    fis = addmf(fis,'output',1,'small inc','trapmf',[0.5 0.7 0.7 0.9]);
    fis = addmf(fis,'output',1,'inc','trapmf',[0.7 0.9 1 1]);
    fis.output.domain = 0:0.005:1;

    % Declare the rules for the FIS. The first 5 columns are for the 5
    % antecedents, 6th column is for the consequent, the 7th column is 
    % for the conjuction operator (1 = and in all rules here) and weights
    % Details of rules in the paper
    ruleList = [ 
     1     3     0     0     0     4     1     1
     1     0     3     0     0     5     1     1
     1     0     0     3     0     5     1     1
     1     0     0     0     3     5     1     1
     3     1     0     0     0     2     1     1
     3     0     1     0     0     1     1     1
     3     0     0     1     0     1     1     1
     3     0     0     0     1     1     1     1
     0     1     3     0     0     4     1     1
     0     1     0     3     0     5     1     1
     0     1     0     0     3     5     1     1
     0     3     1     0     0     2     1     1
     0     3     0     1     0     1     1     1
     0     3     0     0     1     1     1     1
     0     0     1     3     0     4     1     1
     0     0     1     0     3     5     1     1
     0     0     3     1     0     2     1     1
     0     0     3     0     1     1     1     1
     0     0     0     1     3     4     1     1
     0     0     0     3     1     2     1     1
     2     2     2     2     2     3     1     1];
                
    fis = addrule(fis,ruleList);
    % the minimum, middle, and maximum defuzzified values that the
    % consequent will produce with defuzzification (default centroid). This is later
    % used to scale the defuzzified output to dissimilarity (between 0 and 1)
    % Tested in MATLAB 2017a. In 2019b version, matlab doesn't let you
    % add definations to its own classes. 
    fis.minDefuz = defuzz(fis.output.domain,feval(fis.output.mf(1).type,fis.output.domain,fis.output.mf(1).params),fis.defuzzMethod);
    fis.midDefuz = defuzz(fis.output.domain,feval(fis.output.mf(3).type,fis.output.domain,fis.output.mf(3).params),fis.defuzzMethod);
    fis.maxDefuz = defuzz(fis.output.domain,feval(fis.output.mf(5).type,fis.output.domain,fis.output.mf(5).params),fis.defuzzMethod);
end
