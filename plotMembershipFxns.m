function plotMembershipFxns(mfs)
% plots memberhsip functions supplied in the structure mfs.
% mfs needs to have the following fields:
% name: Cell array containing names of the variables in the mf
% set: a vector with domain over which membership functions are defined
% mf: a matrix with ith row contains the membership fucntion for the
% mfs.name{i} variable. 
    mycolors = myColors();
    mymarkers = '.';
    LineStyle = '-';
    hold on;
    for i = 1:length(mfs.name)
        plot(mfs.set,mfs.mf(i,:),'color',mycolors(i,:),'LineStyle',LineStyle,'Marker',mymarkers,'LineWidth',1);
    end
    legend(mfs.name);
    hold off;
end