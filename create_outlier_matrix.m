% CREATE_OUTLIER_MATRIX(fd_threshold, confound_tsv, output_mat)
%
% Takes confound file from fMRIprep and exports a timepoint confound matrix
%   of timepoints exceeding the inputted 'fd_threshold'

function mat = create_outlier_matrix(fd_threshold, confound_tsv, output_mat)

% load confounds as table, extract FD column
t = readtable(confound_tsv,'FileType','text','Delimiter','\t');
fd = t.framewise_displacement;

% get timepoints that exceed threshold
fd_outliers = find(fd > fd_threshold);

fprintf('%d timepoints with fd>%.2f\n',numel(fd_outliers),fd_threshold);
% one column per outlier
mat = zeros(size(fd,1),numel(fd_outliers));
for i=1:numel(fd_outliers)
    % set timepoint to '1' for that outlier/column
    tpt = fd_outliers(i);
    mat(tpt,i) = 1;
end

% construct output filename if none given
if ~exist('output_mat','var')
    [fpath,fname] = fileparts(confound_tsv);
    p = strsplit(fname,'_desc-');
    fname = sprintf('%s_desc-fd%.2fOutliers.tsv',fname,fd_threshold);
    output_mat = fullfile(fpath,fname);
end

fprintf('Writing ''%s''\n',output_mat);
% write tab-seperated output file
writematrix(mat,output_mat,'Delimiter','\t','FileType','text');


end