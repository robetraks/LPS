function [dissim,change,deFuzzOut,rulesFired] = lpsFuzzyRuleDissim(LPSSet1,LPSSet2,fis,options)
% Computes dissimilarity between two LPS sets.
% LPSSet1, LPSSet2 = LPS sets as structures with one field as tv. 
% fis is the Fuzzy Inference System structure made with makeLPSDiffFIS() function. 
% options is a structure containing: 
% options.viewRules = 1 writes the rules and firing strenghts in a GUI table
% options.middle. This should be 0.5 most of the times. Defines the
% middle of the domain over which consequent membership functions are
% defined in the FIS. 
% Outputs:
% dissim: dissimilarity between the two LPS sets
% change: linguistic change 
% deFuzzOut: Defuzzified output
% rulesFired: The rules with firing strength > 0, that resulted in the
% dissimilarity.

    dif = my_round([LPSSet2.tv]-[LPSSet1.tv]);
    [deFuzzOut,rulesFired] = my_evalfis(dif',fis,options.viewRules);
    deFuzzOut = (deFuzzOut-fis.minDefuz)/(fis.maxDefuz-fis.minDefuz);
    for i = 1:length(fis.output.mf)
        outputMship(i) = evalmf(deFuzzOut,fis.output.mf(i).params,fis.output.mf(i).type);
    end
    [~,idx] = max(outputMship);
    change = fis.output.mf(idx).name;
    dissim = my_round(abs(deFuzzOut - options.middle))/0.5;
end

function [deffuzzOut,rulesFired] = my_evalfis(data,fis,viewRules)
% evalualte FIS for antecedents derived from difference between LPS 
% truth-values 
% data is a vector with difference in truth values corresponding to the
% quantifiers. 
% Returns the defuzzified output and the rules that had firing strengths >
% 0 for the input data
    n = 0;
    % Iterate over the rules
    for r = 1:length(fis.rule)
        ruleStrength = inf;
        % Iterate over the antecedents of this rule. Compute the membership 
        % of the antecedent in the input data 
        for i = 1:length(fis.rule(r).antecedent)
            if(fis.rule(r).antecedent(i)~=0)
                ant = fis.rule(r).antecedent(i);
                temp = evalmf(data(i),fis.input(i).mf(abs(ant)).params,fis.input(i).mf(abs(ant)).type);
                % If ant < 0, that implies a NOT in the input rules. So
                % find the inverse of the memberhsip value
                if(ant < 0)
                    temp = 1-temp;
                end
                % Find the overall strngth of the rule
                if(temp<ruleStrength)
                    ruleStrength = temp;
                end
            end
        end
        if(isinf(ruleStrength))
            % If the data does not have > 0 membership in the non zero
            % antecedents for this rule. Implies that this rule says
            % nothing about the data
            ruleStrength = 0;
        end
        % Evaluate the memberships of the ruleStrenght in the rule consquent
        ruleEval(r,:) = feval(fis.output.mf(fis.rule(i).consequent).type,fis.output.domain,fis.output.mf(fis.rule(r).consequent).params);
        ruleEval(r,ruleEval(r,:) > ruleStrength) = ruleStrength;
        if(ruleStrength>0)
            n = n + 1;
            rulesFired(n).ruleNumber = r;
            rulesFired(n).ruleStrength = ruleStrength;
        end
    end
    if(strcmp(fis.aggMethod,'max'))
        fuzzOut = max(ruleEval);
    elseif(strcmp(fis.aggMethod,'sum'))
        fuzzOut = sum(ruleEval);
    end
    if(sum(fuzzOut)==0)
        error(['Cannot evaluate the LPSDiffFIS !!!. No rules fired for the input data: ',num2str(data)]);
    else
        deffuzzOut = (defuzz(fis.output.domain,fuzzOut,fis.defuzzMethod));
    end
    if(viewRules)
        area(fis.output.domain,fuzzOut,'FaceColor','y','EdgeColor','k');
        ylim([0,1]);
        xlim([0,1]);
        hold on;
        for i = 1:length(fis.output.mf)
            plot(fis.output.domain,feval(fis.output.mf(i).type,fis.output.domain,fis.output.mf(i).params),'k--');
            text(mean(fis.output.domain(feval(fis.output.mf(i).type,fis.output.domain,fis.output.mf(i).params)>0)),0.8,fis.output.mf(i).name);
        end
        line([deffuzzOut deffuzzOut],[0 1],'Color','m','LineWidth',2);
        hold off;
    end
end