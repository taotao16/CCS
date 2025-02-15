%% Computes large correlation-based adjacent matrix (LCAM).
function [R_bin, R_wei] = IPN_calLCAM(data, thresh, nblock, connType)
% INPUTS:
%   data   - the sample data: n*p size;
%   thresh - the thresh to decide the adjacency;
%   nblock - the number of blocks in the data;
%   connType - the type of functional connectivity;
%   weight - the weight vector of tissue (e.g., gray matter);
% OUTPUTS:
%   R_bin - binarized adjacent matrix;
%   R_wei - weighted adjacent matrix;
% AUTHOR:
%   Xi-Nian Zuo, Ph.D. of Applied Mathematics
%   Institute of Psychology, Chinese Academy of Sciences.
%   Email: ZuoXN@psych.ac.cn
%   Website: lfcd.psych.ac.cn

[~, p] = size(data);
if nargin < 3
    nblock = 1;
    connType = 'positive';
end
if nargin < 4
    connType = 'positive';
end
data = double(data); %make sure of enough storage
R_bin = sparse([],[],[],p,p,0);
R_wei = sparse([],[],[],p,p,0);
cols_end = rem(p, nblock);
size_block = fix(p / nblock);
%block process
for m=1:nblock
    display(['the ' num2str(m), '-th block ...'])
    start_dim = (m-1)*size_block;
    end_dim = m*size_block;
    data_block = data(:,start_dim+1 : end_dim);
    r_block = IPN_fastCorr(data_block, data);
    clear data_block
    switch connType
        case 'positive'
            idx = find(r_block >= thresh);
        case 'negative'
            idx = find((-r_block) >= thresh);
        case 'abs'
            idx = find(abs(r_block) >= thresh);
    end
    r_block_thr = r_block(idx) ; clear r_block
    s = reshape(r_block_thr, length(idx), 1) ; clear r_block_thr
    [I,J] = ind2sub([size_block, p],idx);
    R_bin = R_bin + sparse(start_dim + I, J, 1, p, p);
    R_wei = R_wei + sparse(start_dim + I, J, s, p, p);
    clear s
end
if cols_end ~= 0
    %the last block
    display(['the ' num2str(nblock+1), '-th block ...'])
    data_block = data(:,(nblock*size_block+1) : p);
    r_block = IPN_fastCorr(data_block, data);
    clear data_block
    switch connType
        case 'positive'
            idx = find(r_block >= thresh);
        case 'negative'
            idx = find((-r_block) >= thresh);
        case 'abs'
            idx = find(abs(r_block) >= thresh);
    end
    r_block_thr = r_block(idx) ; clear r_block
    s = reshape(r_block_thr, length(idx), 1) ; clear r_block_thr
    [I,J] = ind2sub([p-nblock*size_block, p],idx);
    R_bin = R_bin + sparse(nblock*size_block+I, J, 1, p, p);
    R_wei = R_wei + sparse(nblock*size_block+I, J, s, p, p);
    clear s
end
R_bin = R_bin - sparse(1:p, 1:p, spdiags(R_bin,0), p, p, p);
R_wei = R_wei - sparse(1:p, 1:p, spdiags(R_wei,0), p, p, p);