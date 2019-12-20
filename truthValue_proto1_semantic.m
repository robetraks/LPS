function tv = truthValue_proto1_semantic(u,mf,domain,varargin)
% Computes truth value using Semantic method (of Jain et. al 2015), for the supplied data,
% membership function and its discrete domain. Calls the sugeno integral
% according to the type of membership function of the quantifier and
% returns the truth value.
% u: Memberships of original data in the Summarizer memebrship function
% mf: Membership funciton of the Quantifier with which the truth-value is
%     to be computed
% domain: the discrete domain over which mf is defined
% varagin: if the quantifiers are absolute, then do not compute the
% proportion of objects in the Sugeno integral

    if(nargin==4)
        QuantifierType = varargin{1};
    else
        QuantifierType = 'relative';
    end

    if ((mf(1) == 0) && (mf(end) == 0))
        mfType = 1; %Non Monotonic 
    elseif ((mf(1) == 0) && (mf(end) == 1))
        mfType = 2; % Monotonic Non decreasing
    elseif ((mf(1) == 1) && (mf(end) == 0))
        mfType = 3; %Monotonic Non increasing
    else
        error('Non recognizable membership function');
    end
    
    if (mfType == 2)
       tv = sugenoIntegralForLPS(u,mf,domain,QuantifierType);
    elseif(mfType == 1)
        onesInMF = find(mf==1);
        mf1 = ones(1,length(mf));
        mf1(1:onesInMF(1)-1) = mf(1:onesInMF(1)-1);
        mf2 = mf;
        mf2(1:onesInMF(1)-1) = ones(1,onesInMF(1)-1);
        tv = min(sugenoIntegralForLPS(u,mf1,domain,QuantifierType),1-sugenoIntegralForLPS(u,1-mf2,domain,QuantifierType));
    elseif(mfType == 3)
        tv = 1- sugenoIntegralForLPS(u,1-mf,domain,QuantifierType);
    end
end

function tv = sugenoIntegralForLPS(u,mf,domain,varargin)
% Computes truth value using discreete form of sugeno integral for the
% supplied data, membership function and its domain.
% data = each row represnts one object series (bag of balls)
% for realtive Quantifiers (domain = [0 1])
% u: Memberships of original data in the Summarizer memebrship function
% mf: Membership funciton of the Quantifier with which the truth-value is
%     to be computed
% domain: the discrete domain over which mf is defined
% varagin: if the quantifiers are absolute, then do not compute the
% proportion of objects in the Sugeno integral
    if(isempty(varargin))
        N = 1;
    elseif(strcmp(varargin{1},'relative'))
        N = size(u,2);
    elseif(strcmp(varargin{1},'absolute'))
        N=1;
    end
    a = 0.0:0.01:1;
    % T_sugeno = max(min(alpha,uq(|P_alpha|/|N|)))
    for i = 1:length(a)
        if(isvector(u)), Aa = sum(u >= a(i));   
        else, Aa = sum(all(u >= a(i)));
        end
        q = Aa/N;
        [~, idx] = min(abs(repmat(q,1,size(domain,2))-domain),[],2);
        q1 = mf(idx);
        s1(i) = min(a(i),q1);
    end
    tv = max(s1);
end
