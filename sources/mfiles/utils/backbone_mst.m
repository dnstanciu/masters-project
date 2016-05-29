function  [CIJtree] = backbone_mst(CIJ)
%BACKBONE_WU        Backbone
%
%   Modified version of backbone_wu() from Brain Connectivity Toolbox.
%   This computes just the minimum spanning tree.
%
%   [CIJtree,CIJclus] = backbone_wu(CIJ,avgdeg)
%
%   The network backbone contains the dominant connections in the network
%   and may be used to aid network visualization. This function computes
%   the backbone of a given weighted and undirected connection matrix CIJ,
%   using a minimum-spanning-tree based algorithm.
%
%   input:      CIJ,    connection/adjacency matrix (weighted, undirected)
%            avgdeg,    desired average degree of backbone
%   output:
%           CIJtree,    connection matrix of the minimum spanning tree of CIJ
%           CIJclus,    connection matrix of the minimum spanning tree plus
%                       strongest connections up to an average degree 'avgdeg'
%
%   NOTE: nodes with zero strength are discarded.
%   NOTE: CIJclus will have a total average degree exactly equal to
%         (or very close to) 'avgdeg'.
%   NOTE: 'avgdeg' backfill is handled slightly differently than in Hagmann
%         et al 2008.
%
%   Reference: Hidalgo et al. (2007) Science 317, 482.
%              Hagmann et al. (2008) PLoS Biol
%
%   Olaf Sporns, Indiana University, 2007/2008/2010/2012

N = size(CIJ,1);
CIJtree = zeros(N);

% Scale values up
CIJ = int64(CIJ * (10^10));

% find strongest edge (note if multiple edges are tied, only use first one)
[i,j,s] = find(max(max(CIJ))==CIJ);
im = [i(1) i(2)];
jm = [j(1) j(2)];

% copy into tree graph
CIJtree(im,jm) = CIJ(im,jm);
in = im;
out = setdiff(1:N,in);

% repeat N-2 times
for n=1:N-2

    % find strongest link between 'in' and 'out',ignore tied ranks
    [i,j,s] = find(max(max(CIJ(in,out)))==CIJ(in,out));
    im = in(i(1));
    jm = out(j(1));

    % copy into tree graph
    CIJtree(im,jm) = CIJ(im,jm); CIJtree(jm,im) = CIJ(jm,im);
    in = [in jm];
    out = setdiff(1:N,in);

end;
