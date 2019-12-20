function [deffuzzOut,rulesFired] = my_evalfis(data,fis,viewRules)
% evalualte FIS for antecedents derived from LPS and 
    n = 0;
    for r = 1:length(fis.rule)
        ruleStrength = inf;
        for i = 1:length(fis.rule(r).antecedent)
            if(fis.rule(r).antecedent(i)~=0)
                ant = fis.rule(r).antecedent(i);
                temp = evalmf(data(i),fis.input(i).mf(abs(ant)).params,fis.input(i).mf(abs(ant)).type);
                if(ant < 0)
                    temp = 1-temp;
                end
                if(temp<ruleStrength)
                    ruleStrength = temp;
                end
            end
        end
        if(isinf(ruleStrength))
            % If no rule fires
            someThingFishy=1;
            ruleStrength = 0;
        end
        ruleEval(r,:) = feval(fis.output.mf(fis.rule(i).consequent).type,fis.output.domain,fis.output.mf(fis.rule(r).consequent).params);
        ruleEval(r,ruleEval(r,:) > ruleStrength) = ruleStrength;
        if(ruleStrength>0)
            n = n + 1;
            rulesFired(n).ruleNumber = r;
            rulesFired(n).ruleStrength = ruleStrength;
        end
    end
%     rulesFired = find(sum(ruleEval,2) > 0);
    if(strcmp(fis.aggMethod,'max'))
        fuzzOut = max(ruleEval);
    elseif(strcmp(fis.aggMethod,'sum'))
        fuzzOut = sum(ruleEval);
    end
    if(sum(fuzzOut)==0)
        error('Cannot evaluate !!!');
%         deffuzzOut = NaN;
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
        end
        line([deffuzzOut deffuzzOut],[0 1],'Color','m','LineWidth',2);
        hold off;
    end
    
end
