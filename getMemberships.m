function dataMships = getMemberships(data,mshipFxns)
% Returns the membership of supplied data in all the variables in the
% mshipFxns structure.
% data is a matrix where each row is a feature and columns are the objects
% whose memberships are to be calculated
% dataMships is a 3D matrix, with dataMships(i,j,k) containing the
% membership in mshipFxns.name{i} in of the jth object in the kth object
% set
    for i = 1:size(data,1)
        [X,Y] = meshgrid(data(i,:),mshipFxns.set);
        [val, idx]=min(abs(X-Y));
        for j = 1:length(mshipFxns.name)
            dataMships(j,:,i) = mshipFxns.mf(mshipFxns.map(mshipFxns.name{j}),idx);
        end
    end
end